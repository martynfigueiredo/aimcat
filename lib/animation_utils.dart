import 'dart:math';

import 'package:flutter/material.dart';

/// A custom page route that provides a smooth zoom + fade transition.
class AimCatPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AimCatPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smoother zoom with fastOutSlowIn - starts fast, ends gently
            final zoomAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            );

            // Smooth fade with easeOut for a gentle appearance
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: zoomAnimation,
                child: child,
              ),
            );
          },
        );
}

/// A widget that provides a staggered entry animation for its children.
class StaggeredEntry extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayIncrement;

  const StaggeredEntry({
    super.key,
    required this.child,
    required this.index,
    this.delayIncrement = const Duration(milliseconds: 50),
  });

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    Future.delayed(widget.delayIncrement * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A background widget that displays subtle floating sparkles.
class SparkleBackground extends StatefulWidget {
  final Widget child;
  const SparkleBackground({super.key, required this.child});

  @override
  State<SparkleBackground> createState() => _SparkleBackgroundState();
}

class _SparkleBackgroundState extends State<SparkleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Sparkle> _sparkles = List.generate(20, (_) => _Sparkle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _SparklePainter(_sparkles, _controller.value, color),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Sparkle {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble();
  final double size = Random().nextDouble() * 3 + 1;
  final double speed = Random().nextDouble() * 0.2 + 0.1;
  final double offset = Random().nextDouble() * 2 * pi;
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double progress;
  final Color color;

  _SparklePainter(this.sparkles, this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.15);
    
    for (var sparkle in sparkles) {
      final double xPos = (sparkle.x * size.width);
      final double yShift = (progress * sparkle.speed * size.height) + (sparkle.y * size.height);
      final double yPos = yShift % size.height;
      
      final double opacity = (sin(progress * 2 * pi + sparkle.offset) + 1) / 2;
      paint.color = color.withValues(alpha: 0.1 * opacity);
      
      canvas.drawCircle(Offset(xPos, yPos), sparkle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}
