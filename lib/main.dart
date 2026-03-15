import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/services/offline_guest_service.dart';
import 'features/user_data/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence so writes are queued when offline
  // and automatically replayed when connectivity is restored.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // If online, attempt to promote any pending offline guest to a real
  // Firebase anonymous account right at startup.
  final results = await Connectivity().checkConnectivity();
  final isOnline = results.any((r) => r != ConnectivityResult.none);
  if (isOnline) {
    final offlineGuestService = OfflineGuestService();
    if (await offlineGuestService.hasPendingOfflineGuest()) {
      final authService = AuthService(FirestoreService(), offlineGuestService);
      await authService.maybeMigrateOfflineGuest();
    }
  }

  runApp(const ProviderScope(child: DualNBackApp()));
}

class DualNBackApp extends ConsumerWidget {
  const DualNBackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Dual N-Back',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
