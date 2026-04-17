import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:affiliatepro_mobile/controller/coinx/coinx_controller.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:affiliatepro_mobile/controller/store_controller.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/store/store_page.dart';
import 'package:affiliatepro_mobile/view/screens/slots/slots_screen.dart';

class ExCoinWalletScreen extends StatefulWidget {
  const ExCoinWalletScreen({super.key});

  @override
  State<ExCoinWalletScreen> createState() => _ExCoinWalletScreenState();
}

class _ExCoinWalletScreenState extends State<ExCoinWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExCoinController controller = Get.put(ExCoinController(preferences: Get.find<DashboardController>().preferences));

  @override
  void initState() {
    super.initState();
    print('📱 [UI] Ingreso a ExCoinWalletScreen');
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.onTabChanged(_tabController.index);
        setState(() {}); // Forzar rebuild para cambiar el contenido de la pestaña
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1A10), // Verde súper oscuro
              Colors.black,      // Negro
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.excoinBalance.value == 0.0) {
                    return _buildSkeletonLoader();
                  }
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        _buildPremiumBalanceCard(),
                        const SizedBox(height: 24),
                        _buildSegmentedControl(),
                        // Contenido de las pestañas integrado manualmente para scroll único
                        _buildTabContent(),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Billetera ExCoin",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 18),
            ),
          ),
          const SizedBox(width: 48), // Compensación para centrar
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(height: 160, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24))),
            const SizedBox(height: 24),
            Container(height: 50, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 24),
            Expanded(child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)))),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBalanceCard() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1D1B),
              Color(0xFF0F1210),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.03),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: const Color(0xFF00FF88).withOpacity(0.5), size: 14),
                const SizedBox(width: 6),
                Text(
                  "SALDO PROTEGIDO",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.toll, color: Color(0xFFFFD700), size: 38), // Icono moneda dorada premium
                const SizedBox(width: 14),
                Obx(() => FadeIn(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    '${controller.excoinBalance.value.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                )),
                const SizedBox(width: 8),
                const Text(
                  "ExCoin",
                  style: TextStyle(color: Color(0xFF00FF88), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 🎰 BOTÓN DE ACCESO A SLOTS (REQUERIMIENTO V1.9.0)
            InkWell(
              onTap: () => _handleSlotsNavigation(),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFF00FF88), size: 14),
                    const SizedBox(width: 8),
                    const Text(
                      "¿Necesitas ExCoin? Juega aquí",
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// LÓGICA DE NAVEGACIÓN A CASINO NATIVO (v2.0.0)
  void _handleSlotsNavigation() {
    print("🎰 [SLOTS] Navegando a Casino Nativo...");
    Get.to(() => const SlotsScreen());
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D1B).withOpacity(0.8), // Gris muy oscuro premium
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)), // Borde verde sutil más visible
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "¿Qué es ExCoin?",
            style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Obx(() => Text(
            controller.infoText.value,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          )),
          const SizedBox(height: 16),
          _buildInfoRow("Pagos instantáneos"),
          const SizedBox(height: 8),
          _buildInfoRow("Sin comisiones"),
          const SizedBox(height: 8),
          _buildInfoRow("Ofertas exclusivas"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF00FF88), size: 16),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // TAREA 3: TARJETA INFORMATIVA NUEVA PARA CANJEAR
  Widget _buildRedeemInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D1B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Canjea tu Saldo Disponible",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "Puedes convertir tus ganancias acumuladas en ExCoin de forma instantánea para usarlas en la tienda.",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          // Highlight: Tasa de Canje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF00FF88), size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => Text(
                    "Tasa de canje: ${controller.exchangeRate.value}",
                    style: const TextStyle(color: Color(0xFF00FF88), fontSize: 12, fontWeight: FontWeight.w600),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 58, // TAREA 2: Ajuste de altura para tabs "gorditos" premium
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D1B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF00FF88),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          dividerColor: Colors.transparent, // TAREA 4 (v31.0.0): Línea blanca invisible forzada
          dividerHeight: 0, 
          indicatorColor: Colors.transparent, 
          indicatorSize: TabBarIndicatorSize.tab, // Asegurar que el indicador cubra toda la pestaña
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Poppins'),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0),
          tabs: [
            Tab(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // TAREA 2: Padding Premium
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("COMPRAR EXCOIN"),
                ),
              ),
            ),
            Tab(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // TAREA 2: Padding Premium
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("CANJEAR SALDO"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return _tabController.index == 0 
      ? _buildBuyContent() 
      : _buildRedeemContent();
  }

  Widget _buildBuyContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TAREA 2: SECCIÓN INFORMATIVA EXCLUSIVA DE COMPRAR
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildInfoSection(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                "¿Cuánto quieres comprar?",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
              ),
              const Spacer(),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.exchangeRate.value,
                  style: const TextStyle(color: Color(0xFF00FF88), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.buyAmount,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1A1D1B),
              hintText: "Cantidad de ExCoin",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 16),
              prefixIcon: const Icon(Icons.stars, color: Color(0xFF00FF88), size: 22),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Container(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              "Inversión estimada: \$${controller.usdToPay.value} USD",
              style: TextStyle(color: const Color(0xFF00FF88).withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          )),
          const SizedBox(height: 32),
          Row(
            children: [
              const Text(
                "Selecciona una pasarela",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
              ),
              const Spacer(),
              Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.3), size: 14),
              const SizedBox(width: 4),
              Text("PAGO SEGURO", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: controller.paymentGateways.length,
            itemBuilder: (context, index) {
              final gw = controller.paymentGateways[index];
              return _buildModernGatewayCard(gw);
            },
          )),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF88).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                final response = await controller.confirmBuyExCoin();
                if (response != null && response['status'] == true) {
                  _openWebView(response['confirm_html']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 0,
              ),
              child: const Text(
                "Confirmar Compra",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernGatewayCard(Map<String, dynamic> gw) {
    bool isSelected = controller.selectedGateway.value == gw['id'].toString();
    return GestureDetector(
      onTap: () => controller.onGatewaySelected(gw['id'].toString(), gw['title'] ?? ""),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00FF88).withOpacity(0.08) : const Color(0xFF1A1D1B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF00FF88) : Colors.white.withOpacity(0.05),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF00FF88) : Colors.white.withOpacity(0.2),
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                gw['title']?.toUpperCase() ?? "PAGO",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          // TAREA 3: TARJETA INFORMATIVA EXCLUSIVA DE CANJEAR
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildRedeemInfoCard(),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.03),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    "GANANCIAS DISPONIBLES",
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => FadeIn(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      "\$${controller.availableEarnings.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Color(0xFF00FF88),
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )),
                  Text(
                    "DÓLARES (USD)",
                    style: TextStyle(color: const Color(0xFF00FF88).withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Monto a canjear",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: TextField(
              controller: controller.redeemAmount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1D1B),
                hintText: "0.00",
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF00FF88)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Obx(() => Text(
              "Recibirás aproximadamente: ${controller.excoinToReceive.value} ExCoin",
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            )),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildWarningBox(),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => controller.redeemEarningsForExCoin(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF88),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 0,
                ),
                child: const Text(
                  "Canjear por ExCoin",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F00), // TAREA 4: Fondo ámbar muy oscuro
        borderRadius: BorderRadius.circular(12), // TAREA 4: Border radius 12
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)), // Borde sutil ámbar neón
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 24), // TAREA 4: Icono ámbar brilloso
          const SizedBox(width: 14),
          Expanded(
            child: Obx(() => Text(
              controller.warningText.value, // TAREA 4: Texto dinámico
              style: TextStyle(
                color: Colors.orangeAccent.withOpacity(0.8), // TAREA 4: Color ámbar claro
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            )),
          ),
        ],
      ),
    );
  }

  void _openWebView(String htmlContent) {
    if (kIsWeb) {
      Get.snackbar(
        "Pestaña de Pago", 
        "El procesamiento de pagos vía WebView solo está disponible en la App móvil nativa.", 
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      print("🛡️ [WEB/NATIVE FIX] Compatibilidad kIsWeb aplicada. Abortando WebView en navegador.");
      return;
    }

    // 🛡️ [WEB/NATIVE FIX] Compatibilidad kIsWeb aplicada. dart:io protegido.
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        print("🛡️ [WEBVIEW FIX] Plataforma Android inicializada para el WebView de Pagos. Previniendo pantalla roja.");
      }
    }

    Get.to(() => Scaffold(
      backgroundColor: const Color(0xFF0A0C0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1210),
        elevation: 0,
        title: const Text("Procesando Pago", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            controller.onWebViewClosed("manual_close");
            Get.back();
          },
        ),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                print('🌐 [WEBVIEW] Navegando a: $url');
                if (url.contains("status=success")) {
                  controller.onWebViewClosed("success");
                  Get.back();
                  Get.snackbar(
                    "¡Éxito!", 
                    "Tu compra de ExCoin ha sido procesada. 🚀", 
                    backgroundColor: const Color(0xFF00FF88), 
                    colorText: Colors.black,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(20),
                    borderRadius: 15,
                  );
                  controller.fetchExCoinData();
                } else if (url.contains("status=failed") || url.contains("status=cancel")) {
                  controller.onWebViewClosed("failed");
                  Get.back();
                  Get.snackbar(
                    "Pago Cancelado", 
                    "No se pudo completar la compra de ExCoin.", 
                    backgroundColor: Colors.redAccent, 
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(20),
                    borderRadius: 15,
                  );
                }
              },
            ),
          )
          ..loadHtmlString(htmlContent),
      ),
    ));
  }
}
