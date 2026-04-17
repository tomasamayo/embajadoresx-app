import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/dashboard/components/menu.dart';
import 'package:affiliatepro_mobile/view/screens/dashboard/components/ai_marketing_sheet.dart';
import '../../../controller/bannerAndLinks_controller.dart';
import '../../base/custom_app_bar.dart';
import '../login/login.dart';
import 'components/bannerAndLinks_listView.dart';
import 'components/banner_shimmer_widget.dart';
import '../../../utils/preference.dart';

class BannerAndLinks extends StatefulWidget {
  const BannerAndLinks({super.key});

  @override
  State<BannerAndLinks> createState() => _BannerAndLinksState();
}

class _BannerAndLinksState extends State<BannerAndLinks> {
  @override
  void initState() {
    final controller = Get.find<BannerAndLinksController>();
    
    // REQUERIMIENTO V1.6.0: Detectar si venimos de una notificación
    if (controller.forceGlobalDeepLink) {
      controller.currentMarketView = "all"; 
    } else {
      controller.currentMarketView = "favorites"; 
    }
    
    controller.getBannerAndLinksData();
    controller.getFullCatalogForCache(); 
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<BannerAndLinksController>(
        builder: (bannerAndLinksController) {
      if (bannerAndLinksController.isLoading ||
          bannerAndLinksController.isBannerAndLinksLoading) {
        return BannerShimmerWidget(
          controller: bannerAndLinksController,
        );
      } 
      
      // REQUERIMIENTO V1.2.4: Manejo de Error y Datos Nulos (Blindaje)
      if (bannerAndLinksController.bannerAndLinksData == null || !bannerAndLinksController.bannerAndLinksData!.status) {
        return Scaffold(
          backgroundColor: AppColor.dashboardBgColor,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link_off, color: Colors.redAccent, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    "Error de Conexión o Sesión Expirada",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No pudimos cargar tus banners y enlaces. Por favor, reintenta o cierra sesión para refrescar tu acceso.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => bannerAndLinksController.getBannerAndLinksData(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            "🔄 REINTENTAR AHORA",
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF88),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => SharedPreference.logOut().then((_) => Get.offAll(() => const LoginPage())),
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                        label: const Text("Cerrar Sesión y Salir", style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      var dashModel = bannerAndLinksController.bannerAndLinksData!;
        return Scaffold(
          drawer: const Drawer(
            child: MenuPage(),
          ),
          backgroundColor: AppColor.dashboardBgColor,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => AIMarketingSheet(
                  productosDisponibles: bannerAndLinksController.allProducts.isNotEmpty 
                      ? bannerAndLinksController.allProducts 
                      : (bannerAndLinksController.bannerAndLinksData?.data ?? []),
                ),
              );
            },
            backgroundColor: const Color(0xFF00FF88),
            foregroundColor: Colors.black,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.auto_awesome_rounded, size: 28),
          ),
          body: Stack(
            children: [
              // Gradient Background
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
              
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.link, color: AppColor.appPrimary, size: 24),
                              const SizedBox(height: 4),
                              const Text(
                                "Banners y Enlaces",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                "TUS FAVORITOS Y PRODUCTOS CREADOS",
                                style: TextStyle(
                                  color: AppColor.appPrimary.withOpacity(0.8),
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          Builder(
                            builder: (context) => InkWell(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: const Icon(Icons.menu, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Summary Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1210),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColor.appPrimary.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.appPrimary.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TOTAL RECURSOS",
                                style: TextStyle(
                                  color: AppColor.appPrimary.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bannerAndLinksController.currentMarketView == "favorites" 
                                  ? "${dashModel.data.length} Enlaces"
                                  : (bannerAndLinksController.currentMarketView == "hot" ? "🔥 Top Hot" : "🌐 Global"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Botón de Filtro (Icono de Embudo)
                              InkWell(
                                onTap: () {
                                  _showFilterDialog(context, bannerAndLinksController);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (bannerAndLinksController.selectedCategoryId != null || 
                                           bannerAndLinksController.selectedMarketCategoryId != null)
                                        ? AppColor.appPrimary 
                                        : AppColor.appPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColor.appPrimary.withOpacity(0.2)),
                                  ),
                                  child: Icon(
                                    Icons.filter_list_rounded,
                                    color: (bannerAndLinksController.selectedCategoryId != null || 
                                           bannerAndLinksController.selectedMarketCategoryId != null)
                                        ? Colors.black 
                                        : AppColor.appPrimary,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Botón de Vista (Cuadrícula/Lista)
                              InkWell(
                                onTap: () => bannerAndLinksController.toggleView(),
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: bannerAndLinksController.isGridView 
                                        ? AppColor.appPrimary 
                                        : AppColor.appPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    bannerAndLinksController.isGridView 
                                        ? Icons.list_rounded 
                                        : Icons.grid_view_rounded,
                                    color: bannerAndLinksController.isGridView 
                                        ? Colors.black 
                                        : AppColor.appPrimary,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            BannerAndLinksListView(
                              controller: bannerAndLinksController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    });
  }

  void _showFilterDialog(BuildContext context, BannerAndLinksController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F1210),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filtrar por Categoría",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 🟢 MIS FAVORITOS (Solo para Usuarios Normales)
              if (!controller.isAdmin) ...[
                _buildFilterOption(
                  context, 
                  "Mis Favoritos", 
                  "favorites", 
                  controller.currentMarketView == "favorites",
                  () => controller.setMarketView("favorites"),
                  icon: Icons.star_rounded,
                  activeColor: const Color(0xFF00FF88),
                ),
                const SizedBox(height: 12),
              ],
              
              // 🌐 TODOS LOS PRODUCTOS
              _buildFilterOption(
                context, 
                "Todos los Productos", 
                "all", 
                controller.currentMarketView == "all",
                () => controller.setMarketView("all"),
                icon: Icons.public_rounded,
                activeColor: Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              
              // 🔥 PRODUCTOS CANDENTES
              _buildFilterOption(
                context, 
                "Productos Candentes", 
                "hot", 
                controller.currentMarketView == "hot",
                () => controller.setMarketView("hot"),
                icon: Icons.whatshot_rounded,
                activeColor: Colors.orangeAccent,
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Aplicar Filtros", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context, 
    String label, 
    String? id, 
    bool isSelected, 
    VoidCallback onTap,
    {IconData? icon, Color? activeColor}
  ) {
    return InkWell(
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? (activeColor?.withOpacity(0.1) ?? AppColor.appPrimary.withOpacity(0.1)) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? (activeColor ?? AppColor.appPrimary) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: isSelected ? (activeColor ?? AppColor.appPrimary) : Colors.white54, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? (activeColor ?? AppColor.appPrimary) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: (activeColor ?? AppColor.appPrimary), size: 20),
          ],
        ),
      ),
    );
  }
}
