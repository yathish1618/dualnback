import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../stats/domain/game_session.dart';

class SessionDetailsScreen extends StatelessWidget {
  final GameSession session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (session.scoreSheet.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Session Details")),
        body: const Center(
          child: Text("No score sheet available for this session."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Session Details – N${session.nLevel}")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Debug mode banner ─────────────────────────────────────
          if (session.debugMode)
            Container(
              color: Colors.amber.shade700.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.bug_report,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      'This session was played in Debug Mode — scores are unofficial.',
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Score table ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowMinHeight: 30,
                    dataRowMaxHeight: 30,
                    columnSpacing: 12,
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Pos')),
                      DataColumn(label: Text('Aud')),
                      DataColumn(label: Text('M-Pos')),
                      DataColumn(label: Text('M-Aud')),
                      DataColumn(label: Text('S-Pos')),
                      DataColumn(label: Text('S-Aud')),
                      DataColumn(label: Text('Total')),
                    ],
                    rows:
                        session.scoreSheet.map((result) {
                          final row = result.positionIndex ~/ 3;
                          final col = result.positionIndex % 3;

                          Color rowColor = Colors.transparent;
                          if (result.positionScore == -1 ||
                              result.audioScore == -1) {
                            rowColor = Colors.red.withValues(alpha: 0.12);
                          } else if (result.positionScore == 1 ||
                              result.audioScore == 1) {
                            rowColor = Colors.green.withValues(alpha: 0.12);
                          }

                          return DataRow(
                            color: WidgetStateProperty.all(rowColor),
                            cells: [
                              DataCell(Text('${result.trialNumber}')),
                              DataCell(Text('R${row + 1}:C${col + 1}')),
                              DataCell(Text(result.audioLetter)),
                              // M-Pos
                              DataCell(
                                Text(
                                  result.isPositionMatch ? '✓' : '–',
                                  style: TextStyle(
                                    color:
                                        result.isPositionMatch
                                            ? Colors.green
                                            : cs.onSurface.withValues(
                                              alpha: 0.4,
                                            ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // M-Aud
                              DataCell(
                                Text(
                                  result.isAudioMatch ? '✓' : '–',
                                  style: TextStyle(
                                    color:
                                        result.isAudioMatch
                                            ? Colors.green
                                            : cs.onSurface.withValues(
                                              alpha: 0.4,
                                            ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                _buildScoreCell(result.positionScore, cs),
                              ),
                              DataCell(_buildScoreCell(result.audioScore, cs)),
                              DataCell(Text('${result.totalScore}')),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
          // ── Legend ────────────────────────────────────────────────
          _buildLegend(context, cs),
        ],
      ),
    );
  }

  Widget _buildScoreCell(int score, ColorScheme cs) {
    Color color = cs.onSurface.withValues(alpha: 0.4);
    if (score == 1) color = Colors.green;
    if (score == -1) color = Colors.red;

    return Text(
      '$score',
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLegend(BuildContext context, ColorScheme cs) {
    final style = TextStyle(
      fontSize: 12,
      color: cs.onSurface.withValues(alpha: 0.7),
    );
    const entries = [
      ('#', 'Trial number'),
      ('Pos', 'Grid position (e.g. R2:C1 = row 2, column 1)'),
      ('Aud', 'Letter heard'),
      ('M-Pos', 'Did position match N trials back?'),
      ('M-Aud', 'Did audio match N trials back?'),
      (
        'S-Pos',
        'Position score  (+1 correct hit, −1 false press, 0 otherwise)',
      ),
      ('S-Aud', 'Audio score  (+1 correct hit, −1 false press, 0 otherwise)'),
      ('Total', 'Running total score'),
    ];

    return Container(
      width: double.infinity,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Column guide',
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 6),
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: RichText(
                text: TextSpan(
                  style: style,
                  children: [
                    TextSpan(
                      text: '${e.$1}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    TextSpan(text: e.$2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
