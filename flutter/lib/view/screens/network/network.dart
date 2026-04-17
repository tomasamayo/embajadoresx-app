import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/dashboard_controller.dart';
import '../../../controller/network_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/text.dart';
import '../../base/custom_app_bar.dart';
import '../dashboard/components/menu.dart';
import '../login/login.dart';
import 'network_listView.dart';
import 'network_shimmer_widget.dart';
import '../../../utils/preference.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    Get.find<NetworkController>().getNetworkData();
    Get.find<DashboardController>().getDashboardData();
    
    // TAREA: Configuración de animación palpitante (v1.2.9)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    super.initState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NetworkController>(builder: (bannerAndLinksController) {
      if (bannerAndLinksController.isLoading ||
          bannerAndLinksController.isNetworkLoading) {
        return NetworkShimmerWidget(
          controller: bannerAndLinksController,
        );
      } 
      
      // REQUERIMIENTO V1.2.4: Manejo de Error y Datos Nulos (Blindaje)
      if (bannerAndLinksController.networkData == null || !bannerAndLinksController.networkData!.status) {
        return Scaffold(
          backgroundColor: AppColor.dashboardBgColor,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.signal_wifi_off, color: Colors.redAccent, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    "Error de Conexión o Sesión Expirada",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No pudimos cargar los datos de tu red. Por favor, reintenta o cierra sesión para refrescar tu acceso.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  // TAREA 2: ARREGLAR OVERFLOW VISUAL (Cambiado Row a Column)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => bannerAndLinksController.getNetworkData(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            "🔄 REINTENTAR AHORA",
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF88),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => SharedPreference.logOut().then((_) => Get.offAll(() => const LoginPage())),
                          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                          label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white70)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      var dashModel = bannerAndLinksController.networkData!;
        return Scaffold(
          drawer: const Drawer(
            child: MenuPage(),
          ),
          backgroundColor: AppColor.dashboardBgColor,
          body: Stack(
            children: [
              // 1. Gradient Background
              Positioned(
                top: -250,
                left: -150,
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        AppColor.appPrimary.withOpacity(0.4),
                        AppColor.appPrimary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // 2. Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Header (Limpiado, solo título y menú)
                    _buildHeader(context, bannerAndLinksController),
                    
                    // --- NUEVA BARRA DE ESTADÍSTICAS ---
                    GetBuilder<DashboardController>(
                      builder: (dash) {
                        final totals = dash.dashboardData?.data.userTotals;
                        final referTotal = dash.dashboardData?.data.referTotal;

                        return Padding( 
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
                          child: Row( 
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            crossAxisAlignment: CrossAxisAlignment.center, 
                            children: [ 
                              // --- IZQUIERDA: Ganancias Mes --- 
                              Column( 
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                children: [ 
                                  const Text("GANANCIAS MES", style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1, fontFamily: 'Poppins')), 
                                  Row( 
                                    children: [ 
                                      const Icon(Icons.trending_up, color: Color(0xFF00FF88), size: 14), 
                                      const SizedBox(width: 4), 
                                      Text( 
                                        referTotal?.totalProductSale.amounts != null 
                                            ? "\$${referTotal!.totalProductSale.amounts}" 
                                            : "\$0.00",
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'), 
                                      ), 
                                    ], 
                                  ), 
                                ], 
                              ), 
                        
                              // --- CENTRO: Rango Actual --- 
                              Obx(() {
                                // REQUERIMIENTO V1.2.5: Rango dinámico desde la variable observable del controlador
                                final String rankName = bannerAndLinksController.networkData?.data.currentRankName ?? 'AFILIADO';
                                return Container( 
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
                                  decoration: BoxDecoration( 
                                    color: const Color(0xFF00FF88).withOpacity(0.2), // Fondo translúcido neón 
                                    borderRadius: BorderRadius.circular(15), 
                                    border: Border.all(color: const Color(0xFF00FF88)), // Borde neón 
                                  ), 
                                  child: Text(
                                    rankName.toUpperCase(), 
                                    style: const TextStyle(
                                      color: Color(0xFF00FF88), 
                                      fontSize: 10, 
                                      fontWeight: FontWeight.bold, 
                                      fontFamily: 'Poppins',
                                      letterSpacing: 0.5,
                                    ),
                                  ), 
                                );
                              }), 
                        
                              // --- DERECHA: Afiliados Mes --- 
                              Column( 
                                crossAxisAlignment: CrossAxisAlignment.end, 
                                children: [ 
                                  const Text("AFILIADOS MES", style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1, fontFamily: 'Poppins')), 
                                  Row( 
                                    children: [ 
                                      Text( 
                                        "${dashModel.data.referredUsersTree.length}",
                                        style: const TextStyle(color: Color(0xFF00FF88), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'), 
                                      ), 
                                      const SizedBox(width: 4), 
                                      const Icon(Icons.person_add, color: Color(0xFF00FF88), size: 14), 
                                    ], 
                                  ), 
                                ], 
                              ), 
                            ], 
                          ), 
                        );
                      }
                    ),


                    // 1. El Árbol (Ocupa el espacio disponible)
                    Expanded(
                      child: NetworkListView(
                        controller: bannerAndLinksController,
                      ),
                    ),

                    // 2. El Footer de Estadísticas (Fijado abajo)
                    GetBuilder<DashboardController>(
                      builder: (dash) {
                        final totals = dash.dashboardData?.data.userTotals;
                        final affiliatesCount = dash.dashboardData?.data.referTotal.totalGaneralClick.totalClicks ?? "0"; // Ejemplo, ajustar según campo real
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0B0B0F),
                            border: Border(top: BorderSide(color: Colors.white10)),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildBottomStat("Afiliados", dashModel.data.referredUsersTree.length.toString()),
                                _buildBottomStat("Volumen", "\$${totals?.saleLocalstoreTotal ?? '0.00'}"),
                                _buildBottomStat("Clics", totals?.totalClicksCount.toString() ?? "0", icon: Icons.touch_app, iconColor: const Color(0xFF00FF88)),
                                _buildBottomStat("Ventas", totals?.saleLocalstoreCount.toString() ?? "0"),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    });
  }

  void _showNetworkInfoModal(BuildContext context, NetworkController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF161B22), // TAREA: Dark Mode (v1.2.9)
        content: Column(
          mainAxisSize: MainAxisSize.min, // Modal compacto
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF00FF88), size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              "Información de Red",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            // TAREA: Scrollable Content para texto largo (v1.2.9)
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    controller.networkData?.data.networkInfoText?.replaceAll('\\n', '\n').trim() ?? 
                    "Cargando información detallada de niveles y comisiones...",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins', height: 1.6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF88),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: const Color(0xFF00FF88).withOpacity(0.3),
                ),
                child: const Text("ENTENDIDO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStat(String title, String value, {IconData? icon, Color? iconColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? AppColor.appPrimary, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 8,
            letterSpacing: 0.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, NetworkController bannerAndLinksController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.hub, color: AppColor.appPrimary, size: 24),
              const SizedBox(height: 4),
              const Text(
                "MI RED",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              // v1.3.1: Contador Global de Embajadores
              const SizedBox(height: 2),
              Obx(() => Text(
                "Comunidad: [${bannerAndLinksController.totalUsers.value}] EX",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              )),
            ],
          ),
          // TAREA: Botón Palpitante Informativo (v1.2.9)
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.25).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.6, end: 1.0).animate(
                CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
              ),
              child: InkWell(
                onTap: () => _showNetworkInfoModal(context, bannerAndLinksController),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.help_outline, color: Color(0xFF00FF88)),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
