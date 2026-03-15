import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/auth_provider.dart';
import '../../../core/services/connectivity_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInGuest() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final connectivity = ref.watch(connectivityProvider);
    // isOnline defaults to true while still loading so we don't flash disabled state
    final isOnline = connectivity.when(
      data: (online) => online,
      loading: () => true,
      error: (_, __) => true,
    );

    // Consistent border radius for both buttons
    const buttonRadius = BorderRadius.all(Radius.circular(14));
    const buttonShape = RoundedRectangleBorder(borderRadius: buttonRadius);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(20),
                Text(
                  'Dual N-Back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const Gap(6),
                Text(
                  'Train your working memory',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Gap(24),

                // ── Offline banner ──────────────────────────────────────────
                if (!isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cs.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 18,
                          color: cs.onErrorContainer,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            "You're offline. Play as guest and data will sync when you reconnect.",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: cs.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Gap(24),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Google sign-in — disabled when offline
                  Tooltip(
                    message: isOnline ? '' : 'Requires internet connection',
                    child: ElevatedButton.icon(
                      onPressed: isOnline ? _signInWithGoogle : null,
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: buttonShape,
                      ),
                    ),
                  ),
                  const Gap(14),
                  // Guest — always available (uses offline fallback when needed)
                  FilledButton.icon(
                    onPressed: _signInGuest,
                    icon: const Icon(Icons.person_outline),
                    label: Text(
                      isOnline ? 'Continue as Guest' : 'Continue as Guest (Offline)',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: buttonShape,
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
