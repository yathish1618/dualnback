import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/training_models.dart';
import '../../user_data/services/firestore_service.dart';

final _firestoreService = FirestoreService();

// ─── User Profile Provider ────────────────────────────────────────────────────

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
      return UserProfileNotifier();
    });

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  static const _prefsKey = 'user_profile_v2';

  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      // Try local first for speed
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString(_prefsKey);
      if (local != null) {
        state = AsyncValue.data(
          UserProfile.fromMap(Map<String, dynamic>.from(json.decode(local))),
        );
      } else {
        state = const AsyncValue.data(UserProfile());
      }
      // Then sync from Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final remote = await _firestoreService.fetchUserProfile(uid);
        state = AsyncValue.data(remote);
        await prefs.setString(_prefsKey, json.encode(remote.toMap()));
      }
    } catch (e) {
      debugPrint('[UserProfile] load error: $e');
      state = const AsyncValue.data(UserProfile());
    }
  }

  Future<void> update(UserProfile profile) async {
    state = AsyncValue.data(profile);
    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(profile.toMap()));
    // Persist remotely
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.saveTrainingProfile(uid, profile);
    }
  }

  /// Called after a block completes — adapts N, updates streak
  Future<void> afterBlock({
    required int positionMistakes,
    required int audioMistakes,
    required bool isLastBlock,
    required String today,
  }) async {
    final current = state.value ?? const UserProfile();
    final newN = adaptNLevel(
      currentN: current.currentNLevel,
      positionMistakes: positionMistakes,
      audioMistakes: audioMistakes,
    );

    int newStreak = current.currentStreak;
    int newBest = current.bestStreak;

    // Update streak on the FIRST block of a new day (any block counts for streak).
    // If lastTrainingDate is already today, streak is already counted — don't add again.
    final isNewDay = current.lastTrainingDate != today;
    if (isNewDay) {
      final yesterday = _yyyyMmDd(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      if (current.lastTrainingDate == yesterday) {
        newStreak = current.currentStreak + 1; // Consecutive day
      } else {
        newStreak = 1; // Streak reset (missed a day)
      }
      if (newStreak > newBest) newBest = newStreak;
    }

    await update(
      current.copyWith(
        currentNLevel: newN,
        bestNLevel: newN > current.bestNLevel ? newN : current.bestNLevel,
        currentStreak: newStreak,
        bestStreak: newBest,
        // Record today so subsequent blocks don't double-count streak
        lastTrainingDate: today,
      ),
    );
  }

  String _yyyyMmDd(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

// ─── Training Day Provider ────────────────────────────────────────────────────

final trainingDayProvider =
    StateNotifierProvider<TrainingDayNotifier, AsyncValue<TrainingDay>>((ref) {
      return TrainingDayNotifier();
    });

class TrainingDayNotifier extends StateNotifier<AsyncValue<TrainingDay>> {
  static const _prefsKey = 'training_day_v2';

  TrainingDayNotifier() : super(const AsyncValue.loading()) {
    _loadToday();
  }

  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      TrainingDay? day;

      if (saved != null) {
        final decoded = TrainingDay.fromMap(
          Map<String, dynamic>.from(json.decode(saved)),
        );
        if (decoded.date == _today) {
          day = decoded;
        }
      }

      // Try Firestore if no local today
      if (day == null) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          day = await _firestoreService.fetchTrainingDay(uid, _today);
        }
      }

      final profile = await _firestoreService.fetchUserProfile(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      state = AsyncValue.data(
        day ??
            TrainingDay(
              date: _today,
              blocks: const [],
              startingNLevel: profile.currentNLevel,
              endingNLevel: profile.currentNLevel,
            ),
      );
    } catch (e) {
      debugPrint('[TrainingDay] load error: $e');
      state = AsyncValue.data(
        TrainingDay(
          date: _today,
          blocks: const [],
          startingNLevel: 2,
          endingNLevel: 2,
        ),
      );
    }
  }

  Future<void> addBlockResult(
    BlockResult block,
    UserProfile updatedProfile,
  ) async {
    final current = state.value;
    if (current == null) return;

    final updated = TrainingDay(
      date: current.date,
      blocks: [...current.blocks, block],
      startingNLevel: current.startingNLevel,
      endingNLevel: updatedProfile.currentNLevel,
    );
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> _persist(TrainingDay day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(day.toMap()));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.saveTrainingDay(uid, day);
    }
  }

  void refresh() => _loadToday();
}
