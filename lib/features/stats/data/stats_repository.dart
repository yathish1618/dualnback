import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../user_data/providers/user_data_provider.dart';
import '../../user_data/services/firestore_service.dart';
import '../domain/game_session.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  final authService = ref.read(authServiceProvider);
  return StatsRepository(firestore, authService);
});

class StatsRepository {
  final FirestoreService _firestore;
  final AuthService _authService;
  static const String _key = 'game_sessions_history';

  StatsRepository(this._firestore, this._authService);

  Future<void> saveSession(GameSession session) async {
    // 1. Save Locally (Always)
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_key) ?? [];
    currentList.add(jsonEncode(session.toJson()));
    await prefs.setStringList(_key, currentList);
    debugPrint('[StatsRepo] ✅ Session saved locally (id=${session.id})');

    // 2. Save to Firestore (If Logged In)
    final user = _authService.currentUser;
    if (user != null) {
      debugPrint(
        '[StatsRepo] 🔥 Saving to Firestore (uid=${user.uid}, id=${session.id})',
      );
      try {
        await _firestore.saveGameSession(user.uid, session);
        debugPrint(
          '[StatsRepo] ✅ Firestore save SUCCESS (uid=${user.uid}, id=${session.id})',
        );
      } catch (e) {
        debugPrint('[StatsRepo] ❌ Firestore save FAILED (uid=${user.uid}): $e');
      }
    } else {
      debugPrint('[StatsRepo] ⚠️ No user logged in – skipping Firestore save');
    }
  }

  Future<List<GameSession>> getSessions() async {
    // 1. Try Fetch from Firestore if logged in
    final user = _authService.currentUser;
    if (user != null) {
      debugPrint('[StatsRepo] 🔥 Fetching from Firestore (uid=${user.uid})');
      try {
        final sessions = await _firestore.fetchGameSessionsSnapshot(user.uid);
        debugPrint(
          '[StatsRepo] ✅ Firestore fetch OK – ${sessions.length} sessions',
        );
        if (sessions.isNotEmpty) return sessions;
        debugPrint('[StatsRepo] ℹ️ Firestore empty – falling back to local');
      } catch (e) {
        debugPrint(
          '[StatsRepo] ❌ Firestore fetch FAILED (uid=${user.uid}): $e',
        );
        debugPrint('[StatsRepo] ⚠️ Falling back to local storage');
      }
    } else {
      debugPrint('[StatsRepo] ⚠️ No user – loading from local storage');
    }

    // 2. Fallback to Local
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_key) ?? [];

    return currentList
        .map((str) => GameSession.fromJson(jsonDecode(str)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> syncGuestData(String oldUid, String newUid) async {
    await _firestore.migrateGuestData(oldUid, newUid);
  }

  Future<List<GameSession>> fetchGuestData(String uid) async {
    return _firestore.fetchGameSessionsSnapshot(uid);
  }

  Future<void> restoreGuestData(String uid, List<GameSession> sessions) async {
    await _firestore.restoreGameSessions(uid, sessions);
  }
}
