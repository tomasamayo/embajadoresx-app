import 'package:flutter/material.dart';

import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';

class ExNeonButton extends StatelessWidget {
  const ExNeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: ExFuturisticTheme.neonGradient(),
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        boxShadow: ExFuturisticTheme.glow(
          opacity: 0.28,
          blur: 28,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(compact ? 18 : 22),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 22,
              vertical: compact ? 12 : 15,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, color: const Color(0xFF06100C), size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF06100C),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
