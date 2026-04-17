import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class VaultIntroOverlay extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback? onSkip;

  const VaultIntroOverlay({
    super.key,
    required this.animation,
    this.onSkip,
  });

  double _interval(double t, double start, double end, Curve curve) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    final v = (t - start) / (end - start);
    return curve.transform(v.clamp(0, 1));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSkip,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = animation.value;
            final exProgress = _interval(t, 0.00, 0.35, Curves.easeInOut);
            final arrowProgress = _interval(t, 0.35, 0.55, Curves.easeInOut);
            
            // El flash ocurre justo cuando termina el dibujo y antes de abrir
            final flashIn = _interval(t, 0.55, 0.58, Curves.easeOut);
            final flashOut = 1 - _interval(t, 0.58, 0.65, Curves.easeIn);
            final flashOpacity = (flashIn * flashOut).clamp(0, 1);
            
            // Las puertas abren con EaseInOutQuart para máxima fluidez
            final doorProgress = _interval(t, 0.60, 0.95, Curves.easeInOutQuart);
            final centerLineOpacity = _interval(t, 0.58, 0.65, Curves.easeInOut);

            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: AppColor.dashboardBgColor,
                  ),
                ),
                
                // Fondo de rejilla estático
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: CustomPaint(
                      painter: _GridPainter(color: AppColor.appWhite),
                    ),
                  ),
                ),

                // Lógica de Puertas con el Logo dividido
                Stack(
                  children: [
                    // Puerta Izquierda + Mitad Izquierda del Logo
                    Positioned(
                      left: -size.width * 0.5 * doorProgress,
                      top: 0,
                      bottom: 0,
                      width: size.width * 0.5,
                      child: Stack(
                        children: [
                          _DoorPanel(),
                          Center(
                            child: Transform.translate(
                              offset: Offset(size.width * 0.25, 0), // Centrar el logo en la pantalla
                              child: SizedBox(
                                width: math.min(size.width * 0.72, 340),
                                height: math.min(size.width * 0.72, 340) * 0.62,
                                child: ClipRect(
                                  clipper: _LeftHalfClipper(),
                                  child: CustomPaint(
                                    painter: _ExLogoPainter(
                                      exProgress: exProgress,
                                      arrowProgress: arrowProgress,
                                    ),
                                    foregroundPainter: _GlowPainter(
                                      progress: exProgress,
                                      color: AppColor.appPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Puerta Derecha + Mitad Derecha del Logo
                    Positioned(
                      right: -size.width * 0.5 * doorProgress,
                      top: 0,
                      bottom: 0,
                      width: size.width * 0.5,
                      child: Stack(
                        children: [
                          _DoorPanel(),
                          Center(
                            child: Transform.translate(
                              offset: Offset(-size.width * 0.25, 0), // Centrar el logo en la pantalla
                              child: SizedBox(
                                width: math.min(size.width * 0.72, 340),
                                height: math.min(size.width * 0.72, 340) * 0.62,
                                child: ClipRect(
                                  clipper: _RightHalfClipper(),
                                  child: CustomPaint(
                                    painter: _ExLogoPainter(
                                      exProgress: exProgress,
                                      arrowProgress: arrowProgress,
                                    ),
                                    foregroundPainter: _GlowPainter(
                                      progress: exProgress,
                                      color: AppColor.appPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Línea central de energía
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: centerLineOpacity * (1 - doorProgress),
                      child: Center(
                        child: Container(
                          width: 2,
                          height: size.height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColor.appPrimary.withOpacity(0.9),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.appPrimary.withOpacity(0.35),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Flash de luz al abrir
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: flashOpacity * 0.4,
                      child: Container(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double progress;
  final Color color;

  _GlowPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.1) return;
    
    final paint = Paint()
      ..color = color.withOpacity(0.12 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) => oldDelegate.progress != progress;
}

class _LeftHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class _RightHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class _DoorPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F0D),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0B0F0D),
                  const Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.06,
            child: CustomPaint(
              painter: _CarbonPainter(color: AppColor.appWhite),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.18)
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

class _CarbonPainter extends CustomPainter {
  final Color color;
  _CarbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.18)
      ..strokeWidth = 1;

    const step = 14.0;
    for (double y = -size.width; y <= size.height + size.width; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width), paint);
    }
    for (double y = -size.width + step * 0.5; y <= size.height + size.width; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CarbonPainter oldDelegate) => false;
}

class _ExLogoPainter extends CustomPainter {
  final double exProgress;
  final double arrowProgress;

  _ExLogoPainter({
    required this.exProgress,
    required this.arrowProgress,
  });

  Path _ePath(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();
    final left = w * 0.12;
    final top = h * 0.18;
    final bottom = h * 0.82;
    final mid = h * 0.50;
    final right = w * 0.40;

    p.moveTo(right, top);
    p.lineTo(left, top);
    p.lineTo(left, bottom);
    p.lineTo(right, bottom);

    p.moveTo(left, mid);
    p.lineTo(w * 0.34, mid);

    p.moveTo(left, top);
    p.lineTo(left, bottom);

    return p;
  }

  Path _xPath(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();
    final xLeft = w * 0.46;
    final xRight = w * 0.88;
    final top = h * 0.18;
    final bottom = h * 0.82;

    p.moveTo(xLeft, top);
    p.lineTo(xRight, bottom);

    p.moveTo(xRight, top);
    p.lineTo(xLeft, bottom);

    return p;
  }

  Path _arrowPath(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();
    p.moveTo(w * 0.54, h * 0.62);
    p.lineTo(w * 0.66, h * 0.46);
    p.lineTo(w * 0.74, h * 0.54);
    p.lineTo(w * 0.88, h * 0.28);
    return p;
  }

  Path _arrowHead(Size s) {
    final w = s.width;
    final h = s.height;
    final tip = Offset(w * 0.88, h * 0.28);
    final left = Offset(w * 0.82, h * 0.30);
    final down = Offset(w * 0.86, h * 0.36);
    final p = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(down.dx, down.dy)
      ..close();
    return p;
  }

  Path _trim(Path path, double t) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return path;
    final total = metrics.fold<double>(0, (a, m) => a + m.length);
    final target = total * t.clamp(0, 1);
    double current = 0;
    final out = Path();
    for (final m in metrics) {
      final next = current + m.length;
      final end = math.min<double>(m.length, math.max<double>(0.0, target - current));
      if (end > 0) {
        out.addPath(m.extractPath(0, end), Offset.zero);
      }
      current = next;
      if (current >= target) break;
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColor.appPrimary;

    final strokeThin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.022
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.yellow;

    final headPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow;

    final e = _trim(_ePath(size), exProgress);
    final x = _trim(_xPath(size), exProgress);
    final arrow = _trim(_arrowPath(size), arrowProgress);

    canvas.drawPath(e, stroke);
    canvas.drawPath(x, stroke);
    canvas.drawPath(arrow, strokeThin);

    if (arrowProgress > 0.92) {
      canvas.drawPath(_arrowHead(size), headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExLogoPainter oldDelegate) {
    return oldDelegate.exProgress != exProgress || oldDelegate.arrowProgress != arrowProgress;
  }
}
