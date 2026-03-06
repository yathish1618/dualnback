import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../user_data/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb
            ? '361630791216-bl7apcaht3so3nbcrvb6cispu6mcqmdn.apps.googleusercontent.com'
            : null,
  );

  AuthService(this._firestoreService);

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

  // Sign in with Guest (Anonymous)
  Future<UserCredential> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      if (credential.user != null) {
        await _firestoreService.saveUserProfile(
          credential.user!.uid,
          displayName: 'Guest',
        );
      }
      return credential;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await signInAnonymously();
  }
}
