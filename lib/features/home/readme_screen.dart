import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ReadmeScreen extends StatelessWidget {
  const ReadmeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('READ ME'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is Dual N-Back?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(16),
            Text(
              'Dual N-Back is a cognitive training game aimed at improving working memory and fluid intelligence. '
              'The task involves remembering a sequence of spoken letters and a sequence of positions of a square at the same time.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(32),

            Text(
              'How to Play',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              '• You will see a square move on a 3x3 grid and hear a letter.\n'
              '• Respond if the position or letter matches the one from N steps earlier.\n'
              '• N starts at 2 (2-back) and increases as you improve.',
              style: TextStyle(height: 1.5, fontSize: 16),
            ),
            const Gap(32),

            Text(
              'Scientific Benefits',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Text(
              'Research suggests that practicing this task can improve fluid intelligence (Gf), which is the ability to reason and solve new problems independently of previously acquired knowledge.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(32),

            Text(
              'Research Paper',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: const SelectableText(
                'Jaeggi, S. M., Buschkuehl, M., Jonides, J., & Perrig, W. J. (2008). '
                'Improving fluid intelligence with training on working memory. '
                'PNAS, 105(19), 6829–6833.\n\n'
                'https://www.pnas.org/doi/10.1073/pnas.0801268105',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const Gap(32),

            const Divider(),
            const Gap(16),
            Text('Development', style: Theme.of(context).textTheme.labelLarge),
            const Gap(4),
            Text(
              'Developed as a modern, high-performance implementation of the classic cognitive training exercise.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
