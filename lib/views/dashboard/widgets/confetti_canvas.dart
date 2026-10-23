import 'dart:math';
import 'package:flutter/material.dart';

/// Animated particle explosion confetti painter.
class ConfettiCanvas extends StatefulWidget {
  final Widget child;

  const ConfettiCanvas({super.key, required this.child});

  @override
  State<ConfettiCanvas> createState() => _ConfettiCanvasState();
}

class _ConfettiCanvasState extends State<ConfettiCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _particles = List.generate(50, (index) => _createParticle());
    _controller.forward();
  }

  _ConfettiParticle _createParticle() {
    final colors = [
      Colors.amber,
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];
    return _ConfettiParticle(
      color: colors[_random.nextInt(colors.length)],
      angle: _random.nextDouble() * 2 * pi,
      speed: 150 + _random.nextDouble() * 250,
      radius: 4 + _random.nextDouble() * 6,
      rotationSpeed: _random.nextDouble() * 4,
    );
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
        return CustomPaint(
          foregroundPainter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double angle;
  final double speed;
  final double radius;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.radius,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 3);

    for (var particle in particles) {
      final distance = particle.speed * progress;
      final dx = center.dx + cos(particle.angle) * distance;
      final dy = center.dy + sin(particle.angle) * distance + (progress * progress * 100);

      final paint = Paint()..color = particle.color.withValues(alpha: 1.0 - progress);

      canvas.drawCircle(Offset(dx, dy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
