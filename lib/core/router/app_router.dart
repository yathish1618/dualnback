import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/readme_screen.dart';
import '../../features/home/tutorial_screen.dart';
import '../../features/home/about_screen.dart';
import '../../features/game/presentation/game_screen.dart';
import '../../features/game/presentation/game_result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/stats/presentation/session_details_screen.dart';
import '../../features/stats/domain/game_session.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/training/presentation/training_session_screen.dart';
import '../../features/training/presentation/streak_calendar_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // effectiveAuthProvider is true when the user is logged into Firebase
  // OR has a pending offline guest UID — either way they should not see
  // the login screen.
  final effectiveAuth = ref.watch(effectiveAuthProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/game',
        builder: (context, state) => GameScreen(extra: state.extra),
      ),
      GoRoute(
        path: '/training',
        builder: (context, state) => const TrainingSessionScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const StreakCalendarScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => GameResultScreen(extra: state.extra),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
        routes: [
          GoRoute(
            path: 'details',
            builder: (context, state) {
              final session = state.extra as GameSession;
              return SessionDetailsScreen(session: session);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/readme',
        builder: (context, state) => const ReadmeScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
    redirect: (context, state) {
      final isSplash = state.uri.toString() == '/splash';

      // While effective auth is still loading never redirect — let splash play.
      if (effectiveAuth.isLoading) return null;

      // If we're on splash, never redirect away — SplashScreen navigates itself.
      if (isSplash) return null;

      // After splash has finished navigating, apply auth guard.
      // isLoggedIn is true for both Firebase users AND offline guests.
      final isLoggedIn = effectiveAuth.value ?? false;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
  );
});
