import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';

class ExGlassCard extends StatelessWidget {
  const ExGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.borderColor,
    this.glowColor,
    this.onTap,
    this.gradient,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final Widget body = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ?? ExFuturisticTheme.glassGradient(),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? ExFuturisticTheme.stroke,
            ),
            boxShadow: glowColor == null
                ? <BoxShadow>[]
                : ExFuturisticTheme.glow(
                    color: glowColor!,
                    opacity: 0.12,
                    blur: 26,
                  ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) {
      return body;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: body,
      ),
    );
  }
}
