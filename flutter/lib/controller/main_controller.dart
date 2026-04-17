import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/controller/login_controller.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/missions/missions_screen.dart';
import 'package:affiliatepro_mobile/view/screens/banner_links_v2/banner_links_page_v2.dart';
import 'package:affiliatepro_mobile/view/screens/dashboard_v2/dashboard_page_v2.dart';
import 'package:affiliatepro_mobile/view/screens/network_v2/network_page_v2.dart';
import 'package:affiliatepro_mobile/view/screens/ranking_v2/ranking_page_v2.dart';
import '../view/screens/login/login.dart';

class MainController extends GetxController {
  // v71.0.0: Llaves Globales para el App Tour (Accesibles desde cualquier pantalla)
  final GlobalKey perfilKey = GlobalKey();
  final GlobalKey saldoUSDKey = GlobalKey();
  final GlobalKey saldoExCoinKey = GlobalKey();
  final GlobalKey btnEnlacesKey = GlobalKey();
  final GlobalKey rangoKey = GlobalKey();
  final GlobalKey btnEventosKey = GlobalKey();
  final GlobalKey btnRankingKey = GlobalKey();
  final GlobalKey btnRedKey = GlobalKey();

  final ScrollController dashboardScrollController =
      ScrollController(); // v74.0.0: Compartido para tour
  /// v2.7.0: Contexto del Scaffold del Dashboard (tour + drawer). Debe ser [ScaffoldState] para `openDrawer`.
  final GlobalKey<ScaffoldState> dashboardContextKey =
      GlobalKey<ScaffoldState>();
  bool isTourActive =
      false; // v73.0.0: Estado centralizado para bloquear navegación

  int selectedIndex = 0;
  PageController? _pageController;
  PageController? get pageController => _pageController;

  var pageList = [
    const DashboardPageV2(),
    const MissionsScreen(),
    const BannerLinksPageV2(),
    const RankingPageV2(),
    const NetworkPageV2(),
  ];

  @override
  void onInit() {
    super.onInit();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    _pageController?.dispose();
    dashboardScrollController.dispose(); // v74.0.0: Limpieza
    super.onClose();
  }

  void resetState() {
    selectedIndex = 0;
    _pageController?.dispose();
    _pageController = PageController(initialPage: 0);
    update();
  }

  changePageIndex(int index) {
    if (index < pageList.length) {
      selectedIndex = index;
      pageController?.jumpToPage(index);
      update();
    }
  }

  logOut(BuildContext context) async {
    await SharedPreference.logOut().then((value) async {
      if (value) {
        // REQUERIMIENTO: Asegurar persistencia de guía por dispositivo tras limpieza selectiva
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('guia_vista', true);

        // REQUERIMIENTO V18.0: Restauración de dependencias de Login tras limpieza
        // Limpieza de estados en RAM
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().updateUserData(null);
          Get.find<DashboardController>().updateDashboardData(null);
        }

        // Re-inyectar LoginController antes de navegar
        if (!Get.isRegistered<LoginController>()) {
          Get.put(LoginController(preferences: prefs), permanent: true);
        }

        // Navegación con limpieza de stack
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false);
      }
    });
  }
}
