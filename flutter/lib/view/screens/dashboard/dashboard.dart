import 'package:affiliatepro_mobile/view/screens/coinx/coinx_wallet_screen.dart';
import 'package:affiliatepro_mobile/controller/coinx/coinx_controller.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/utils/session_manager.dart';
import 'package:affiliatepro_mobile/model/dashboard_model.dart';
import 'package:affiliatepro_mobile/utils/colors.dart' as app_colors;
import 'package:affiliatepro_mobile/view/screens/dashboard/components/menu.dart';
import 'package:affiliatepro_mobile/view/screens/dashboard/components/notification_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../controller/payments_detail_controller.dart';
import 'components/data_cubic.dart';
import 'components/membership_plan.dart';
import 'components/shimmer_widget.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/orders/orders.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payments/payments.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/reports/reports.dart';
import 'package:affiliatepro_mobile/view/screens/wallet/wallet.dart';
import 'package:affiliatepro_mobile/view/screens/profile/profile.dart';
import 'package:affiliatepro_mobile/view/screens/bannerAndLinks/bannerAndLinks.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/benefits/benefits.dart';
import 'package:affiliatepro_mobile/view/screens/main_container/main_container.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/popular_affiliates.dart';
import 'components/weekly_growth_chart.dart';
import 'components/ai_marketing_sheet.dart';
import '../academy_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import '/service/api_service.dart';
import 'package:affiliatepro_mobile/service/event_service.dart';
import 'package:affiliatepro_mobile/service/academy_service.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:async';
import 'package:affiliatepro_mobile/service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool hideAISuggestionBox = false;
  bool hideForever = false;
  bool isRefreshing = false;
  bool isAIPanelOpen = false; // Restaurado para evitar errores
  bool _isSaving = false; // Spinner para actualización de enlaces
  // bool _isTourActive = false; // v73.0.0: Eliminado, ahora se usa MainController.isTourActive
  // Llave del Scaffold: MainController.dashboardContextKey (tour desde Profile, drawer, Showcase)
  // final ScrollController _scrollController = ScrollController(); // v74.0.0: Eliminado local, ahora en MainController
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // v71.0.0: Llaves extraídas del MainController
  // final GlobalKey _perfilKey = GlobalKey(); // Ya no se usan localmente
  // final GlobalKey _saldoUSDKey = GlobalKey();
  // final GlobalKey _saldoExCoinKey = GlobalKey();
  // final GlobalKey _btnEnlacesKey = GlobalKey();
  // final GlobalKey _rangoKey = GlobalKey();
  // final GlobalKey _btnEventosKey = GlobalKey();
  // final GlobalKey _btnRankingKey = GlobalKey();
  // final GlobalKey _btnRedKey = GlobalKey();

  // TAREA: APP TOUR v1.2.9 (v61.0.0) - Custom Tooltip Builder (Margen de Seguridad Anti-Recorte)
  Widget _buildCustomTooltip(String title, String description, {bool isFirst = false, bool isLast = false, bool isAbove = false}) {
    const Color neonGreen = Color(0xFF06FD71);
    final BuildContext? scaffoldContext = Get.find<MainController>().dashboardContextKey.currentContext;
    
    return Container(
      width: 280,
      margin: EdgeInsets.only(
        top: isAbove ? 0 : 40,
        bottom: isAbove ? 100 : 0, // v61.0.0: Margen inferior de 100px para evitar recortes en la parte baja
      ),
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: neonGreen.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila Superior: Título + Botón "X"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: neonGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                onPressed: () {
                  final dashContext = Get.find<MainController>().dashboardContextKey.currentContext;
                  final controller = Get.find<MainController>();
                  if (dashContext != null) {
                    // 1. PRIMERO le damos la orden al paquete de que cierre y destruya su capa invisible 
                    ShowCaseWidget.of(dashContext).dismiss(); 

                    // 2. LUEGO, esperamos 300ms a que la animación de cierre termine y la pantalla quede limpia 
                    Future.delayed(const Duration(milliseconds: 300), () {
                      // 3. AHORA SÍ, quitamos el candado y recargamos la UI 
                      controller.isTourActive = false;
                      controller.update();
                    });
                  }
                },
                icon: const Icon(Icons.close, color: Colors.white38, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Centro: Descripción
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Fila Inferior: Botones de navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isFirst)
                TextButton(
                  onPressed: () {
                    final dashContext = Get.find<MainController>().dashboardContextKey.currentContext;
                    if (dashContext != null) {
                      ShowCaseWidget.of(dashContext).previous(); // Usar dashContext
                    }
                  },
                  child: const Text(
                    "ATRÁS",
                    style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final dashContext = Get.find<MainController>().dashboardContextKey.currentContext;
                  final controller = Get.find<MainController>();
                  if (dashContext != null) {
                    // 1. PRIMERO le damos la orden al paquete de que cierre y destruya su capa invisible 
                    if (isLast) {
                      // En el último paso, usar next() es la forma nativa y segura de finalizar 
                      ShowCaseWidget.of(dashContext).next();
                    } else {
                      ShowCaseWidget.of(dashContext).next(); // Siguiente paso normal
                    }

                    // 2. LUEGO, si es el último, esperamos 300ms a que la animación de cierre termine y la pantalla quede limpia 
                    if (isLast) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        // 3. AHORA SÍ, quitamos el candado y recargamos la UI 
                        controller.isTourActive = false;
                        controller.update();
                      });
                    }
                  }
                },
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   decoration: BoxDecoration(
                     color: neonGreen,
                     borderRadius: BorderRadius.circular(10),
                   ),
                   child: Text(
                     isLast ? "FINALIZAR" : "SIGUIENTE",
                     style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900),
                   ),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleAIPanel() {
    setState(() {
      isAIPanelOpen = !isAIPanelOpen;
      if (isAIPanelOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // v2.1.0: Refactorización crítica para evitar setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DashboardController>().getUser();
      Get.find<DashboardController>().getDashboardData();
      fetchPayment();
      checkHidePreference();
      
      // TAREA: APP TOUR v1.2.9 (v55.0.0) - Auto-disparo
      _checkShowcase();
    });

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),  // Starts from right
      end: Offset.zero,                // Ends at original position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // REQUERIMIENTO: Re-verificar token al volver a la app (v4.0.0)
      NotificationService().registerFCMTokenIfReady();
    }
  }

  Future<void> _checkShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final dashboardController = Get.find<DashboardController>();
    final mainController = Get.find<MainController>();
    
    // TAREA: Validación de persistencia local (Una sola vez por dispositivo)
    final bool hasSeenTour = prefs.getBool('guia_vista') ?? false; 
    
    if (!hasSeenTour) { 
      if (dashboardController.isLoading || dashboardController.isDashboardDataLoading) { 
        Future.delayed(const Duration(milliseconds: 1000), () => _checkShowcase()); 
        return; 
      } 
      
      final BuildContext? scaffoldContext = Get.find<MainController>().dashboardContextKey.currentContext; 
      if (mounted && scaffoldContext != null) { 
        // v2.2.0: Doble verificación de seguridad para asegurar que los widgets están listos
        await Future.delayed(const Duration(milliseconds: 1200)); 
        
        // Verificar que las llaves críticas tengan contexto antes de disparar
        if (mainController.perfilKey.currentContext == null || 
            mainController.saldoUSDKey.currentContext == null) {
          debugPrint("⚠️ [TOUR] Widgets no listos, reintentando...");
          Future.delayed(const Duration(milliseconds: 500), () => _checkShowcase());
          return;
        }

        await Scrollable.ensureVisible(scaffoldContext, duration: const Duration(milliseconds: 500)); 
        
        // 1. BLOQUEAR LA APP 
        mainController.isTourActive = true; 
        
        // 2. GUARDAR PARA QUE NUNCA MÁS SE REPITA EN ESTE DISPOSITIVO 
        await prefs.setBool('guia_vista', true); 
        
        // 3. INICIAR TOUR 
        ShowCaseWidget.of(scaffoldContext).startShowCase([ 
          mainController.perfilKey, 
          mainController.saldoUSDKey, 
          mainController.saldoExCoinKey, 
          mainController.btnEnlacesKey, 
          mainController.btnEventosKey, 
          mainController.btnRankingKey, 
          mainController.btnRedKey, 
        ]); 
      } 
    } 
  }


  void fetchPayment() {
    Get.find<PaymentDetailController>().getPaymentsData();
  }

  Future<void> checkHidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hideForever = prefs.getBool('hide_ai_box_forever') ?? false;
    });
  }

  Future<void> setHideForever() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_ai_box_forever', true);
    setState(() {
      hideAISuggestionBox = true;
      hideForever = true;
      _toggleAIPanel();
    });
  }

  void hideOnce() {
    setState(() {
      hideAISuggestionBox = true;
      _toggleAIPanel();
    });
  }



  void _refreshSuggestion() {
    setState(() {
      isRefreshing = true;
    });

    final dashboardController = Get.find<DashboardController>();
    dashboardController.refreshAISuggestion();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    });
  }

  void _showAIMarketingCenter() {
    HapticFeedback.mediumImpact();
    final dashboardController = Get.find<DashboardController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AIMarketingSheet(
        productosDisponibles: dashboardController.dashboardData?.data.marketTools ?? [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentDetailController>(
      builder: (paymentDetailController) {
        return GetBuilder<DashboardController>(
          builder: (dashboardController) {
            return Scaffold(
              key: Get.find<MainController>().dashboardContextKey,
              drawer: Drawer( // Restaurado a drawer (lado izquierdo)
                backgroundColor: app_colors.AppColor.appPrimaryLight,
                child: const MenuPage(),
              ),
              backgroundColor: app_colors.AppColor.dashboardBgColor,
              bottomNavigationBar: _buildBottomNavigationIfStandalone(context),
              body: Stack(
                children: [
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
                            app_colors.AppColor.appPrimary.withOpacity(0.4),
                            app_colors.AppColor.appPrimary.withOpacity(0.1),
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
                        // Custom Header inline
                        _buildCustomHeader(dashboardController),
                        
                        // Scrollable Body
                        Expanded(
                          child: _buildContent(
                            dashboardController,
                            paymentDetailController,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. AI Button (Floating)
                  if (!hideForever)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: ElasticInUp(
                        child: Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [app_colors.AppColor.appPrimary, Color(0xFF00FF88)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: app_colors.AppColor.appPrimary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleAIPanel,
                              borderRadius: BorderRadius.circular(28),
                              child: const Center(
                                child: Icon(
                                  Icons.smart_toy_outlined,
                                  color: app_colors.AppColor.appBlack,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 4. Sliding AI Panel
                  if (!hideAISuggestionBox && !hideForever && isAIPanelOpen)
                    Positioned(
                      right: 16,
                      top: 80,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildAIPanel(dashboardController),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomHeader(DashboardController controller) {
    return GetBuilder<MainController>(
      builder: (mainController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 10, 16.0, 10),
          child: Row(
            children: [
              // 1. Avatar (Interactivo - v69.0.0: Ya no es un paso del tour)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (mainController.isTourActive) return; // v2.9.2: Bloqueo reactivo
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  splashColor: const Color(0xFF00FF88).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: controller.loginModel?.data?.profileAvatar != null && controller.loginModel!.data!.profileAvatar!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(controller.loginModel!.data!.profileAvatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: const Color(0xFF151520),
                      border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5), width: 1.5),
                    ),
                    child: (controller.loginModel?.data?.profileAvatar == null || controller.loginModel!.data!.profileAvatar!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white24, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 2. Textos (Saludo e "Ir al perfil") - Paso 1 del Tour (v69.0.0)
              Expanded(
                child: Showcase.withWidget(
                  key: mainController.perfilKey,
                  height: 200,
                  width: 280,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.85,
                  container: _buildCustomTooltip(
                    'Tu Perfil', 
                    '👤 Tu Perfil: Hola! Aquí puedes gestionar tus datos, editar tu información y ver tu progreso',
                    isFirst: true, // v69.0.0: Texto mejorado
                    isAbove: false,
                  ),
                  targetPadding: const EdgeInsets.all(10), // v64.0.0: Padding ajustado
                  tooltipPosition: TooltipPosition.bottom,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Saludo con Check Azul Reactivo (Persistent)
                      Obx(() {
                        final bool isVerified = controller.isVerified.value == 1;
                        final String userName = controller.loginModel?.data?.firstname ?? 'Ex';
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Hola, $userName!",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue, // EL USUARIO EXIGE AZUL
                                size: 20,
                              ),
                            ],
                          ],
                        );
                      }),
                      
                      // Acción: Ver Perfil
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (mainController.isTourActive) return; // v2.9.2: Bloqueo reactivo
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfilePage()),
                            );
                          },
                          splashColor: const Color(0xFF00FF88).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Ver Perfil",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  if (mainController.isTourActive) return; // v2.9.2: Bloqueo reactivo del menú hamburguesa
                  HapticFeedback.lightImpact();
                  Get.find<MainController>().dashboardContextKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget? _buildBottomNavigationIfStandalone(BuildContext context) {
    // v73.0.0: Simplificado para evitar duplicidad y asegurar que el Showcase use el contexto global de MainContainer
    final bool hasMainPageAncestor = context.findAncestorWidgetOfExactType<MainPage>() != null;
    if (hasMainPageAncestor) return null;

    final mainController = Get.isRegistered<MainController>() ? Get.find<MainController>() : Get.put(MainController());

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xFF0B0B0F),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B0B0F),
        selectedItemColor: const Color(0xFF00FF88),
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        currentIndex: mainController.selectedIndex,
        onTap: (i) {
          mainController.changePageIndex(i);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Inicio",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: "Eventos",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(Icons.link, color: Color(0xFF00FF88), size: 28),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withOpacity(0.8),
                    blurRadius: 25,
                    spreadRadius: 8,
                  )
                ],
              ),
              child: const Icon(Icons.link, color: Colors.black, size: 30),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: "Ranking",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: "Mi Red",
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, DashboardController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151520),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white)),
        content: const Text("¿Estás seguro de que quieres salir? Se limpiarán absolutamente todos los datos de sesión.", 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              // 1. REQUERIMIENTO V12.0: Logout Seguro y Controlado
              final mainController = Get.find<MainController>();
              await mainController.logOut(context);
            },
            child: const Text("CERRAR SESIÓN", style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      DashboardController dashboardController,
      PaymentDetailController paymentDetailController,
      ) {
    final mainController = Get.find<MainController>();
    if (dashboardController.isLoading ||
        dashboardController.isDashboardDataLoading) {
      return ShimmerWidget(controller: dashboardController);
    }

    var dashModel = dashboardController.dashboardData;
    if (dashModel == null) return const SizedBox();

    return SingleChildScrollView(
      controller: Get.find<MainController>().dashboardScrollController, // v74.0.0: Compartido
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (paymentDetailController.PaymentDetailData?.data.notification
                    ?.paymentList ==
                    'Bank details are not set!')
                  NotificationBar(controller: paymentDetailController),

                const SizedBox(height: 20),

                // 1. Balance Section (Big & Bold)
                _buildBalanceSection(dashModel.data.userTotals.userBalance, dashModel.data.userTotals.walletUnpaidAmount),
              ],
            ),
          ),
          
          // 1.1 Weekly Growth Chart (FULL WIDTH - No parent padding)
          Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 280, // Altura optimizada REQUERIMIENTO V1.2.2
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0), // REQUERIMIENTO V1.2.2: Padding aumentado para visibilidad de L y D
                  child: WeeklyGrowthChartWidget(
                    weeklyData: dashModel.data.weeklyChartData,
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // 2. Metrics Grid (Balance, Actions, Clicks, Transferred) - Mantener intacto
                _buildMetricsGrid(dashModel),

                const SizedBox(height: 24),

                // 3. NUEVAS ACCIONES RÁPIDAS (Quick Actions)
                Padding( 
                  padding: const EdgeInsets.symmetric(vertical: 12.0), 
                  child: Row( 
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                    children: [ 
                      _buildQuickAction(Icons.link, "Mis Enlaces", () {
                        _mostrarMisEnlaces(context);
                      }), 
                      _buildQuickAction(Icons.verified_user, "Mi Plan", () {
                        _mostrarPlanMembresia(context);
                      }), 
                      _buildQuickAction(Icons.rocket_launch, "Academia", () {
                        if (Get.find<MainController>().isTourActive) return;
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AcademyScreen()));
                      }), 
                    ], 
                  ), 
                ),

                const SizedBox(height: 16),

                // 4. TARJETA DE PROGRESO COMPACTA E INTERACTIVA (v94.0.0: ELIMINACIÓN RADICAL DEL SHOWCASE)
                Padding( 
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), 
                  child: GestureDetector( 
                    onTap: () { 
                      if (Get.find<MainController>().isTourActive) return; 
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BenefitsPage())); 
                    }, 
                    child: Container( 
                      width: double.infinity, 
                      decoration: BoxDecoration( 
                        color: const Color(0xFF151520), 
                        borderRadius: BorderRadius.circular(15), 
                        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)) 
                      ), 
                      child: Padding( 
                        padding: const EdgeInsets.all(16.0), 
                        child: Row( 
                          children: [ 
                            Expanded( 
                              child: Column( 
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                mainAxisAlignment: MainAxisAlignment.center, 
                                children: [ 
                                  Row( 
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                    children: [ 
                                      Text( 
                                        "RANGO: ${dashModel.data.currentRankName.toUpperCase()}", 
                                        style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5, fontFamily: 'Poppins') 
                                      ), 
                                      Text( 
                                        "\$${dashModel.data.userTotals.userBalance}", 
                                        style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontFamily: 'Poppins') 
                                      ) 
                                    ] 
                                  ), 
                                  const SizedBox(height: 12), 
                                  LinearProgressIndicator( 
                                    value: (dashModel.data.userPlan.statusId != '0') ? 1.0 : 0.0, 
                                    backgroundColor: Colors.white10, 
                                    color: const Color(0xFF00FF88), 
                                    minHeight: 6, 
                                    borderRadius: BorderRadius.circular(10) 
                                  ), 
                                ], 
                              ), 
                            ), 
                            const SizedBox(width: 16), 
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16), 
                          ], 
                        ), 
                      ), 
                    ), 
                  ), 
                ),

                const SizedBox(height: 24),

                // 5. SECCIÓN ACTIVIDAD RECIENTE (DATOS REALES)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8), 
                  child: Text("ACTIVIDAD RECIENTE", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5, fontFamily: 'Poppins'))
                ), 
                
                if (dashModel.data.notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "Aún no tienes actividades recientes",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...dashModel.data.notifications.take(5).map((notif) {
                    // Lógica dinámica de iconos y traducción basada en el contenido
                    IconData icon = Icons.notifications_active;
                    String desc = notif['description'] ?? notif['message'] ?? "";
                    String title = notif['title'] ?? "Nueva Actividad";
                    
                    // REQUERIMIENTO V1.2.1: Traducción dinámica simple (Frontend Fix)
                    if (desc.toLowerCase().contains("register as a on affiliate program")) {
                      desc = desc.replaceAll(RegExp("register as a on affiliate program", caseSensitive: false), "se registró en el programa de afiliados");
                    }
                    if (desc.toLowerCase().contains("purchased a new subscription")) {
                      desc = desc.replaceAll(RegExp("purchased a new subscription", caseSensitive: false), "compró una nueva suscripción");
                    }
                    if (desc.toLowerCase().contains("purchased")) {
                      desc = desc.replaceAll(RegExp("purchased", caseSensitive: false), "compró");
                    }
                    if (desc.toLowerCase().contains("membership plan bonus")) {
                      desc = "Bono de Membresía";
                    }

                    // REQUERIMIENTO V1.2.1: Sincronización de iconos dinámicos
                    if (desc.contains("Bono de Membresía")) {
                      icon = Icons.card_membership; // REQUERIMIENTO V1.2.1: Icono específico para Bono de Membresía
                    } else if (desc.toLowerCase().contains("compro") || desc.toLowerCase().contains("compra") || desc.toLowerCase().contains("suscripción") || desc.toLowerCase().contains("order")) {
                      icon = Icons.shopping_cart_outlined;
                    } else if (desc.toLowerCase().contains("register") || desc.toLowerCase().contains("unió") || desc.toLowerCase().contains("registro")) {
                      icon = Icons.person_add_alt_1_outlined;
                    } else if (desc.toLowerCase().contains("comisión") || desc.toLowerCase().contains("ganaste")) {
                      icon = Icons.monetization_on_outlined;
                    }

                    return _buildNotificationItem(
                      icon: icon,
                      title: desc.isNotEmpty ? desc : title,
                      subtitle: notif['created_at'] ?? "Reciente",
                    );
                  }).toList(),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile( 
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(color: const Color(0xFF151520), borderRadius: BorderRadius.circular(8)), 
          child: Icon(icon, color: const Color(0xFF00FF88))
        ), 
        title: Text(
          title, 
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ), 
        subtitle: Text(
          subtitle, 
          style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Poppins')
        ), 
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF151520),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
            ),
            child: Icon(icon, color: const Color(0xFF00FF88), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  void _mostrarPlanMembresia(BuildContext context) { 
    final dashboardController = Get.find<DashboardController>();
    
    showModalBottomSheet( 
      context: context, 
      backgroundColor: Colors.transparent, 
      isScrollControlled: true, 
      builder: (context) => Obx(() => Container( 
        padding: const EdgeInsets.all(24), 
        decoration: const BoxDecoration( 
          color: Color(0xFF0B0B0F), // Fondo oscuro 
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)), 
          border: Border(top: BorderSide(color: Color(0xFF00FF88), width: 1.5)), // Borde neón superior 
        ), 
        child: Column( 
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))), 
            const SizedBox(height: 20), 
            const Text("Plan de Membresía", style: TextStyle(color: Color(0xFF00FF88), fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), 
            const SizedBox(height: 20), 
            // Tarjeta interna del plan 
            Container( 
              padding: const EdgeInsets.all(16), 
              decoration: BoxDecoration(color: const Color(0xFF151520), borderRadius: BorderRadius.circular(16)), 
              child: Column( 
                children: [ 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      const Text("Estado", style: TextStyle(color: Colors.white54, fontFamily: 'Poppins')), 
                      Text(
                        dashboardController.planStatus.value, 
                        style: TextStyle(
                          color: dashboardController.planStatus.value == "ACTIVO" ? const Color(0xFF00FF88) : Colors.redAccent, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: 'Poppins'
                        )
                      )
                    ]
                  ), 
                  const Divider(color: Colors.white10, height: 30), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      const Text("Plan Actual", style: TextStyle(color: Colors.white54, fontFamily: 'Poppins')), 
                      Text(
                        dashboardController.planName.value, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
                      )
                    ]
                  ), 
                  const Divider(color: Colors.white10, height: 30), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      const Text("Vence en", style: TextStyle(color: Colors.white54, fontFamily: 'Poppins')), 
                      Text(
                        dashboardController.daysLeftStr.value, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
                      )
                    ]
                  ), 
                ], 
              ), 
            ), 
            const SizedBox(height: 30), 
          ], 
        ), 
      )), 
    ); 
  }

  void _mostrarMisEnlaces(BuildContext context) { 
    final dashboardController = Get.find<DashboardController>();
    var affiliateStoreUrl = dashboardController.dashboardData?.data.affiliateStoreUrl ?? "";
    var resellerLink = dashboardController.dashboardData?.data.uniqueResellerLink ?? "";
    var isVendor = dashboardController.loginModel?.data?.isVendor == "1";

    showModalBottomSheet( 
      context: context, 
      backgroundColor: Colors.transparent, 
      isScrollControlled: true, 
      builder: (context) => Container( 
        padding: const EdgeInsets.all(24), 
        decoration: const BoxDecoration( 
          color: Color(0xFF0B0B0F), 
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)), 
          border: Border(top: BorderSide(color: Color(0xFF00FF88), width: 1.5)), 
        ), 
        child: Column( 
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))), 
            const SizedBox(height: 20), 
            Text(
              isVendor ? "Mis Enlaces de Proveedor" : "Mis Enlaces de Afiliado", 
              style: const TextStyle(color: Color(0xFF00FF88), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
            ), 
            const SizedBox(height: 20), 
            
            // Lista de Enlaces Dinámica según Rol (Lógica clonada de MiRegistro)
            if (!isVendor) ...[
              _buildLinkCardSheet("Tienda Afiliado", affiliateStoreUrl, Icons.store, "store"), 
              const SizedBox(height: 12), 
              _buildLinkCardSheet("Registro Revendedor", resellerLink, Icons.person_add, "reseller"), 
            ] else ...[
              _buildLinkCardSheet("URL de la tienda", affiliateStoreUrl, Icons.store, "store"), 
              const SizedBox(height: 12), 
              _buildLinkCardSheet("Comparte tu tienda", affiliateStoreUrl, Icons.share, "store"), 
              const SizedBox(height: 12), 
              _buildLinkCardSheet("Invitar a proveedores", resellerLink, Icons.person_add, "reseller"), 
              const SizedBox(height: 12), 
              _buildLinkCardSheet("Invitar a afiliados", resellerLink, Icons.group_add, "reseller"), 
            ],
            
            const SizedBox(height: 30), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  Widget _buildLinkCardSheet(String title, String url, IconData icon, String type) { 
    return Container( 
      margin: const EdgeInsets.only(bottom: 12), 
      padding: const EdgeInsets.all(12), 
      decoration: BoxDecoration(color: const Color(0xFF151520), borderRadius: BorderRadius.circular(12)), 
      child: Row( 
        children: [ 
          Container( 
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: const Color(0xFF0B0B0F), borderRadius: BorderRadius.circular(8)), 
            child: Icon(icon, color: const Color(0xFF00FF88), size: 20), 
          ), 
          const SizedBox(width: 12), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
                Text(url, style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )
          ), 
          IconButton( 
            icon: const Icon(Icons.copy, color: Colors.white54, size: 20), 
            onPressed: () {
              if (url.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: url));
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Enlace copiado", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFF00FF88),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            }, 
          ),
        ], 
      ), 
    ); 
  }

  void _mostrarDialogoEditarEnlace(String titulo, String urlActual, String type) {
    final TextEditingController _slugController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0B0B0F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00FF88), width: 0.5)),
          title: Text("Editar $titulo", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ingresa el nuevo slug para tu enlace:", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: _slugController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "ej: mi-tienda-ex",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF151520),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00FF88))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context), 
              child: const Text("CANCELAR", style: TextStyle(color: Colors.white54))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: _isSaving ? null : () async {
                if (_slugController.text.trim().isEmpty) return;
                
                setDialogState(() { _isSaving = true; }); // Activa spinner local
                setState(() { _isSaving = true; }); // Activa spinner global
                
                await _actualizarEnlaceReal(_slugController.text.trim(), type);
                
                if (mounted) {
                  setDialogState(() { _isSaving = false; });
                  setState(() { _isSaving = false; });
                }
              },
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text("ACTUALIZAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _actualizarEnlaceReal(String nuevoSlug, String type) async {
    final dashboardController = Get.find<DashboardController>();
    final userId = dashboardController.loginModel?.data?.userId ?? "1";
    
    // Mapeo dinámico del tipo según backend
    String tipoDeEnlace = 'product';
    if (type == 'reseller') tipoDeEnlace = 'store';
    // Se puede expandir según 'form', etc.

    final String urlEndpoint = 'https://embajadoresx.com/api/update_affiliate_link';
    final Map<String, String> payload = {
      'user_id': userId.toString(),
      'related_id': '1', // TODO: Reemplazar con ID real si es dinámico
      'new_slug': nuevoSlug,
      'type': tipoDeEnlace,
    };

    print('🔎 [ENLACES] Intentando actualizar enlace...');
    print('📡 [ENLACES] URL: $urlEndpoint');
    print('📦 [ENLACES] Payload: $payload');

    try {
      final response = await http.post(
        Uri.parse(urlEndpoint), 
        body: payload,
      ).timeout(const Duration(seconds: 15));

      print('📥 [ENLACES] Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          if (mounted) {
            Navigator.pop(context); // Cierra el diálogo
            Navigator.pop(context); // Cierra el bottom sheet para refrescar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Color(0xFF00FF88),
                content: Text("¡Enlace actualizado con éxito!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            );
            // Refrescar datos del dashboard
            dashboardController.getDashboardData();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.redAccent, content: Text(data['message'] ?? "Error al actualizar")),
            );
          }
        }
      } else {
        print('❌ [ENLACES] Error de servidor: ${response.statusCode}');
        throw Exception("Error de servidor: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ [ENLACES] Error Crítico: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Error de conexión")),
        );
      }
    }
  }

  Widget _buildAcademyCTA(BuildContext context) {
    const Color neonGreen = Color(0xFF00FF88);
    final mainController = Get.find<MainController>();

    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          if (Get.find<MainController>().isTourActive) return;
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AcademyScreen()),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1E1E),
                const Color(0xFF121212).withOpacity(0.9),
              ],
            ),
            border: Border.all(
              color: neonGreen.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: neonGreen.withOpacity(0.03),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded, // Usamos un cohete para representar el impulso de la academia
                  color: neonGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Academia EX",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Aprende a vender y multiplica tus comisiones",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(DashboardModel dashModel) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMetricCard(
          "Balance", 
          dashModel.data.userTotals.userBalance, 
          Icons.account_balance_wallet, 
          Colors.blue
        ),
        _buildMetricCard(
          "Acciones", 
          "${dashModel.data.userTotals.clickActionTotal}/${dashModel.data.userTotals.clickActionCommission}", 
          Icons.flash_on, 
          Colors.orange
        ),
        _buildMetricCard(
          "Clics", 
          "${dashModel.data.userTotals.totalClicksCount}/\$${dashModel.data.userTotals.totalClicksCommission}", 
          Icons.mouse, 
          Colors.purple
        ),
        _buildMetricCard(
          "Total Transferido", 
          dashModel.data.userTotals.userBalance, 
          Icons.payment, 
          Colors.green
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: app_colors.AppColor.dashboardCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: app_colors.AppColor.appWhite.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: app_colors.AppColor.appGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: app_colors.AppColor.appWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(String balance, dynamic margin) {
    final dashboardController = Get.find<DashboardController>();
    final mainController = Get.find<MainController>();
    final excoinController = Get.isRegistered<ExCoinController>() 
        ? Get.find<ExCoinController>() 
        : null;
    
    return Row(
      children: [
        // TAREA 1 & 3 (v3.0.0): Tarjeta Izquierda - Saldo USD (Verde Neón)
        Expanded(
          child: Showcase.withWidget(
            key: Get.find<MainController>().saldoUSDKey,
            height: 200,
            width: 280,
            overlayColor: Colors.black,
            overlayOpacity: 0.85,
            container: _buildCustomTooltip(
              'Saldo USD', 
              '💰 Tu Ganancia Real: Aquí verás tus dólares listos para retirar',
              isFirst: false, // v65.0.0: Paso 2
              isAbove: false, // v60.0.0: Burbuja ABAJO
            ),
            targetPadding: const EdgeInsets.all(25), // v60.0.0: Target ampliado a 25
            tooltipPosition: TooltipPosition.bottom, // v60.0.0: Forzar abajo
            child: GestureDetector(
              onTap: () {
                // v73.0.0: Bloqueo centralizado
                if (Get.find<MainController>().isTourActive) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: app_colors.AppColor.dashboardCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      app_colors.AppColor.dashboardCardColor,
                      const Color(0xFF0A1A10).withOpacity(0.3),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Saldo USD",
                      style: TextStyle(
                        color: app_colors.AppColor.appGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      child: excoinController != null 
                      ? Obx(() => Text(
                          "\$${excoinController.availableEarnings.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.greenAccent, // TAREA 3: Verde Neón
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ))
                      : Text(
                          balance,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // TAREA 1, 3 & 4 (v3.0.0): Tarjeta Derecha - Saldo ExCoin (Dorado/Ámbar)
        Expanded(
          child: Showcase.withWidget(
            key: Get.find<MainController>().saldoExCoinKey,
            height: 200,
            width: 280,
            overlayColor: Colors.black,
            overlayOpacity: 0.85,
            container: _buildCustomTooltip(
              'Saldo ExCoin', 
              '🟡 ExCoins: Tu moneda virtual para potenciar ventas y premios',
              isFirst: false,
              isLast: false, // v68.0.0: Ya no es el último
              isAbove: false, // v60.0.0: Burbuja ABAJO
            ),
            targetPadding: const EdgeInsets.all(25), // v60.0.0: Target ampliado a 25
            tooltipPosition: TooltipPosition.bottom, // v60.0.0: Forzar abajo
            child: GestureDetector(
              onTap: () {
                // v73.0.0: Bloqueo centralizado
                if (Get.find<MainController>().isTourActive) return;

                HapticFeedback.lightImpact();
                // TAREA 4: Navegación Directa
                Get.to(() => const ExCoinWalletScreen());
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: app_colors.AppColor.dashboardCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      app_colors.AppColor.dashboardCardColor,
                      const Color(0xFF1A1A0A).withOpacity(0.5),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Saldo ExCoin",
                      style: TextStyle(
                        color: app_colors.AppColor.appGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: excoinController != null 
                            ? Obx(() => Text(
                                '${excoinController.excoinBalance.value.toInt()}',
                                style: const TextStyle(
                                  color: Colors.amber, // TAREA 3: Dorado/Ámbar
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ))
                            : Obx(() => Text(
                                '${dashboardController.excoinBalance.value.toInt()}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              )),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.toll, color: Colors.amber, size: 20), // TAREA 3: Icono Dorado
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAffiliateLinks(DashboardController controller) {
    var affiliateStoreUrl = controller.dashboardData?.data.affiliateStoreUrl ?? "";
    var resellerLink = controller.dashboardData?.data.uniqueResellerLink ?? "";
    var isVendor = controller.loginModel?.data?.isVendor == "1";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            isVendor ? "Enlaces de Proveedor" : "Enlaces de Afiliado",
            style: const TextStyle(
              color: app_colors.AppColor.appWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (!isVendor) ...[
                _buildLinkCard("Tienda Afiliado", affiliateStoreUrl, FontAwesomeIcons.store),
                const SizedBox(width: 12),
                _buildLinkCard("Registro Revendedor", resellerLink, FontAwesomeIcons.userPlus),
              ] else ...[
                _buildLinkCard("URL de la tienda", affiliateStoreUrl, FontAwesomeIcons.store),
                const SizedBox(width: 12),
                _buildLinkCard("Comparte tu tienda de proveedor", affiliateStoreUrl, FontAwesomeIcons.cartShopping),
                const SizedBox(width: 12),
                _buildLinkCard("Invitar a proveedores", resellerLink, FontAwesomeIcons.userTie),
                const SizedBox(width: 12),
                _buildLinkCard("Invitar a afiliados", resellerLink, FontAwesomeIcons.userPlus),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkCard(String title, String url, IconData icon) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_colors.AppColor.dashboardCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: app_colors.AppColor.appWhite.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: app_colors.AppColor.appPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: app_colors.AppColor.appPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: app_colors.AppColor.appWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              if (url.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Enlace copiado al portapapeles',
                      style: TextStyle(color: app_colors.AppColor.appBlack, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: app_colors.AppColor.appPrimary,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: app_colors.AppColor.appPrimaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: app_colors.AppColor.appWhite.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.copy, size: 14, color: app_colors.AppColor.appGrey),
                  const SizedBox(width: 8),
                  Text(
                    "Copiar Enlace",
                    style: TextStyle(
                      color: app_colors.AppColor.appGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResellerCard(String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_colors.AppColor.dashboardCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: app_colors.AppColor.appWhite.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1C1C), // Dark red/brown bg
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add_outlined, color: Color(0xFFFF5252), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Registro Revendedor",
                  style: TextStyle(
                    color: app_colors.AppColor.appWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ".../register/N", // Placeholder or truncated link
                  style: TextStyle(
                    color: app_colors.AppColor.appGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
               Clipboard.setData(ClipboardData(text: url));
               Get.snackbar('Copiado', 'Enlace de revendedor copiado');
            },
            icon: Icon(Icons.copy, color: app_colors.AppColor.appGrey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPanel(DashboardController dashboardController) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85 - 16,
        decoration: BoxDecoration(
          color: app_colors.AppColor.appPrimaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: app_colors.AppColor.appPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: app_colors.AppColor.appPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Sugerencia EX",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: app_colors.AppColor.appPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: app_colors.AppColor.appGrey, size: 18),
                    onPressed: _refreshSuggestion,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close, color: app_colors.AppColor.appGrey, size: 18),
                    onPressed: _toggleAIPanel,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    opacity: isRefreshing ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      dashboardController.getAISuggestion(),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: app_colors.AppColor.appWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: hideOnce,
                        child: Text(
                          "Ocultar ahora",
                          style: TextStyle(color: app_colors.AppColor.appGrey, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: setHideForever,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: app_colors.AppColor.appPrimary,
                          foregroundColor: app_colors.AppColor.appBlack,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "No mostrar más",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
