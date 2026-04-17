import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';

class ExFxBackground extends StatefulWidget {
  const ExFxBackground({super.key});

  @override
  State<ExFxBackground> createState() => _ExFxBackgroundState();
}

class _ExFxBackgroundState extends State<ExFxBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
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
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(color: ExFuturisticTheme.bg),
            Positioned(
              left: -120 + (t * 40),
              top: -80,
              child: _orb(
                size: 300,
                color: ExFuturisticTheme.primary.withOpacity(0.18),
              ),
            ),
            Positioned(
              right: -120,
              top: 140 - (t * 50),
              child: _orb(
                size: 280,
                color: ExFuturisticTheme.cyan.withOpacity(0.08),
              ),
            ),
            Positioned(
              left: -90 + (t * 70),
              bottom: -40,
              child: _orb(
                size: 240,
                color: ExFuturisticTheme.purple.withOpacity(0.08),
              ),
            ),
            CustomPaint(
              painter: _GridPainter(
                lineColor: Colors.white.withOpacity(0.035),
                progress: t,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ScanlinePainter(
                    opacity: 0.03 + (t * 0.015),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _orb({required double size, required Color color}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.lineColor, required this.progress});

  final Color lineColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const double spacing = 26;
    for (double dx = 0; dx < size.width; dx += spacing) {
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
    for (double dy = 0; dy < size.height; dy += spacing) {
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    final Paint sweep = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.transparent,
          ExFuturisticTheme.primary.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: <double>[
          math.max(0, progress - 0.08),
          progress.clamp(0.0, 1.0),
          math.min(1, progress + 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sweep);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor;
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1;
    for (double dy = 0; dy < size.height; dy += 4) {
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
