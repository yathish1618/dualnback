import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../auth/providers/auth_provider.dart';
import '../training/state/training_provider.dart';
import '../training/domain/training_models.dart';

final _homeTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.value;
    final isGuest = user?.isAnonymous ?? true;
    final profileAsync = ref.watch(userProfileProvider);
    final dayAsync = ref.watch(trainingDayProvider);

    final profile = profileAsync.value ?? const UserProfile();
    final day = dayAsync.value;

    // Use Firebase displayName first (for Google-signed users), then fall back
    String firstName = 'Guest';
    if (!isGuest && user != null) {
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        firstName = user.displayName!.trim().split(' ').first;
      } else if (user.email != null) {
        firstName = user.email!.split('@').first;
      }
    }

    final completedBlocks = day?.completedBlocks ?? 0;
    final isSessionDone = day?.isComplete ?? false;

    void onTrainingTap() {
      void proceed() {
        if (completedBlocks == 0 && !isSessionDone) {
          context.push(
            '/game',
            extra: {
              'nLevel': profile.currentNLevel,
              'mode': 'training',
              'blockNumber': 1,
            },
          );
        } else {
          context.push('/training');
        }
      }

      if (!profile.hasSeenTutorial) {
        _showTutorialPrompt(context, ref, profile, proceed);
      } else {
        proceed();
      }
    }

    void onNavTap(int i) {
      switch (i) {
        case 0:
          ref.read(_homeTabProvider.notifier).state = 0;
          break;
        case 1:
          context.push('/stats');
          break;
        case 2:
          context.push('/calendar');
          break;
        case 3:
          if (!profile.hasSeenTutorial) {
            _showTutorialPrompt(context, ref, profile, () {
              _showPracticeDialog(context, profile.currentNLevel);
            });
          } else {
            _showPracticeDialog(context, profile.currentNLevel);
          }
          break;
        case 4:
          context.push('/tutorial');
          break;
        case 5:
          context.push('/settings');
          break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                'Hello, $firstName',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'N',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${profile.currentNLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Gap(8),

                  // â”€â”€ Logo + Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5),
                                blurRadius: 28,
                                offset: Offset.zero,
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'DUAL N-BACK',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'BRAIN TRAINING',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),

                  // â”€â”€ Training card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _TrainingCard(
                    streak: profile.currentStreak,
                    completedBlocks: completedBlocks,
                    isSessionDone: isSessionDone,
                    onTap: onTrainingTap,
                  ),
                  const Gap(16),

                  // â”€â”€ Quick stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _QuickStatsRow(
                    currentStreak: profile.currentStreak,
                    bestN: profile.bestNLevel,
                    bestStreak: profile.bestStreak,
                  ),
                  const Gap(20),

                  // â”€â”€ Nav grid tiles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _NavTileGrid(onTap: onNavTap),
                  const Gap(32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorialPrompt(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    VoidCallback onProceed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('First Time Playing?'),
          content: const Text(
            'Dual N-Back can be a bit tricky to understand at first. Would you like to see a quick interactive "How to play" demo?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref
                    .read(userProfileProvider.notifier)
                    .update(profile.copyWith(hasSeenTutorial: true));
                Navigator.pop(ctx);
                onProceed();
              },
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(userProfileProvider.notifier)
                    .update(profile.copyWith(hasSeenTutorial: true));
                Navigator.pop(ctx);
                context.push('/tutorial');
              },
              child: const Text('Show Me'),
            ),
          ],
        );
      },
    );
  }

  void _showPracticeDialog(BuildContext context, int currentN) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PracticePicker(defaultN: currentN),
    );
  }
}

// â”€â”€ Minimal nav tile grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _NavTileGrid extends StatelessWidget {
  final ValueChanged<int> onTap;
  const _NavTileGrid({required this.onTap});

  static const _tiles = [
    _TileData(1, Icons.bar_chart_rounded, 'Stats', Color(0xFF6C63FF)),
    _TileData(2, Icons.calendar_month_rounded, 'Calendar', Color(0xFF00BFA5)),
    _TileData(3, Icons.science_rounded, 'Practice', Color(0xFFFF6D00)),
    _TileData(4, Icons.help_outline_rounded, 'How to Play', Color(0xFF0091EA)),
    _TileData(5, Icons.settings_rounded, 'Settings', Color(0xFF7CB342)),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return GridView.count(
          crossAxisCount: isWide ? 5 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          // Wider screens: tiles are more rectangular (less tall)
          childAspectRatio: isWide ? 2.2 : 1.05,
          children: _tiles.map((t) => _NavTile(data: t, onTap: onTap)).toList(),
        );
      },
    );
  }
}

class _TileData {
  final int navIndex;
  final IconData icon;
  final String label;
  final Color color;
  const _TileData(this.navIndex, this.icon, this.label, this.color);
}

class _NavTile extends StatefulWidget {
  final _TileData data;
  final ValueChanged<int> onTap;
  const _NavTile({required this.data, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) => _ctrl.forward();
  void _onCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.data.color;

    return GestureDetector(
      onTap: () => widget.onTap(widget.data.navIndex),
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onCancel,
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.data.icon, color: c, size: 28),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.data.label,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Training card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TrainingCard extends StatelessWidget {
  final int streak, completedBlocks;
  final bool isSessionDone;
  final VoidCallback onTap;

  const _TrainingCard({
    required this.streak,
    required this.completedBlocks,
    required this.isSessionDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = completedBlocks / 20.0;

    // Shortened labels
    String actionLabel;
    if (isSessionDone) {
      actionLabel = '✓ Done';
    } else if (completedBlocks == 0) {
      actionLabel = '▶ Start';
    } else {
      actionLabel = '▶ B${completedBlocks + 1}';
    }

    return InkWell(
      onTap: isSessionDone ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isSessionDone
                    ? [
                      Colors.green.withValues(alpha: 0.15),
                      Colors.teal.withValues(alpha: 0.10),
                    ]
                    : [
                      cs.primary.withValues(alpha: 0.17),
                      cs.secondary.withValues(alpha: 0.10),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSessionDone
                    ? Colors.green.withValues(alpha: 0.3)
                    : cs.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  streak > 0 ? '🔥 $streak-Day Streak' : '📅 Daily Training',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isSessionDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      '✓ Done',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  isSessionDone ? Colors.green : cs.primary,
                ),
              ),
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Short: "12/20" instead of "12 / 20 blocks today"
                Text(
                  '$completedBlocks/20 blocks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (!isSessionDone)
                  Text(
                    actionLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ 3-tile quick stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _QuickStatsRow extends StatelessWidget {
  final int currentStreak, bestN, bestStreak;
  const _QuickStatsRow({
    required this.currentStreak,
    required this.bestN,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(label: 'Streak', value: '🔥 $currentStreak'),
        const Gap(10),
        _StatTile(label: 'Best N', value: 'N-$bestN'),
        const Gap(10),
        _StatTile(label: 'Best Streak', value: '🏆 $bestStreak'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Practice picker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PracticePicker extends ConsumerWidget {
  final int defaultN;
  const _PracticePicker({required this.defaultN});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practice Mode',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Choose your N-level',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(9, (i) {
                final n = i + 1;
                return ChoiceChip(
                  label: Text('N-$n'),
                  selected: n == defaultN,
                  onSelected: (_) {
                    Navigator.pop(context);
                    context.push(
                      '/game',
                      extra: {'nLevel': n, 'mode': 'practice'},
                    );
                  },
                );
              }),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}
