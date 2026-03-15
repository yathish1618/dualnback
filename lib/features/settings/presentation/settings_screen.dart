import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../stats/data/stats_repository.dart';
import '../../settings/domain/game_settings_provider.dart';
import '../../stats/domain/game_session.dart';
import '../../game/services/audio_service.dart' show audioServiceProvider;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAccountSection(context, ref),
          const Divider(),
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme colors'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref
                  .read(themeProvider.notifier)
                  .setTheme(val ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Game'),
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(gameSettingsProvider);
              return SwitchListTile(
                value: settings.visualFeedbackEnabled,
                onChanged:
                    (val) => ref
                        .read(gameSettingsProvider.notifier)
                        .setVisualFeedback(val),
                title: const Text('Visual Feedback'),
                subtitle: const Text('Flash buttons on input'),
                secondary: const Icon(Icons.flash_on),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(gameSettingsProvider);
              return SwitchListTile(
                value: settings.vibrationEnabled,
                onChanged:
                    (val) => ref
                        .read(gameSettingsProvider.notifier)
                        .setVibration(val),
                title: const Text('Vibration'),
                secondary: const Icon(Icons.vibration),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(gameSettingsProvider);
              return SwitchListTile(
                value: settings.debugModeEnabled,
                onChanged:
                    (val) => ref
                        .read(gameSettingsProvider.notifier)
                        .setDebugMode(val),
                title: const Text('Debug Mode'),
                subtitle: const Text('Show detailed game state table'),
                secondary: const Icon(Icons.bug_report),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Audio'),
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(gameSettingsProvider);
              return ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('Voice Gender'),
                // subtitle: const Text('Select the narrator voice'),
                trailing: SegmentedButton<AudioGender>(
                  segments: const [
                    ButtonSegment(
                      value: AudioGender.female,
                      label: Text('Female'),
                      icon: Icon(Icons.female),
                    ),
                    ButtonSegment(
                      value: AudioGender.male,
                      label: Text('Male'),
                      icon: Icon(Icons.male),
                    ),
                  ],
                  selected: {settings.audioGender},
                  onSelectionChanged: (Set<AudioGender> selection) {
                    ref
                        .read(gameSettingsProvider.notifier)
                        .setAudioGender(selection.first);
                    // Pre-load the newly selected audio file immediately
                    ref.read(audioServiceProvider).unlockAndPreload();
                  },
                  showSelectedIcon: false,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isGuest = user?.isAnonymous ?? true;
    final cs = Theme.of(context).colorScheme;

    // Derive display name
    String displayName = 'Guest';
    if (!isGuest && user != null) {
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        displayName = user.displayName!.trim();
      } else if (user.email != null) {
        displayName = user.email!;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Account'),
        ListTile(
          leading: Icon(
            isGuest ? Icons.account_circle_outlined : Icons.verified_user,
          ),
          title: Text(
            isGuest ? 'Guest User' : displayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            isGuest
                ? 'Sign in to save your progress permanently.'
                : 'Progress synced to your account.',
          ),
        ),
        const SizedBox(height: 4),

        if (isGuest)
          // ── Compact "Sign in with Google" button ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final authService = ref.read(authServiceProvider);
                final statsRepo = ref.read(statsRepositoryProvider);
                try {
                  List<GameSession> tempSessions = [];
                  final result = await authService.linkWithGoogle(
                    onCredentialCollisionPreAuth: (oldUid) async {
                      tempSessions = await statsRepo.fetchGuestData(oldUid);
                    },
                    onCredentialCollisionPostAuth: (oldUid, newUid) async {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Syncing guest data to your account…',
                            ),
                          ),
                        );
                      }
                      await statsRepo.restoreGuestData(newUid, tempSessions);
                    },
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result != null
                              ? 'Signed in & synced!'
                              : 'Sign in cancelled or failed.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sign in failed: ${e.toString().replaceAll('Exception:', '')}',
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign in with Google'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                side: BorderSide(color: cs.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          )
        else
          // ── Compact "Sign Out" button ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                side: BorderSide(color: cs.error.withValues(alpha: 0.6)),
                foregroundColor: cs.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
