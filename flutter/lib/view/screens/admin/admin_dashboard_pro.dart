import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/admin_controller.dart';
import 'package:animate_do/animate_do.dart';

class AdminDashboardProScreen extends StatefulWidget {
  const AdminDashboardProScreen({super.key});

  @override
  State<AdminDashboardProScreen> createState() => _AdminDashboardProScreenState();
}

class _AdminDashboardProScreenState extends State<AdminDashboardProScreen> {
  final AdminController controller = Get.put(AdminController());

  static const Color _neon = Color(0xFF00FF88);
  static const Color _dark = Color(0xFF0A0F0D);
  static const Color _card = Color(0xFF111916);
  static const Color _cardBorder = Color(0xFF1E2D25);

  @override
  void initState() {
    super.initState();
    controller.getAdminDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050905),
              Color(0xFF0A1A10),
              Color(0xFF0F2318),
              Color(0xFF071208),
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingDashboard.value) {
                    return _buildLoading();
                  }
                  final data = controller.adminDashboard.value;
                  if (data == null) {
                    return _buildNoData();
                  }
                  return _buildContent(data);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 16),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "DASHBOARD GLOBAL",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _neon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _neon.withOpacity(0.2)),
            ),
            child: const Icon(Icons.analytics_outlined, color: _neon, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              color: _neon,
              backgroundColor: _neon.withOpacity(0.15),
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text("Cargando datos del sistema...",
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined, color: Colors.white.withOpacity(0.15), size: 56),
          const SizedBox(height: 12),
          Text("Sin datos disponibles",
            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildContent(dynamic data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Crecimiento ──
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: _sectionLabel("📈  CRECIMIENTO SEMANAL"),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FadeInLeft(
                  duration: const Duration(milliseconds: 500),
                  child: _growthCard(
                    "Balance",
                    data.balanceGrowth,
                    Icons.account_balance_outlined,
                    const Color(0xFF00FF88),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FadeInRight(
                  duration: const Duration(milliseconds: 500),
                  child: _growthCard(
                    "Clicks",
                    data.clicksGrowth,
                    Icons.ads_click_outlined,
                    const Color(0xFF40E0FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Billetera Real ──
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: _sectionLabel("💳  BILLETERA REAL"),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 150),
            child: _walletCard(
              "Dinero Congelado",
              "On Hold",
              data.onHold,
              Icons.hourglass_top_rounded,
              Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 220),
            child: _walletCard(
              "Por Pagar",
              "Unpaid",
              data.unpaid,
              Icons.payments_outlined,
              const Color(0xFFFF5252),
            ),
          ),
          const SizedBox(height: 32),

          // ── Fuentes de Ingreso ──
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 200),
            child: _sectionLabel("💰  FUENTES DE INGRESO"),
          ),
          const SizedBox(height: 12),
          ...[
            ["Local Store", Icons.store_outlined, data.incomeSources['local_store'] ?? 0.0],
            ["Integraciones Externas", Icons.link_outlined, data.incomeSources['external_integrations'] ?? 0.0],
            ["Vendor Pay", Icons.handshake_outlined, data.incomeSources['vendor_pay'] ?? 0.0],
          ].asMap().entries.map((e) => FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: Duration(milliseconds: 250 + (e.key * 60)),
            child: _sourceItem(e.value[0] as String, e.value[1] as IconData, e.value[2] as double),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.45),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _growthCard(String label, double value, IconData icon, Color accent) {
    final bool isPositive = value >= 0;
    final Color valueColor = isPositive ? accent : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.04), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 15),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%",
            style: TextStyle(
              color: valueColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: valueColor.withOpacity(0.7), size: 13),
              const SizedBox(width: 4),
              Text(isPositive ? "En alza" : "En baja",
                style: TextStyle(color: valueColor.withOpacity(0.7), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletCard(String title, String subtitle, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text("USD", style: TextStyle(color: color.withOpacity(0.5), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sourceItem(String label, IconData icon, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _neon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _neon.withOpacity(0.7), size: 15),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(color: _neon, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

}
