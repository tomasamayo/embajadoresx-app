import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/controller/membership_controller.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/ia_marketing/ia_marketing_screen.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/log_list/loglist.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/orders/orders.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payment_details/paymentDetail.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payments/payments.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/reports/reports.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/store/store_page.dart';
import 'package:affiliatepro_mobile/view/screens/benefits_v2/benefits_page_v2.dart';
import 'package:affiliatepro_mobile/view/screens/coinx/coinx_wallet_screen.dart';
import 'package:affiliatepro_mobile/view/screens/dashboard/verification/account_verification_screen.dart';
import 'package:affiliatepro_mobile/view/screens/membership/membership_buy.dart';
import 'package:affiliatepro_mobile/view/screens/membership/membership_history.dart';
import 'package:affiliatepro_mobile/view/screens/notifications/notifications.dart';
import 'package:affiliatepro_mobile/view/screens/academy_screen.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_remote_image.dart';

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
            Container(color: Colors.black.withValues(alpha: 0.62)),
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
                            _DrawerItem(
                              icon: Icons.analytics_outlined,
                              label: 'Mis Reportes',
                              highlight: true,
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const ReportsPage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.list_alt_rounded,
                              label: 'Lista de Registros',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const LoglistPage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.inventory_2_outlined,
                              label: 'Mis Pedidos',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const OrdersPage());
                              },
                            ),
                            const SizedBox(height: 8),
                            _SectionLabel(text: 'Finanzas'),
                            _DrawerItem(
                              icon: Icons.toll_rounded,
                              label: 'Comprar ExCoin',
                              accentColor: ExFuturisticTheme.primary,
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const ExCoinWalletScreen());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Detalles de Pago',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const PaymentDetailPage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.payments_outlined,
                              label: 'Pagos',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const PaymentsPage());
                              },
                            ),
                            const SizedBox(height: 8),
                            _SectionLabel(text: 'Herramientas EX'),
                            _DrawerItem(
                              icon: Icons.auto_awesome_rounded,
                              label: 'IA Marketing Center',
                              accentColor: ExFuturisticTheme.primary,
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const IAMarketingScreen());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.school_outlined,
                              label: 'Academia EX',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const AcademyScreen());
                              },
                            ),
                            const SizedBox(height: 8),
                            _SectionLabel(text: 'Sistema'),
                            _DrawerItem(
                              icon: Icons.storefront_outlined,
                              label: 'Tienda',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const StorePage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.workspace_premium_outlined,
                              label: 'Beneficios',
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const BenefitsPageV2());
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
                            _DrawerItem(
                              icon: Icons.verified_user_outlined,
                              label: 'Solicitar Check Azul',
                              accentColor: ExFuturisticTheme.primary,
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => const AccountVerificationScreen());
                              },
                            ),
                            const SizedBox(height: 8),
                            _SectionLabel(text: 'Membresía'),
                            _DrawerItem(
                              icon: Icons.shopping_cart_outlined,
                              label: 'Comprar membresía',
                              onTap: () {
                                _ensureMembershipController(
                                    dashboardController);
                                Navigator.of(context).pop();
                                Get.to(() => const MembershipBuyPage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.history_rounded,
                              label: 'Historial de compras',
                              onTap: () {
                                _ensureMembershipController(
                                    dashboardController);
                                Navigator.of(context).pop();
                                Get.to(() => const MembershipHistoryPage());
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.refresh_rounded,
                              label: 'Restablecer Sugerencias IA',
                              onTap: () async {
                                Get.back();
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('hide_ai_box_forever');
                                Get.snackbar(
                                  'Sugerencias restablecidas',
                                  'Las sugerencias de IA volverán a mostrarse.',
                                  backgroundColor: Colors.black87,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
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
                        borderColor:
                            ExFuturisticTheme.danger.withValues(alpha: 0.18),
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
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Versión 1.3.0',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
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
    this.highlight = false,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Color tone =
        accentColor ?? (highlight ? ExFuturisticTheme.primary : Colors.white);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExGlassCard(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        borderColor: highlight
            ? ExFuturisticTheme.primary.withValues(alpha: 0.28)
            : null,
        glowColor: highlight ? ExFuturisticTheme.primary : null,
        gradient: highlight
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  ExFuturisticTheme.primary.withValues(alpha: 0.20),
                  Colors.white.withValues(alpha: 0.03),
                ],
              )
            : null,
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: tone.withValues(alpha: highlight ? 0.16 : 0.08),
              ),
              child: Icon(icon, color: tone, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: highlight ? ExFuturisticTheme.primarySoft : tone,
                  fontSize: 16,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Icon(
              highlight ? Icons.circle : Icons.chevron_right_rounded,
              size: highlight ? 10 : 24,
              color: highlight ? ExFuturisticTheme.primarySoft : Colors.white30,
            ),
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
              ? ExRemoteImage(
                  imageUrl: avatarUrl!,
                  fit: BoxFit.cover,
                  fallback: _fallback(initials),
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

void _ensureMembershipController(DashboardController dashboardController) {
  if (!Get.isRegistered<MembershipController>()) {
    Get.put(
      MembershipController(preferences: dashboardController.preferences),
      permanent: true,
    );
  }
}
