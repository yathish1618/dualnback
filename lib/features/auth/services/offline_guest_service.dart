import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Manages the offline guest identity lifecycle.
///
/// When a user chooses "Continue as Guest" while offline, Firebase
/// can't create an anonymous user. Instead, we generate a local UUID
/// and store it as [_key]. Once connectivity is restored we call
/// [maybeMigrateToFirebase] which fires `signInAnonymously()` on
/// Firebase and clears the pending key — the SharedPreferences data
/// (training profile, training day) is stored globally so it becomes
/// visible under the new Firebase UID automatically.
class OfflineGuestService {
  static const _key = 'offline_guest_uid';

  /// Returns the local guest UID (creating one if needed).
  Future<String> getOrCreateLocalGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null) return existing;
    final newId = const Uuid().v4();
    await prefs.setString(_key, newId);
    debugPrint('[OfflineGuest] Created local guest UID: $newId');
    return newId;
  }

  /// True if there is a pending offline guest UID that hasn't been
  /// linked to a Firebase user yet.
  Future<bool> hasPendingOfflineGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  /// Clears the pending offline guest UID after successful migration.
  Future<void> clearPendingGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    debugPrint('[OfflineGuest] Cleared pending offline guest UID.');
  }
}
