import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _gridController;
  late AnimationController _glowController;

  // State
  int? _activeCellIndex;
  Timer? _sequenceTimer;

  // Custom Colors
  static const Color gridBorderColor = Color(0xFF6EC6F0);
  static const Color flashCircleColor = Color(0xFF99EB96);
  static const Color glowColor = Color(0xFF6EC6F0);

  // Dimensions
  static const double gridSize = 160.0;
  static const double circleSize = 40.0; // Fits well within ~53px cell

  @override
  void initState() {
    super.initState();

    // 1. Grid Animation (Controls Fade In AND Fade Out)
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Entry speed
      reverseDuration: const Duration(milliseconds: 800), // Exit speed
    );

    // 2. Glow Animation (Pulsing)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _startSequence();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _gridController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startSequence() {
    // 1. Animate In
    _gridController.forward();

    // 2. Schedule Flashes (Faster pacing)
    // Flash 1: Bottom-Left (6)
    _scheduleFlash(1000, 6);

    // Flash 2: Top-Left (0)
    _scheduleFlash(1500, 0);

    // Flash 3: Top-Right (2)
    _scheduleFlash(2000, 2);

    // Flash 4: Bottom-Right (8)
    _scheduleFlash(2500, 8);

    // 3. Animate Out
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        // Reverse the grid animation (disappears in reverse order)
        _gridController.reverse();
      }
    });

    // 4. Navigate
    _sequenceTimer = Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  void _scheduleFlash(int delayMs, int index) {
    Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      setState(() {
        _activeCellIndex = index;
      });

      // Clear flash after 400ms (Quick pulse)
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _activeCellIndex = null;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The Grid Stack
            SizedBox(
              width: gridSize,
              height: gridSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Layer 1: Animated Glow
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          boxShadow: [
                            BoxShadow(
                              color: glowColor.withValues(
                                alpha: 0.2 + (0.3 * _glowController.value),
                              ),
                              blurRadius: 30 + (10 * _glowController.value),
                              spreadRadius: 5 + (5 * _glowController.value),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Layer 2: The Grid Steps
                  // We rebuild the grid using animated values derived from controller
                  ...List.generate(9, (index) {
                    // Calculate staggering
                    // Interval 0.0-1.0 mapped to index
                    final double start = index * 0.08;
                    final double end = start + 0.4;

                    final Animation<double> opacity = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: _gridController,
                        curve: Interval(
                          start,
                          min(1.0, end),
                          curve: Curves.easeIn,
                        ),
                      ),
                    );

                    return Align(
                      alignment: _getAlignmentForIndex(index),
                      child: FadeTransition(
                        opacity: opacity,
                        child: Container(
                          width: gridSize / 3,
                          height: gridSize / 3,
                          decoration: BoxDecoration(
                            color: index == 4 ? Colors.transparent : Colors.black,
                            border: index == 4
                                ? null
                                : Border(
                                    top: BorderSide(
                                      color: gridBorderColor,
                                      width: (index ~/ 3) == 0 ? 1.5 : 0.75,
                                    ),
                                    left: BorderSide(
                                      color: gridBorderColor,
                                      width: (index % 3) == 0 ? 1.5 : 0.75,
                                    ),
                                    right: BorderSide(
                                      color: gridBorderColor,
                                      width: (index % 3) == 2 ? 1.5 : 0.75,
                                    ),
                                    bottom: BorderSide(
                                      color: gridBorderColor,
                                      width: (index ~/ 3) == 2 ? 1.5 : 0.75,
                                    ),
                                  ),
                          ),
                          child:
                              _activeCellIndex == index
                                  ? Center(
                                    child: Container(
                                      width: circleSize,
                                      height: circleSize,
                                      decoration: const BoxDecoration(
                                        color: flashCircleColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Text (Fades out via manual logic or just stays?)
            // We'll let it stay or fade out with the grid.
            // Let's use simple FadeInUp for entry.
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Text(
                'Dual N-Back',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to place 0-8 indices in 3x3 grid alignment
  Alignment _getAlignmentForIndex(int index) {
    // Row 0: -1.0, -1.0 (Top Left)
    // Row 1: 0.0
    // Row 2: 1.0

    final int row = index ~/ 3;
    final int col = index % 3;

    return Alignment(
      (col - 1.0), // 0 -> -1, 1 -> 0, 2 -> 1
      (row - 1.0),
    );
  }

  double min(double a, double b) => a < b ? a : b;
}
