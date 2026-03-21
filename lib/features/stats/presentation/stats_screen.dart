import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../stats/data/stats_repository.dart';
import '../../stats/domain/game_session.dart';

final statsFutureProvider = FutureProvider.autoDispose<List<GameSession>>((
  ref,
) async {
  final repo = ref.read(statsRepositoryProvider);
  return repo.getSessions();
});

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: statsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text("No games played yet."));
          }
          final sortedSessions = sessions.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          return ListView.builder(
            itemCount: sortedSessions.length,
            itemBuilder: (context, index) {
              final session = sortedSessions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    context.push('/stats/details', extra: session);

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(child: Text("N${session.nLevel}")),
                            if (session.debugMode)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Tooltip(
                                  message: 'Played in Debug Mode',
                                  child: Icon(
                                    Icons.bug_report,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Score: ${session.score}/${session.scoreSheet.fold<int>(0, (sum, item) => sum + (item.isPositionMatch ? 1 : 0) + (item.isAudioMatch ? 1 : 0))}"),
                                  const SizedBox(width: 8),
                                  // Mode badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          session.gameMode == 'training'
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.15)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color:
                                            session.gameMode == 'training'
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.5)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.4),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      session.gameMode == 'training'
                                          ? 'Training'
                                          : 'Practice',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            session.gameMode == 'training'
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                DateFormat.yMMMd().add_jm().format(
                                  session.date,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Pos: ${session.correctPosition}"),
                            Text("Audio: ${session.correctAudio}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
