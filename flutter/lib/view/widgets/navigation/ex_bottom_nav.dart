import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';

class ExBottomNavItem {
  const ExBottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });

  final String label;
  final Widget icon;
  final Widget? activeIcon;
}

class ExBottomNav extends StatelessWidget {
  const ExBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  }) : assert(items.length > 1);

  final int currentIndex;
  final List<ExBottomNavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFF12131E).withOpacity(0.88),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: ExFuturisticTheme.primary.withOpacity(0.08),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: List<Widget>.generate(items.length, (int index) {
                final bool isActive = index == currentIndex;
                final ExBottomNavItem item = items[index];
                return Expanded(
                  child: _BottomNavButton(
                    label: item.label,
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    isActive: isActive,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final Widget? activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget resolvedIcon = isActive ? (activeIcon ?? icon) : icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: isActive ? 1.04 : 1,
                child: Container(
                  padding: EdgeInsets.all(isActive ? 14 : 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? ExFuturisticTheme.primary.withOpacity(0.12)
                        : Colors.transparent,
                    boxShadow: isActive
                        ? <BoxShadow>[
                            BoxShadow(
                              color:
                                  ExFuturisticTheme.primary.withOpacity(0.18),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  child: resolvedIcon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive
                      ? ExFuturisticTheme.primary
                      : Colors.white.withOpacity(0.60),
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
