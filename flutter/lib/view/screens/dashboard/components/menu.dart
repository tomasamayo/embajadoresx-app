import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/controller/membership_controller.dart';
import 'package:affiliatepro_mobile/view/screens/notifications/notifications.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';

import '../../Menu/log_list/loglist.dart';
import '../../Menu/orders/orders.dart';
import '../../Menu/payment_details/paymentDetail.dart';
import '../../Menu/payments/payments.dart';
import '../../Menu/reports/reports.dart';
import '../../Menu/benefits/benefits.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/ia_marketing/ia_marketing_screen.dart';
import '../../Menu/vendor_dashboard/vendor_dashboard_screen.dart';
import '../../Menu/vendor_dashboard/vendor_products_screen.dart';
import '../../Menu/vendor_dashboard/vendor_coupons_screen.dart';
import '../../Menu/vendor_dashboard/vendor_orders_screen.dart';
import '../../Menu/vendor_dashboard/vendor_clients_screen.dart';
import '../../Menu/vendor_dashboard/vendor_store_settings_screen.dart';
import '../../Menu/store/store_page.dart';
import '../../membership/membership_buy.dart';
import '../../membership/membership_history.dart';
import '../../academy_screen.dart';
import '../../coinx/coinx_wallet_screen.dart';
import '../../admin/admin_dashboard_pro.dart';
import '../../admin/admin_global_network.dart';
import '../../admin/admin_complaints.dart';
import '../../admin/admin_wallet_screen.dart';
import '../verification/account_verification_screen.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TAREA 3: LOG DE RENDERIZADO
    print('🔘 [UI] Botón de Pedidos renderizado en el menú lateral.');
    
    final dashboardController = Get.find<DashboardController>();
    final user = dashboardController.loginModel?.data;

    return Container(
      color: const Color(0xFF0F1210), // Fondo estilo cripto
      child: SafeArea(
        child: Column(
          children: [
            // New Header with Profile Info integrated
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                                image: DecorationImage(
                                  image: NetworkImage(user?.profileAvatar ?? ""),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                            ),
                            Positioned(
                              bottom: -1,
                              right: -1,
                              child: Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F1210),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: AppColor.appPrimary,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() {
                            final currentUser = dashboardController.loginModel?.data;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${currentUser?.firstname ?? ''} ${currentUser?.lastname ?? ''}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (dashboardController.isVerified.value == 1) ...[
                                      const SizedBox(width: 5),
                                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                                    ],
                                  ],
                                ),
                                Builder(builder: (context) {
                                  String roleText = "MODO AFILIADO";
                                  Color roleColor = AppColor.appGrey;
                                  if (currentUser?.isAdmin == true) {
                                    roleText = "MODO ADMINISTRADOR";
                                    roleColor = const Color(0xFFFFD700);
                                  } else if (dashboardController.isVendorMode.value) {
                                    roleText = "MODO PROVEEDOR";
                                    roleColor = const Color(0xFF00FF88);
                                  }
                                  return Text(
                                    roleText,
                                    style: TextStyle(
                                      color: roleColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.4), size: 22),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                  // SECCIÓN ADMINISTRADOR (REQUERIMIENTO V1.2.9)
                  if (user?.isAdmin == true) ...[
                    _buildSectionTitle("GESTIÓN DE SISTEMA"),
                    _buildMenuItem(
                      context,
                      "Dashboard Global",
                      Icons.assessment_outlined,
                      const AdminDashboardProScreen(),
                      iconColor: const Color(0xFFFFD700),
                    ),
                    _buildMenuItem(
                      context,
                      "Árbol de Red Global",
                      Icons.account_tree_outlined,
                      const AdminGlobalNetworkScreen(),
                      iconColor: const Color(0xFFFFD700),
                    ),
                    _buildMenuItem(
                      context,
                      "Libro de Reclamaciones",
                      Icons.report_problem_outlined,
                      const AdminComplaintsScreen(),
                      iconColor: const Color(0xFFFFD700),
                    ),
                    _buildMenuItem(
                      context,
                      "Billetera Global",
                      Icons.account_balance_wallet_outlined,
                      const AdminWalletScreen(),
                      iconColor: const Color(0xFFFFD700),
                    ),
                    const SizedBox(height: 25),
                  ],

                  _buildSectionTitle("GESTIÓN"),
                  _buildMenuItem(
                        context,
                        "Mis Reportes",
                        FontAwesomeIcons.chartPie,
                        const ReportsPage(),
                        isSelected: true, // Ejemplo de seleccionado
                      ),
                      _buildMenuItem(
                        context,
                        "Lista de Registros",
                        FontAwesomeIcons.list,
                        const LoglistPage(),
                      ),
                      _buildMenuItem(
                        context,
                        "Mis Pedidos",
                        Icons.inventory_2_outlined,
                        const OrdersPage(),
                      ),

                      const SizedBox(height: 25),

                      // SECCIÓN TIENDA PROVEEDOR (RECONSTRUIDA V1.2.4)
                      Obx(() => dashboardController.isVendorMode.value 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("TIENDA PROVEEDOR"),
                              _buildMenuItem(
                                context,
                                "Panel de control",
                                Icons.dashboard_customize_outlined,
                                const VendorDashboardScreen(),
                                iconColor: const Color(0xFF00FF88),
                              ),
                              _buildMenuItem(
                                context,
                                "Productos",
                                Icons.inventory_2_outlined,
                                const VendorProductsScreen(),
                                iconColor: const Color(0xFF00FF88),
                              ),
                              _buildMenuItem(
                                context,
                                "Cupones de tienda",
                                Icons.confirmation_number_outlined,
                                const VendorCouponsScreen(),
                                iconColor: const Color(0xFF00FF88),
                              ),
                              _buildMenuItem(
                                context,
                                "Pedidos",
                                Icons.receipt_long,
                                const VendorOrdersScreen(),
                                iconColor: const Color(0xFF00FF88),
                              ),
                              _buildMenuItem(
                                context,
                                "Clientes",
                                Icons.people_outline,
                                const VendorClientsScreen(),
                                iconColor: const Color(0xFF00FF88),
                              ),
                              _buildMenuItem(
                                context,
                                "Configuración de Tienda",
                                Icons.storefront_outlined,
                                const VendorStoreSettingsScreen(),
                                iconColor: const Color(0xFF00FF88),
                              ),
                              const SizedBox(height: 25),
                            ],
                          )
                        : const SizedBox.shrink()
                      ),

                      _buildSectionTitle("FINANZAS"),
                      _buildMenuItem(
                        context,
                        "Comprar ExCoin",
                        Icons.toll,
                        const ExCoinWalletScreen(),
                        iconColor: const Color(0xFF00FF88),
                        textColor: Colors.white,
                      ),
                      _buildMenuItem(
                        context,
                        "Detalles de Pago",
                        Icons.account_balance_wallet_outlined,
                        const PaymentDetailPage(),
                      ),
                      _buildMenuItem(
                        context,
                        "Pagos",
                        Icons.monetization_on_outlined,
                        const PaymentsPage(),
                      ),

                      const SizedBox(height: 25),

                      _buildSectionTitle("HERRAMIENTAS EX"),
                      _buildMenuItem(
                        context,
                        "IA Marketing Center",
                        Icons.auto_awesome,
                        const IAMarketingScreen(),
                        iconColor: const Color(0xFF00FF88),
                        textColor: Colors.white,
                      ),
                      _buildMenuItem(
                        context,
                        "Academia EX",
                        Icons.school,
                        const AcademyScreen(),
                      ),


                      const SizedBox(height: 25),

                      _buildSectionTitle("SISTEMA"),
                      _buildMenuItem(
                        context,
                        "Tienda",
                        Icons.storefront_outlined,
                        const StorePage(),
                      ),
                      _buildMenuItem(
                        context,
                        "Beneficios",
                        Icons.emoji_events_outlined,
                        const BenefitsPage(),
                      ),
                      _buildMenuItem(
                        context,
                        "Notificaciones",
                        Icons.notifications_none_outlined,
                        const NotificationsPage(),
                      ),
                      _buildMenuItem(
                        context,
                        "Solicitar Check Azul",
                        Icons.verified_user_outlined,
                        const AccountVerificationScreen(),
                        iconColor: const Color(0xFF00FF88),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("MEMBRESÍA"),
                      _buildMenuItem(
                        context,
                        "Comprar membresía",
                        Icons.shopping_cart_outlined,
                        null,
                        onTap: () {
                          // Asegurar inyección del controlador antes de navegar
                          if (!Get.isRegistered<MembershipController>()) {
                            Get.put(MembershipController(preferences: dashboardController.preferences), permanent: true);
                          }
                          Get.to(() => const MembershipBuyPage());
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Historial de compras",
                        Icons.history,
                        null,
                        onTap: () {
                          // REQUERIMIENTO V18.4: Inyección del controlador antes de navegar
                          if (!Get.isRegistered<MembershipController>()) {
                            Get.put(MembershipController(preferences: dashboardController.preferences), permanent: true);
                          }
                          Get.to(() => const MembershipHistoryPage());
                        },
                      ),
                      
                      // Restablecer sugerencias IA
                      _buildMenuItem(
                        context,
                        "Restablecer Sugerencias IA",
                        Icons.refresh,
                        null,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('hide_ai_box_forever');
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Las sugerencias de IA han sido restablecidas.")),
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.all(20),
              child: ListTile(
                onTap: () => Get.find<MainController>().logOut(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.logout, color: Color(0xFFFF5252)),
                title: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),

            // App Version (Dinámica v1.3.0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  String version = snapshot.data?.version ?? "1.3.0";
                  if (snapshot.hasData) {
                    // Log solicitado una vez que tenemos data
                    print("📱 [UI] Texto de versión en Drawer actualizado correctamente: $version");
                  }
                  return Text(
                    'Versión $version',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6), 
                      fontSize: 11, 
                      fontFamily: 'Poppins'
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget? page, {
    bool isSelected = false,
    VoidCallback? onTap,
    bool replace = false,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColor.appPrimary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap ??
            () {
              Navigator.pop(context);
              if (page != null) {
                if (replace) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                }
              }
            },
        dense: true,
        leading: Icon(
          icon,
          color: iconColor ?? (isSelected ? AppColor.appPrimary : Colors.white.withOpacity(0.5)),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (isSelected ? AppColor.appPrimary : Colors.white.withOpacity(0.7)),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColor.appPrimary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
