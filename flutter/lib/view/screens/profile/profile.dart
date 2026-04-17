import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/view/screens/profile/profile_card.dart';
import 'package:affiliatepro_mobile/view/screens/profile/shimmer_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<DashboardController>();
      controller.getUser();
      controller.getDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardController) {
      if (dashboardController.isLoading ||
          dashboardController.isDashboardDataLoading) {
        return ProfielShimmerWidget(
          controller: dashboardController,
        );
      } else {
        final bool hasUser = dashboardController.loginModel?.data != null;
        final bool hasDashboard = dashboardController.dashboardData != null;

        return Scaffold(
          backgroundColor: AppColor.dashboardBgColor,
          extendBodyBehindAppBar:
              true, // REQUERIMIENTO V1.2.3: Fondo hasta arriba del todo
          appBar: AppBar(
            backgroundColor:
                Colors.transparent, // REQUERIMIENTO V1.2.3: AppBar invisible
            elevation: 0,
            scrolledUnderElevation:
                0, // REQUERIMIENTO V1.2.3: Evitar cambio de color al scroll
            leading: const BackButton(
                color: Color(
                    0xFF00FF88)), // REQUERIMIENTO V1.2.3: Icono Verde Neón
            title: const Text(
              "Configuración de Perfil",
              style: TextStyle(
                color: Color(
                    0xFF00FF88), // REQUERIMIENTO V1.2.3: Título Verde Neón
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            centerTitle: true,
          ),
          body: hasUser || hasDashboard
              ? ProfilePageProfile(
                  controller: dashboardController,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.person_off_outlined,
                          color: Color(0xFF00FF88),
                          size: 54,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se pudo cargar el perfil todavía.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Reintenta la sincronización para volver a cargar los datos del usuario.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await dashboardController.getUser();
                            await dashboardController.getDashboardData();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF88),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      }
    });
  }
}
