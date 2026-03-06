import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../user_data/services/firestore_service.dart';

class StreakCalendarScreen extends ConsumerStatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  ConsumerState<StreakCalendarScreen> createState() =>
      _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends ConsumerState<StreakCalendarScreen> {
  final _firestoreService = FirestoreService();
  late DateTime _currentMonth;
  List<String> _superDates = []; // all 20 blocks complete
  List<String> _basicDates = []; // ≥1 block but not complete
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadMonth(_currentMonth);
  }

  Future<void> _loadMonth(DateTime month) async {
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final yearMonth =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final days = await _firestoreService.fetchTrainingDaysInMonth(
        uid,
        yearMonth,
      );
      setState(() {
        _superDates =
            days.where((d) => d.isComplete).map((d) => d.date).toList();
        _basicDates =
            days
                .where((d) => !d.isComplete && d.blocks.isNotEmpty)
                .map((d) => d.date)
                .toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Training Calendar'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          // Cap width so it doesn't sprawl on desktop
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // ── Month navigation ───────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        final prev = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        );
                        setState(() => _currentMonth = prev);
                        _loadMonth(prev);
                      },
                    ),
                    Text(
                      '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          _currentMonth.month == today.month &&
                                  _currentMonth.year == today.year
                              ? null
                              : () {
                                final next = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month + 1,
                                );
                                setState(() => _currentMonth = next);
                                _loadMonth(next);
                              },
                    ),
                  ],
                ),
              ),

              // ── Day-of-week headers ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children:
                      ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                          .map(
                            (d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const Gap(6),

              // ── Calendar grid ──────────────────────
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCalendar(context, cs, today),
                ),

              const Gap(16),

              // ── Legend ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(
                      color: cs.primary,
                      label: 'Super streak (all 20)',
                    ),
                    const Gap(16),
                    _LegendDot(
                      color: Colors.amber.shade600,
                      label: 'Basic streak (1+)',
                    ),
                    const Gap(16),
                    _LegendDot(
                      color: cs.primary.withValues(alpha: 0.2),
                      label: 'Today',
                      border: cs.primary,
                    ),
                  ],
                ),
              ),
              const Gap(20),

              // ── Summary stats ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CalStat(
                      label: 'Super streak days',
                      value: '${_superDates.length}',
                      icon: Icons.local_fire_department,
                    ),
                    _CalStat(
                      label: 'Basic streak days',
                      value: '${_basicDates.length}',
                      icon: Icons.calendar_month,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, ColorScheme cs, DateTime today) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startOffset = (firstDay.weekday - 1) % 7; // Mon=0

    final cells = <Widget>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, d);
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final isSuper = _superDates.contains(dateStr);
      final isBasic = _basicDates.contains(dateStr);
      final isToday =
          date.day == today.day &&
          date.month == today.month &&
          date.year == today.year;
      final isFuture = date.isAfter(today);

      cells.add(
        _DayCell(
          day: d,
          isSuperStreak: isSuper,
          isBasicStreak: isBasic,
          isToday: isToday,
          isFuture: isFuture,
        ),
      );
    }

    // Use fixed cell size (36×36) laid out in a 7-column wrap
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          cells.map((cell) {
            return SizedBox(width: 36, height: 36, child: cell);
          }).toList(),
    );
  }

  String _monthName(int m) =>
      const [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][m];
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSuperStreak, isBasicStreak, isToday, isFuture;
  const _DayCell({
    required this.day,
    required this.isSuperStreak,
    required this.isBasicStreak,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color fg;

    if (isSuperStreak) {
      bg = cs.primary;
      fg = cs.onPrimary;
    } else if (isBasicStreak) {
      bg = Colors.amber.shade600.withValues(alpha: 0.85);
      fg = Colors.white;
    } else if (isToday) {
      bg = cs.primary.withValues(alpha: 0.18);
      fg = cs.primary;
    } else if (isFuture) {
      bg = Colors.transparent;
      fg = cs.onSurface.withValues(alpha: 0.2);
    } else {
      bg = cs.surfaceContainerHighest.withValues(alpha: 0.5);
      fg = cs.onSurface.withValues(alpha: 0.55);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: isToday ? Border.all(color: cs.primary, width: 1.5) : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            color: fg,
            fontWeight:
                isSuperStreak || isBasicStreak || isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final Color? border;
  const _LegendDot({required this.color, required this.label, this.border});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border:
                border != null ? Border.all(color: border!, width: 1.5) : null,
          ),
        ),
        const Gap(6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _CalStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const Gap(4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
