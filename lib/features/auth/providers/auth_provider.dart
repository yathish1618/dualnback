import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/offline_guest_service.dart';
import '../../user_data/providers/user_data_provider.dart';

final offlineGuestServiceProvider = Provider<OfflineGuestService>((ref) {
  return OfflineGuestService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.read(firestoreServiceProvider),
    ref.read(offlineGuestServiceProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges;
});

/// True if the user is effectively "logged in" — either via Firebase
/// (any authenticated user, anonymous or otherwise) OR via an offline
/// guest UID stored in SharedPreferences.
///
/// The router uses this to decide whether to show the login screen.
final effectiveAuthProvider = StreamProvider<bool>((ref) async* {
  // Watch Firebase auth state changes
  await for (final user in FirebaseAuth.instance.userChanges()) {
    if (user != null) {
      yield true;
    } else {
      // No Firebase user — check for offline guest identity
      final prefs = await SharedPreferences.getInstance();
      yield prefs.containsKey('offline_guest_uid');
    }
  }
});
