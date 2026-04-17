import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/benefits/benefits.dart';
import 'package:affiliatepro_mobile/view/screens/notifications/notifications.dart';
import 'package:affiliatepro_mobile/view/screens/profile/profile.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';

class ExAffiliateDrawer extends StatelessWidget {
  const ExAffiliateDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final MainController mainController = Get.find<MainController>();

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const ExFxBackground(),
            Container(color: Colors.black.withOpacity(0.62)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: GetBuilder<DashboardController>(builder: (_) {
                  final user = dashboardController.loginModel?.data;
                  final String fullName =
                      "${user?.firstname ?? ''} ${user?.lastname ?? ''}".trim();
                  final String plan =
                      dashboardController.planName.value.isNotEmpty
                          ? dashboardController.planName.value
                          : (user?.planName ?? "Modo afiliado");

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _AvatarBadge(
                            name: fullName.isEmpty ? "EX" : fullName,
                            avatarUrl: user?.profileAvatar,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  fullName.isEmpty ? "Embajador EX" : fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  plan.toUpperCase(),
                                  style: ExFuturisticTheme.overline.copyWith(
                                    color: ExFuturisticTheme.primarySoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon:
                                const Icon(Icons.close, color: Colors.white54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: <Widget>[
                            ExGlassCard(
                              radius: 30,
                              padding: const EdgeInsets.all(16),
                              borderColor:
                                  ExFuturisticTheme.primary.withOpacity(0.22),
                              glowColor: ExFuturisticTheme.primary,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Centro de control',
                                    style: ExFuturisticTheme.overline.copyWith(
                                      color: ExFuturisticTheme.primarySoft,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Accede a tu perfil, beneficios y módulos clave desde una sola capa premium.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.45,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _SectionLabel(text: 'Principal'),
                            _DrawerItem(
                              icon: Icons.person_outline_rounded,
                              label: 'Ver perfil',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const ProfilePage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.workspace_premium_outlined,
                              label: 'Beneficios EX',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const BenefitsPage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.notifications_active_outlined,
                              label: 'Notificaciones',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const NotificationsPage());
                              },
                            ),
                            const SizedBox(height: 8),
                            _SectionLabel(text: 'Navegación'),
                            _DrawerItem(
                              icon: Icons.grid_view_rounded,
                              label: 'Inicio',
                              onTap: () {
                                Navigator.of(context).pop();
                                mainController.changePageIndex(0);
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.link_rounded,
                              label: 'Banners y enlaces',
                              onTap: () {
                                Navigator.of(context).pop();
                                mainController.changePageIndex(2);
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.emoji_events_outlined,
                              label: 'Ranking',
                              onTap: () {
                                Navigator.of(context).pop();
                                mainController.changePageIndex(3);
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.hub_outlined,
                              label: 'Mi red',
                              onTap: () {
                                Navigator.of(context).pop();
                                mainController.changePageIndex(4);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ExGlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        radius: 22,
                        borderColor: ExFuturisticTheme.danger.withOpacity(0.18),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.logout_rounded,
                                color: ExFuturisticTheme.danger),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextButton(
                                onPressed: () => mainController.logOut(context),
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    color: ExFuturisticTheme.danger,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10, top: 8),
      child: Text(
        text.toUpperCase(),
        style: ExFuturisticTheme.overline,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExGlassCard(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Icon(icon, color: ExFuturisticTheme.primarySoft, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .take(2)
        .map((String part) => part[0])
        .join()
        .toUpperCase();

    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ExFuturisticTheme.neonGradient(),
        boxShadow: ExFuturisticTheme.glow(opacity: 0.24),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: ExFuturisticTheme.bg,
        ),
        child: ClipOval(
          child: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(initials),
                )
              : _fallback(initials),
        ),
      ),
    );
  }

  Widget _fallback(String initials) {
    return Center(
      child: Text(
        initials.isEmpty ? 'EX' : initials,
        style: const TextStyle(
          color: ExFuturisticTheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
