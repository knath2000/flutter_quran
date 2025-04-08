import 'dart:math' show Random, pi, sin; // Import sin as well
import 'package:flutter/material.dart';

// Simple Star data class
class Star {
  final Offset position;
  final double size;
  final double baseOpacity; // Base opacity
  final Duration twinkleDelay; // Delay before starting twinkle
  final Duration twinkleDuration; // Duration of one twinkle cycle

  Star({
    required this.position,
    required this.size,
    required this.baseOpacity,
    required this.twinkleDelay,
    required this.twinkleDuration,
  });
}

// Widget to display the starry background
class StarryBackground extends StatefulWidget {
  final int numberOfStars;
  final Color starColor;

  const StarryBackground({
    super.key,
    this.numberOfStars = 150, // Default number of stars
    required this.starColor,
  });

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

// Add SingleTickerProviderStateMixin for AnimationController
class _StarryBackgroundState extends State<StarryBackground>
    with SingleTickerProviderStateMixin {
  List<Star> _stars = [];
  final Random _random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 5,
      ), // Duration for one full animation cycle (can adjust)
    )..repeat(); // Repeat the animation indefinitely

    // Generate stars after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use LayoutBuilder to get size reliably after layout
      // This ensures stars are generated within the correct bounds
      // We'll wrap the CustomPaint with LayoutBuilder in the build method
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller
    super.dispose();
  }

  void _generateStars(Size size) {
    if (size == Size.zero || !mounted) return;

    List<Star> newStars = [];
    for (int i = 0; i < widget.numberOfStars; i++) {
      newStars.add(
        Star(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          size: _random.nextDouble() * 1.5 + 0.5,
          baseOpacity: _random.nextDouble() * 0.5 + 0.3,
          // Random delay and duration for twinkling effect
          twinkleDelay: Duration(
            milliseconds: _random.nextInt(5000),
          ), // Delay up to 5s
          twinkleDuration: Duration(
            milliseconds: _random.nextInt(3000) + 1000,
          ), // Duration 1s to 4s
        ),
      );
    }
    // Check if mounted before calling setState
    if (mounted) {
      setState(() {
        _stars = newStars;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get the actual size for star generation
    return LayoutBuilder(
      builder: (context, constraints) {
        // Generate stars if they haven't been generated yet or if size is different
        // Note: Simple check, might regenerate too often on minor resizes.
        // Could add more sophisticated size comparison if needed.
        if (_stars.isEmpty ||
            (_stars.isNotEmpty &&
                (_stars[0].position.dx > constraints.maxWidth ||
                    _stars[0].position.dy > constraints.maxHeight))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _generateStars(constraints.biggest);
          });
        }

        // Pass the animation controller's view and duration to the painter
        return CustomPaint(
          painter: StarPainter(
            stars: _stars,
            starColor: widget.starColor,
            animation: _controller.view, // Pass the animation view (value)
            animationDuration:
                _controller.duration ??
                const Duration(seconds: 5), // Pass the duration
          ),
          child: Container(),
        );
      },
    );
  }
}

// CustomPainter to draw the stars
// Make it listenable to the animation controller
class StarPainter extends CustomPainter {
  final List<Star> stars;
  final Color starColor;
  final Animation<double> animation; // Animation value (0.0 to 1.0)
  final Duration animationDuration; // Total duration of the animation cycle
  final Paint starPaint;

  StarPainter({
    required this.stars,
    required this.starColor,
    required this.animation,
    required this.animationDuration,
  }) : starPaint = Paint(),
       super(repaint: animation); // Repaint when animation ticks

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value; // Current animation value (0.0 to 1.0)

    for (final star in stars) {
      // Calculate twinkle effect based on time, delay, and duration
      // This creates a simple sine wave pulse for opacity
      final double phase =
          (time * animationDuration.inMilliseconds + // Use passed duration
              star.twinkleDelay.inMilliseconds) /
          star.twinkleDuration.inMilliseconds;
      final double twinkle =
          (sin(phase * 2 * pi) + 1) / 2; // Value between 0.0 and 1.0
      final double currentOpacity =
          star.baseOpacity *
          (0.5 + twinkle * 0.5); // Vary opacity between 50% and 100% of base

      starPaint.color = starColor.withOpacity(currentOpacity.clamp(0.0, 1.0));
      canvas.drawCircle(star.position, star.size, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) {
    // Repaint if stars, color, or total duration changes (animation repaint is handled by `super(repaint: animation)`)
    return oldDelegate.stars != stars ||
        oldDelegate.starColor != starColor ||
        oldDelegate.animationDuration != animationDuration;
  }
}
