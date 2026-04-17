import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class TechBackground extends StatefulWidget {
  const TechBackground({super.key});

  @override
  State<TechBackground> createState() => _TechBackgroundState();
}

class _TechBackgroundState extends State<TechBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    // Initialize particles
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        vx: (_random.nextDouble() - 0.5) * 0.001,
        vy: (_random.nextDouble() - 0.5) * 0.001,
        size: _random.nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000000), // Black
            Color(0xFF1A1A1A), // Dark Grey
            Color(0xFF000000), // Black
          ],
        ),
      ),
      child: Stack(
        children: [
          // Grid Effect (Static or simple animation)
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          // Floating Particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TechPainter(_particles),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;

  Particle({required this.x, required this.y, required this.vx, required this.vy, required this.size});

  void update() {
    x += vx;
    y += vy;
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class TechPainter extends CustomPainter {
  final List<Particle> particles;

  TechPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.appPrimary.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColor.appPrimary.withOpacity(0.1)
      ..strokeWidth = 0.5;

    for (var particle in particles) {
      particle.update(); // Update position
      var dx = particle.x * size.width;
      var dy = particle.y * size.height;

      // Draw particle
      canvas.drawCircle(Offset(dx, dy), particle.size, paint);

      // Draw connections
      for (var other in particles) {
        var odx = other.x * size.width;
        var ody = other.y * size.height;
        var dist = sqrt(pow(dx - odx, 2) + pow(dy - ody, 2));

        if (dist < 100) {
          canvas.drawLine(Offset(dx, dy), Offset(odx, ody), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.appPrimary.withOpacity(0.03)
      ..strokeWidth = 1;

    const double spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
