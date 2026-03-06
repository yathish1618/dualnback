import 'package:flutter/material.dart';

class GridCell extends StatelessWidget {
  final int index;
  final bool isActive;
  final Color activeColor;

  const GridCell({
    super.key,
    required this.index,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? activeColor : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border:
            isActive
                ? Border.all(color: Colors.white, width: 2)
                : Border.all(color: Colors.white10),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
                : [],
      ),
    );
  }
}
