import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

void showPracticePickerDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _PracticePickerSheet(),
  );
}

class _PracticePickerSheet extends StatelessWidget {
  const _PracticePickerSheet();

  @override
  Widget build(BuildContext context) {
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
                  label: Text('N$n'),
                  selected: false,
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
