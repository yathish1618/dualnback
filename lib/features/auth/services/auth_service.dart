import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../user_data/services/firestore_service.dart';
import 'offline_guest_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService;
  final OfflineGuestService _offlineGuestService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb
            ? '361630791216-bl7apcaht3so3nbcrvb6cispu6mcqmdn.apps.googleusercontent.com'
            : null,
  );

  AuthService(this._firestoreService, this._offlineGuestService);

  // Stream of auth changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Link Guest with Google
  Future<UserCredential?> linkWithGoogle({
    Future<void> Function(String oldUid)? onCredentialCollisionPreAuth,
    Future<void> Function(String oldUid, String newUid)?
    onCredentialCollisionPostAuth,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        debugPrint("AuthService: Attempting to link credential...");
        // Try to link first (preserves UID)
        final userCredential = await currentUser.linkWithCredential(credential);
        await userCredential.user?.reload(); // Force refresh
        debugPrint(
          "AuthService: Linked successfully. isAnonymous: ${userCredential.user?.isAnonymous}",
        );
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          debugPrint(
            "AuthService: Credential already in use. Switching accounts...",
          );
          // Account already exists. We must sign in + migrate.
          final oldUid = currentUser.uid;

          // Hook 1: Pre-Auth (Read Data)
          if (onCredentialCollisionPreAuth != null) {
            await onCredentialCollisionPreAuth(oldUid);
          }

          // Sign in to the existing Google account
          final userCredential = await _firebaseAuth.signInWithCredential(
            credential,
          );
          final newUid = userCredential.user!.uid;

          // Hook 2: Post-Auth (Write Data)
          if (oldUid != newUid && onCredentialCollisionPostAuth != null) {
            debugPrint("AuthService: Migrating data from $oldUid to $newUid");
            await onCredentialCollisionPostAuth(oldUid, newUid);
          }
          await userCredential.user?.reload();
          return userCredential;
        }
        debugPrint("AuthService: Link failed with error code: ${e.code}");
        rethrow;
      }
    } catch (e) {
      debugPrint("AuthService: General error in linkWithGoogle: $e");
      throw Exception('Failed to link with Google: $e');
    }
  }

  /// Sign in as Guest.
  ///
  /// **Online**: creates a real Firebase anonymous user and saves their
  /// profile to Firestore.
  ///
  /// **Offline**: cannot reach Firebase, so we fall back to a locally-
  /// generated UUID stored in SharedPreferences. The user can still
  /// play and all data is saved locally. When connectivity is restored
  /// call [maybeMigrateOfflineGuest] to promote the local guest to a
  /// real Firebase anonymous account.
  ///
  /// Returns `null` when the offline fallback is used (no Firebase
  /// credential is available).
  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      if (credential.user != null) {
        await _firestoreService.saveUserProfile(
          credential.user!.uid,
          displayName: 'Guest',
        );
      }
      // If there was a previously pending offline guest, clear it now
      // that we have a real Firebase user.
      if (await _offlineGuestService.hasPendingOfflineGuest()) {
        await _offlineGuestService.clearPendingGuest();
        debugPrint('[AuthService] Cleared stale offline guest key after online sign-in.');
      }
      return credential;
    } catch (e) {
      // Network unavailable — use local offline guest identity.
      debugPrint('[AuthService] signInAnonymously failed (offline?): $e');
      await _offlineGuestService.getOrCreateLocalGuestId();
      debugPrint('[AuthService] Using offline guest identity.');
      return null; // Caller should treat null as "offline guest mode"
    }
  }

  /// If there is a pending offline guest UID, attempt to promote it to
  /// a real Firebase anonymous account.  Call this whenever the app
  /// detects that connectivity has been restored.
  Future<void> maybeMigrateOfflineGuest() async {
    final hasPending = await _offlineGuestService.hasPendingOfflineGuest();
    if (!hasPending) return;

    debugPrint('[AuthService] Migrating offline guest to Firebase...');
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      if (credential.user != null) {
        await _firestoreService.saveUserProfile(
          credential.user!.uid,
          displayName: 'Guest',
        );
      }
      await _offlineGuestService.clearPendingGuest();
      debugPrint(
        '[AuthService] Offline guest migrated → Firebase UID: ${credential.user?.uid}',
      );
    } catch (e) {
      // Still offline — try again later.
      debugPrint('[AuthService] Migration failed (still offline?): $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    // Clear any offline guest state so sign-out is clean.
    await _offlineGuestService.clearPendingGuest();
    await signInAnonymously();
  }
}
