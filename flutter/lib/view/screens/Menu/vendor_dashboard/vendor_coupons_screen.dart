import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controller/vendor_coupons_controller.dart';
import '../../../../model/vendor_coupon_model.dart';
import 'vendor_manage_coupon_screen.dart';

class VendorCouponsScreen extends StatefulWidget {
  const VendorCouponsScreen({super.key});

  @override
  State<VendorCouponsScreen> createState() => _VendorCouponsScreenState();
}

class _VendorCouponsScreenState extends State<VendorCouponsScreen> {
  late VendorCouponsController controller;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final prefs = await SharedPreferences.getInstance();
    controller = Get.put(VendorCouponsController(preferences: prefs));
    setState(() {
      _isControllerReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "CUPONES",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF001A0F)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.coupons.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
            }
            return RefreshIndicator(
              onRefresh: () => controller.getCoupons(),
              color: const Color(0xFF00FF88),
              backgroundColor: const Color(0xFF1A1A1A),
              child: controller.coupons.isEmpty ? _buildEmptyState() : _buildCouponsList(),
            );
          }),
        ),
      ),
      floatingActionButton: FadeInRight(
        duration: const Duration(milliseconds: 600),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Get.to(() => const VendorManageCouponScreen(), transition: Transition.rightToLeft);
              if (result == true) {
                controller.getCoupons();
              }
            },
            backgroundColor: const Color(0xFF00FF88),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: controller.coupons.length,
      itemBuilder: (context, index) {
        final coupon = controller.coupons[index];
        final bool isActive = coupon.status == "1";
        final bool isPercentage = coupon.type == "percentage";

        // TAREA 1: FUNCIÓN DE LIMPIEZA DINÁMICA (Regex)
        String cleanDiscount(String value) {
          try {
            double val = double.parse(value);
            return val.toString().replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
          } catch (e) {
            return value;
          }
        }

        final String cleanValue = cleanDiscount(coupon.discount.toString());

        return FadeInUp(
          duration: Duration(milliseconds: 400 + (index * 100)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF88).withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.confirmation_number, color: Color(0xFF00FF88), size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.code,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // TAREA 2: CONSTRUCCIÓN DINÁMICA DEL TEXTO
                        isPercentage ? "$cleanValue% OFF" : "\$$cleanValue OFF",
                        style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Usado: ${coupon.usesTotal} veces",
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF00FF88).withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isActive ? const Color(0xFF00FF88).withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(
                        isActive ? "ACTIVO" : "INACTIVO",
                        style: TextStyle(color: isActive ? const Color(0xFF00FF88) : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 20),
                          onPressed: () => Get.to(() => VendorManageCouponScreen(coupon: coupon)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _showDeleteConfirmation(coupon),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2)),
      ),
      child: Text(
        active ? "ACTIVO" : "INACTIVO",
        style: TextStyle(
          color: active ? Colors.greenAccent : Colors.redAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white38, size: 12),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showDeleteConfirmation(VendorCoupon coupon) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("ELIMINAR CUPÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("¿Estás seguro de eliminar el cupón '${coupon.code}'?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCoupon(coupon);
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1)),
              ),
              child: const Icon(Icons.confirmation_number_outlined, size: 80, color: Color(0xFF00FF88)),
            ),
            const SizedBox(height: 24),
            const Text(
              "Aún no tienes cupones de tienda.",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "¡Crea el primero ahora!",
              style: TextStyle(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
