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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<DashboardController>(builder: (dashboardController) {
      if (dashboardController.isLoading ||
          dashboardController.isDashboardDataLoading) {
        return ProfielShimmerWidget(
          controller: dashboardController,
        );
      } else {
        var dashModel = dashboardController.dashboardData;
        if (dashModel == null) return const SizedBox.shrink(); // v4.0.0: Blindaje anti-null
        return Scaffold(
          backgroundColor: AppColor.dashboardBgColor,
          extendBodyBehindAppBar: true, // REQUERIMIENTO V1.2.3: Fondo hasta arriba del todo
          appBar: AppBar(
            backgroundColor: Colors.transparent, // REQUERIMIENTO V1.2.3: AppBar invisible
            elevation: 0,
            scrolledUnderElevation: 0, // REQUERIMIENTO V1.2.3: Evitar cambio de color al scroll
            leading: const BackButton(color: Color(0xFF00FF88)), // REQUERIMIENTO V1.2.3: Icono Verde Neón
            title: const Text(
              "Configuración de Perfil",
              style: TextStyle(
                color: Color(0xFF00FF88), // REQUERIMIENTO V1.2.3: Título Verde Neón
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            centerTitle: true,
          ),
          body: ProfilePageProfile(
            controller: dashboardController,
          ),
        );
      }
    });
  }
}
