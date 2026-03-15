import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../stats/domain/game_session.dart';
import '../../training/domain/training_models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  // ─── User Profile (game_settings) ──────────────────────────────────────────

  Future<void> saveUserProfile(
    String userId, {
    String? displayName,
    String? email,
  }) async {
    try {
      await _usersCollection.doc(userId).set({
        'displayName': displayName ?? 'Guest',
        'email': email,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Swallow — Firestore offline persistence will replay this write
      // when connectivity is restored.
      debugPrint('[FirestoreService] saveUserProfile queued (offline?): $e');
    }
  }

  // ─── Training Profile (N-level, streak) ───────────────────────────────────

  Future<UserProfile> fetchUserProfile(String userId) async {
    try {
      final doc =
          await _usersCollection
              .doc(userId)
              .collection('profile')
              .doc('data')
              .get();
      if (!doc.exists) return const UserProfile();
      return UserProfile.fromMap(doc.data());
    } catch (e) {
      debugPrint('[FirestoreService] fetchUserProfile error: $e');
      return const UserProfile();
    }
  }

  Future<void> saveTrainingProfile(String userId, UserProfile profile) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('profile')
          .doc('data')
          .set(profile.toMap(), SetOptions(merge: true));
      debugPrint(
        '[FirestoreService] ✅ Profile saved N=${profile.currentNLevel} streak=${profile.currentStreak}',
      );
    } catch (e) {
      debugPrint('[FirestoreService] ✗ saveTrainingProfile: $e');
    }
  }

  // ─── Training Days ─────────────────────────────────────────────────────────

  Future<TrainingDay?> fetchTrainingDay(String userId, String date) async {
    try {
      final doc =
          await _usersCollection
              .doc(userId)
              .collection('training_days')
              .doc(date)
              .get();
      if (!doc.exists) return null;
      return TrainingDay.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('[FirestoreService] fetchTrainingDay error: $e');
      return null;
    }
  }

  Future<void> saveTrainingDay(String userId, TrainingDay day) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('training_days')
          .doc(day.date)
          .set(day.toMap());
      debugPrint(
        '[FirestoreService] ✅ TrainingDay saved date=${day.date} blocks=${day.completedBlocks}',
      );
    } catch (e) {
      debugPrint('[FirestoreService] ✗ saveTrainingDay: $e');
    }
  }

  Future<List<TrainingDay>> fetchTrainingDaysInMonth(
    String userId,
    String yearMonth,
  ) async {
    try {
      final snapshot =
          await _usersCollection
              .doc(userId)
              .collection('training_days')
              .where('date', isGreaterThanOrEqualTo: '$yearMonth-01')
              .where('date', isLessThanOrEqualTo: '$yearMonth-31')
              .get();
      return snapshot.docs
          .map((doc) => TrainingDay.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[FirestoreService] fetchTrainingDaysInMonth error: $e');
      return [];
    }
  }

  // ─── Legacy Game Sessions (kept for settings screen data migration) ────────

  Future<void> saveGameSession(String userId, GameSession session) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('game_sessions')
          .doc(session.id)
          .set(session.toJson());
    } catch (e) {
      throw Exception('Failed to save game session: $e');
    }
  }

  Future<List<GameSession>> fetchGameSessionsSnapshot(String userId) async {
    try {
      final snapshot =
          await _usersCollection.doc(userId).collection('game_sessions').get();
      return snapshot.docs
          .map((doc) => GameSession.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch game sessions: $e');
    }
  }

  Future<void> restoreGameSessions(
    String userId,
    List<GameSession> sessions,
  ) async {
    try {
      final batch = _firestore.batch();
      final sessionsRef = _usersCollection
          .doc(userId)
          .collection('game_sessions');
      for (var session in sessions) {
        batch.set(sessionsRef.doc(session.id), session.toJson());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to restore game sessions: $e');
    }
  }

  Future<void> migrateGuestData(String oldUid, String newUid) async {
    try {
      final oldRef = _usersCollection.doc(oldUid).collection('game_sessions');
      final newRef = _usersCollection.doc(newUid).collection('game_sessions');
      final snapshot = await oldRef.get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.set(newRef.doc(doc.id), doc.data());
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to migrate guest data: $e');
    }
  }
}
