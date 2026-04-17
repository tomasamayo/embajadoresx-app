import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_detail_screen.dart';
import 'vendor_products_screen.dart';
import 'vendor_coupons_screen.dart';
import 'vendor_orders_screen.dart';
import '../../../../controller/vendor_dashboard_controller.dart';
import '../../../../model/vendor_stats_model.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  // REQUERIMIENTO V1.2.5: Cambiamos 'late' por inicialización vía Get.find() para evitar LateInitializationError
  VendorDashboardController get controller => Get.find<VendorDashboardController>();
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final prefs = await SharedPreferences.getInstance();
    if (!Get.isRegistered<VendorDashboardController>()) {
      Get.put(VendorDashboardController(preferences: prefs));
    }
    if (mounted) {
      setState(() {
        _isControllerReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.vendorStats.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FF88)),
          );
        }

        final stats = controller.vendorStats.value?.data.stats;
        final recentOrders = controller.vendorStats.value?.data.recentOrders ?? [];

        return RefreshIndicator(
          onRefresh: () => controller.getVendorStats(),
          color: const Color(0xFF00FF88),
          backgroundColor: const Color(0xFF1A1A1A),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: const Text(
                      "Tienda",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 1. Shortcuts Horizontal
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildShortcutChip(
                            "Productos", 
                            Icons.inventory_2_outlined,
                            onTap: () => Get.to(() => const VendorProductsScreen(), transition: Transition.rightToLeft),
                          ),
                          _buildShortcutChip(
                            "Cupones", 
                            Icons.confirmation_number_outlined,
                            onTap: () => Get.to(() => const VendorCouponsScreen(), transition: Transition.rightToLeft),
                          ),
                          _buildShortcutChip(
                            "Pedidos", 
                            Icons.receipt_long,
                            onTap: () => Get.to(() => const VendorOrdersScreen(), transition: Transition.rightToLeft),
                          ),
                          _buildShortcutChip("Más opciones...", Icons.add_circle_outline),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. Stats Grid 2x2
                  _buildStatsGrid(stats),
                  const SizedBox(height: 35),

                  // 3. Recent Orders Header
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pedidos Recientes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => const VendorOrdersScreen(), transition: Transition.rightToLeft),
                          child: const Text(
                            "Ver todo",
                            style: TextStyle(color: Color(0xFF008F58), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 4. Recent Orders List
                  _buildRecentOrdersList(recentOrders),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShortcutChip(String label, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF008F58), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(VendorStatsSummary? stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard("VENTA TOTAL", "\$${stats?.totalSales ?? '0.00'}", Icons.attach_money, [const Color(0xFF1A1A1A), const Color(0xFF0A2A1A)]),
        _buildStatCard("CLICS", stats?.totalClicks ?? '0', Icons.mouse_outlined, [const Color(0xFF1A1A1A), const Color(0xFF1A1A1A)]),
        _buildStatCard("PRODUCTOS", stats?.totalProducts ?? '0', Icons.inventory_2_outlined, [const Color(0xFF1A1A1A), const Color(0xFF1A1A1A)]),
        _buildStatCard("CUPONES", stats?.totalCoupons ?? '0', Icons.confirmation_number_outlined, [const Color(0xFF1A1A1A), const Color(0xFF0A2A1A)]),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, List<Color> colors) {
    // TAREA 1: CAMBIO DE COLOR DE BALANCE (v1.5.0) - Solo para el primer card (VENTA TOTAL)
    final bool isTotalSales = label.toUpperCase() == "VENTA TOTAL";

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF00FF88).withOpacity(0.7), size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isTotalSales ? const Color(0xFF00CD7E) : Colors.white, // TAREA 1: Verde Esmeralda Vibrante (v1.5.2) - Clonado de botón Configurar
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    shadows: const [], // TAREA 1: Sin resplandor para máxima nitidez
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList(List<VendorRecentOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No hay pedidos recientes",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontFamily: 'Poppins'),
          ),
        ),
      );
    }
    return Column(
      children: orders.map((order) {
        Color statusColor = const Color(0xFF00FF88);
        if (order.statusText.toLowerCase().contains('pend') || order.statusText.toLowerCase().contains('proceso')) {
          statusColor = const Color(0xFFFFB800);
        } else if (order.statusText.toLowerCase().contains('canc') || order.statusText.toLowerCase().contains('fall')) {
          statusColor = const Color(0xFFFF5252);
        }

        return _buildOrderCard(
          order.id, // Real Database ID for navigation
          "#${order.orderId}", // Visible ID
          order.createdAt, 
          "\$${order.totalAmount}", 
          order.paymentMethod, 
          order.statusText, 
          statusColor
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard(String dbId, String displayId, String date, String price, String method, String status, Color statusColor) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(displayId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Get.to(() => OrderDetailScreen(orderId: dbId), transition: Transition.rightToLeft),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.visibility_outlined, color: const Color(0xFF00FF88).withOpacity(0.6), size: 16),
                      ),
                    ),
                  ],
                ),
                Text(date, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(price, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    const SizedBox(height: 4),
                    Text(method, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

