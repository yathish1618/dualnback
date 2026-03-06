import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ControlPad extends StatelessWidget {
  final VoidCallback onPositionPressed;
  final VoidCallback onAudioPressed;
  final bool isPositionSelected;
  final bool isAudioSelected;
  final Color? positionFeedbackColor;
  final Color? audioFeedbackColor;

  const ControlPad({
    super.key,
    required this.onPositionPressed,
    required this.onAudioPressed,
    this.isPositionSelected = false,
    this.isAudioSelected = false,
    this.positionFeedbackColor,
    this.audioFeedbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _GameButton(
              label: 'POSITION',
              icon: Icons.grid_view_rounded,
              onPressed: onPositionPressed,
              idleColor: Theme.of(context).colorScheme.secondary,
              feedbackColor: positionFeedbackColor,
            ),
          ),
          const Gap(16),
          Expanded(
            child: _GameButton(
              label: 'AUDIO',
              icon: Icons.headphones_rounded,
              onPressed: onAudioPressed,
              idleColor: Theme.of(context).colorScheme.primary,
              feedbackColor: audioFeedbackColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A minimal game button that shows ONLY:
///   • Idle:     semi-transparent colour tint, coloured border + text
///   • Feedback: solid green or red fill + white text
///
/// No ElevatedButton, no hover state, no ripple / ink splash.
class _GameButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color idleColor;
  final Color? feedbackColor;

  const _GameButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.idleColor,
    this.feedbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final isFeedback = feedbackColor != null;
    final bgColor =
        isFeedback ? feedbackColor! : idleColor.withValues(alpha: 0.12);
    final fgColor = isFeedback ? Colors.white : idleColor;
    final borderColor = isFeedback ? feedbackColor! : idleColor;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isFeedback ? 2.5 : 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: fgColor),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: fgColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
