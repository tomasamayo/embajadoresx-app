import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class VaultIntroOverlay extends StatelessWidget {
  const VaultIntroOverlay({
    super.key,
    required this.animation,
    this.onSkip,
  });

  final Animation<double> animation;
  final VoidCallback? onSkip;

  double _interval(double t, double start, double end, Curve curve) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    final double v = (t - start) / (end - start);
    return curve.transform(v.clamp(0, 1));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSkip,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, _) {
            final double t = animation.value;
            final double logoReveal =
                _interval(t, 0.00, 0.42, Curves.easeOutCubic);
            final double logoPulse =
                _interval(t, 0.18, 0.62, Curves.easeInOutSine);
            final double scanProgress =
                _interval(t, 0.16, 0.62, Curves.easeInOut);
            final double doorProgress =
                _interval(t, 0.60, 0.95, Curves.easeInOutQuart);
            final double centerLineOpacity =
                _interval(t, 0.54, 0.68, Curves.easeInOut);
            final double flashIn = _interval(t, 0.56, 0.60, Curves.easeOut);
            final double flashOut = 1 - _interval(t, 0.60, 0.69, Curves.easeIn);
            final double flashOpacity = (flashIn * flashOut).clamp(0, 1);

            final double logoWidth = math.min(size.width * 0.78, 440.0);
            final double logoHeight = logoWidth * 0.68;

            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    color: AppColor.dashboardBgColor,
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: CustomPaint(
                      painter: _GridPainter(color: AppColor.appWhite),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Stack(
                      children: <Widget>[
                        _OrbGlow(
                          alignment: const Alignment(-0.78, -0.52),
                          color: AppColor.appPrimary.withValues(alpha: 0.16),
                          radius: size.width * 0.34,
                        ),
                        _OrbGlow(
                          alignment: const Alignment(0.84, 0.28),
                          color:
                              const Color(0xFFEDFF2E).withValues(alpha: 0.10),
                          radius: size.width * 0.22,
                        ),
                        _OrbGlow(
                          alignment: Alignment.center,
                          color: AppColor.appPrimary.withValues(alpha: 0.14),
                          radius: size.width * 0.44,
                        ),
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Positioned(
                      left: -size.width * 0.5 * doorProgress,
                      top: 0,
                      bottom: 0,
                      width: size.width * 0.5,
                      child: Stack(
                        children: <Widget>[
                          const _DoorPanel(),
                          Center(
                            child: Transform.translate(
                              offset: Offset(size.width * 0.25, 0),
                              child: _LogoDoorHalf(
                                width: logoWidth,
                                height: logoHeight,
                                clipper: _LeftHalfClipper(),
                                reveal: logoReveal,
                                scanProgress: scanProgress,
                                pulse: logoPulse,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -size.width * 0.5 * doorProgress,
                      top: 0,
                      bottom: 0,
                      width: size.width * 0.5,
                      child: Stack(
                        children: <Widget>[
                          const _DoorPanel(),
                          Center(
                            child: Transform.translate(
                              offset: Offset(-size.width * 0.25, 0),
                              child: _LogoDoorHalf(
                                width: logoWidth,
                                height: logoHeight,
                                clipper: _RightHalfClipper(),
                                reveal: logoReveal,
                                scanProgress: scanProgress,
                                pulse: logoPulse,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Center(
                      child: Opacity(
                        opacity:
                            (1 - doorProgress) * (0.28 + (logoPulse * 0.22)),
                        child: SizedBox(
                          width: logoWidth,
                          height: logoHeight,
                          child: _HologramLogo(
                            reveal: logoReveal,
                            scanProgress: scanProgress,
                            pulse: logoPulse,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                              colors: <Color>[
                                Colors.transparent,
                                AppColor.appPrimary.withValues(alpha: 0.96),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color:
                                    AppColor.appPrimary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: flashOpacity * 0.42,
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

class _LogoDoorHalf extends StatelessWidget {
  const _LogoDoorHalf({
    required this.width,
    required this.height,
    required this.clipper,
    required this.reveal,
    required this.scanProgress,
    required this.pulse,
  });

  final double width;
  final double height;
  final CustomClipper<Rect> clipper;
  final double reveal;
  final double scanProgress;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        clipper: clipper,
        child: _HologramLogo(
          reveal: reveal,
          scanProgress: scanProgress,
          pulse: pulse,
        ),
      ),
    );
  }
}

class _HologramLogo extends StatelessWidget {
  const _HologramLogo({
    required this.reveal,
    required this.scanProgress,
    required this.pulse,
  });

  final double reveal;
  final double scanProgress;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final double scale = 0.74 + (reveal * 0.26);

    return Transform.scale(
      scale: scale,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Opacity(
              opacity: reveal * (0.22 + (pulse * 0.18)),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 30 - (reveal * 10),
                  sigmaY: 30 - (reveal * 10),
                ),
                child: Image.asset(
                  'assets/images/ex_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.92 * reveal,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF7CFFCA),
                      Color(0xFF00FF88),
                      Color(0xFFEDFF2E),
                    ],
                    stops: <double>[0.0, 0.58, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Image.asset(
                  'assets/images/ex_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: (0.12 + (pulse * 0.18)) * reveal,
                child: Align(
                  alignment: Alignment(-0.36 + (scanProgress * 0.72), 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.16,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbGlow extends StatelessWidget {
  const _OrbGlow({
    required this.alignment,
    required this.color,
    required this.radius,
  });

  final Alignment alignment;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _LeftHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class _RightHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class _DoorPanel extends StatelessWidget {
  const _DoorPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF060808),
                  Color(0xFF0B0F0D),
                  Color(0xFF090B0B),
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
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    const double step = 28.0;
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
  const _CarbonPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    const double step = 14.0;
    for (double y = -size.width; y <= size.height + size.width; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width), paint);
    }
    for (double y = -size.width + (step * 0.5);
        y <= size.height + size.width;
        y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CarbonPainter oldDelegate) => false;
}
