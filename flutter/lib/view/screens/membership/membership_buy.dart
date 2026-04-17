import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/colors.dart';
import '../../../controller/membership_controller.dart';
import '../../../controller/dashboard_controller.dart';
import '../../../service/api_service.dart';
import '../../../model/membership_model.dart';

class MembershipBuyPage extends StatefulWidget {
  const MembershipBuyPage({super.key});

  @override
  State<MembershipBuyPage> createState() => _MembershipBuyPageState();
}

class _MembershipBuyPageState extends State<MembershipBuyPage> {
  final Color neonGreen = const Color(0xFF00FF00); // Verde Neón Puro
  late PageController _pageController;
  double _currentPage = 0.0;
  Offset _cardInteractivity = Offset.zero; 
  bool _isInteractingWithCard = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.6);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
    _ensureControllerAndLoadPlansAndScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _ensureControllerAndLoadPlansAndScroll() async {
    if (!Get.isRegistered<MembershipController>()) {
      final prefs = await SharedPreferences.getInstance();
      Get.put(MembershipController(preferences: prefs), permanent: true);
    }
    
    final c = Get.find<MembershipController>();
    await c.getPlans();

    // Auto-scroll al plan activo
    final dashboardController = Get.isRegistered<DashboardController>() 
        ? Get.find<DashboardController>() 
        : null;
    final userPlanName = dashboardController?.dashboardData?.data.userPlan.planName ?? "";
    final plans = c.plans?.data ?? [];

    if (userPlanName.isNotEmpty && plans.isNotEmpty) {
      int activeIndex = plans.indexWhere((p) => 
        userPlanName.toUpperCase().contains(p.name.toUpperCase()) || 
        p.name.toUpperCase().contains(userPlanName.toUpperCase())
      );
      
      if (activeIndex != -1) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              activeIndex, 
              duration: const Duration(milliseconds: 500), 
              curve: Curves.easeInOut
            );
          }
        });
      }
    }
  }

  String _cleanDescription(String raw) {
    final withoutTags = raw.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutTags.replaceAll('&nbsp;', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final MembershipController c = Get.find<MembershipController>();
    
    return Obx(() {
      final dashboardController = Get.isRegistered<DashboardController>() 
          ? Get.find<DashboardController>() 
          : null;
      
      final bool isDashboardLoading = dashboardController == null || dashboardController.isDashboardDataLoading;
      final userPlan = dashboardController?.dashboardData?.data.userPlan;
      
      if (isDashboardLoading || userPlan == null || c.isLoadingPlans) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: neonGreen),
                const SizedBox(height: 20),
                Text(
                  "Sincronizando membresía...",
                  style: TextStyle(
                    color: neonGreen.withOpacity(0.7),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final currentPlanName = userPlan.planName.isNotEmpty ? userPlan.planName : "Cargando...";
      
      // REQUERIMIENTO V1.2.2: Cálculo exacto de calendario (Medianoche)
      // Normalizar fechas para evitar truncamiento por horas (.inDays)
      final DateTime expireDate = userPlan.expireAt;
      final DateTime now = DateTime.now();
      final DateTime pureExpire = DateTime(expireDate.year, expireDate.month, expireDate.day);
      final DateTime pureNow = DateTime(now.year, now.month, now.day);
      final int remainingDays = pureExpire.difference(pureNow).inDays;
      
      final plans = c.plans?.data ?? [];
      
      // Determinar color del botón: Siempre Verde Neón por Ultimatum
      Color actionButtonColor = neonGreen;

      return Scaffold(
        backgroundColor: const Color(0xFF121212), 
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: NeonGridPainter(color: neonGreen.withOpacity(0.02)),
              ),
            ),
            
            Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "MI MEMBRESÍA",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 2.0,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), 
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: plans.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, color: neonGreen.withOpacity(0.3), size: 60),
                              const SizedBox(height: 16),
                              Text(
                                "No hay planes disponibles",
                                style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Poppins'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => c.getPlans(),
                                style: ElevatedButton.styleFrom(backgroundColor: neonGreen.withOpacity(0.1)),
                                child: Text("REINTENTAR", style: TextStyle(color: neonGreen)),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildCurrentPlanCard(currentPlanName, remainingDays),
                              
                              const SizedBox(height: 30),
                              const Center(
                                child: Text(
                                  "COMPARA PLANES",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3.0,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              
                              SizedBox(
                                height: 500, 
                                child: PageView.builder(
                                  controller: _pageController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: plans.length,
                                  itemBuilder: (context, index) {
                                    final plan = plans[index];
                                    
                                    double relativePosition = index - _currentPage;
                                    double scale = 1.0 - (relativePosition.abs() * 0.25).clamp(0.0, 1.0);
                                    double opacity = 1.0 - (relativePosition.abs() * 0.7).clamp(0.0, 1.0);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Opacity(
                                        opacity: opacity.clamp(0.5, 1.0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: _buildPlanCard(plan, relativePosition.abs() < 0.3, index, currentPlanName),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(60, 0, 60, 30), 
                  child: GestureDetector(
                    onTap: () async {
                      if (plans.isNotEmpty) {
                        int currentIndex = _currentPage.round().clamp(0, plans.length - 1);
                        final planId = plans[currentIndex].id;
                        final url = "${ApiService.instance.baseUrl}/membership/buy/$planId";
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54, 
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: actionButtonColor, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: actionButtonColor.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "SUBIR DE NIVEL AHORA",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13, 
                              letterSpacing: 1.5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.swap_calls, color: actionButtonColor, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCurrentPlanCard(String planName, int daysRemaining) {
    double rotationY = _isInteractingWithCard ? (_cardInteractivity.dx * 0.2) : 0.0;
    double rotationX = _isInteractingWithCard ? (_cardInteractivity.dy * -0.2) : 0.0;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _isInteractingWithCard = true;
          double dx = (details.localPosition.dx / context.size!.width) - 0.5;
          double dy = (details.localPosition.dy / 190) - 0.5;
          _cardInteractivity = Offset(dx, dy);
        });
      },
      onPanEnd: (_) => setState(() => _isInteractingWithCard = false),
      onPanCancel: () => setState(() => _isInteractingWithCard = false),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(rotationY)
          ..rotateX(rotationX),
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.black, 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: neonGreen.withOpacity(0.15), width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF002200), // Verde Neón Muy Oscuro
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isInteractingWithCard)
                  Positioned(
                    left: (_cardInteractivity.dx + 0.5) * 400 - 150,
                    top: -100,
                    child: Transform.rotate(
                      angle: 0.6,
                      child: Container(
                        width: 120,
                        height: 500,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "PLAN ACTUAL:",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Text(
                                planName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: neonGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: neonGreen, width: 1),
                            ),
                            child: Text(
                              "ACTIVO",
                              style: TextStyle(
                                color: neonGreen, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quedan $daysRemaining días",
                            style: const TextStyle(
                              color: Colors.white, // Blanco Puro según Ultimatum
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "MEMBRESÍA VERIFICADA",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2), 
                              fontSize: 9, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
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
        ),
      ),
    );
  }

  Widget _buildPlanCard(MembershipPlanItem plan, bool isCentered, int index, String activePlanName) {
    final Color accentColor = neonGreen;
    final bool isActuallyActive = activePlanName.toUpperCase().contains(plan.name.toUpperCase()) || 
                                  plan.name.toUpperCase().contains(activePlanName.toUpperCase());
    
    return GestureDetector(
      onTap: () async {
        final url = "${ApiService.instance.baseUrl}/membership/buy/${plan.id}";
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActuallyActive ? accentColor.withOpacity(0.5) : Colors.white.withOpacity(0.1), 
            width: 0.5
          ), 
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001100), 
              Colors.black, 
            ],
          ),
          boxShadow: isActuallyActive ? [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante para que no crezca de más
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActuallyActive ? neonGreen.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isActuallyActive ? neonGreen.withOpacity(0.5) : Colors.white.withOpacity(0.2), 
                    width: 0.5
                  ),
                ),
                child: Text(
                  isActuallyActive ? "TU PLAN ACTUAL" : "PLAN DISPONIBLE",
                  style: TextStyle(
                    color: isActuallyActive ? neonGreen : Colors.white70, 
                    fontSize: 8, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5
                  ),
                ),
              ),
              Text(
                plan.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text("\$", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Text(
                    "${plan.price}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(color: Colors.white24, blurRadius: 15),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Empieza a generar ingresos reales",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: plan.benefits.isEmpty
                    ? Center(
                        child: Text(
                          "Consulta los beneficios detallados en nuestra web",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(), // Scroll interno independiente
                        itemCount: plan.benefits.length,
                        itemBuilder: (context, bIndex) {
                          return _buildBenefitItem(plan.benefits[bIndex], accentColor);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Espaciado vertical para look & feel de la web
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0), // Centrado visual con la primera línea de texto
            child: Container(
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.8), // Verde esmeralda sutil
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12), // Espaciado para que el texto respire
          Flexible( // Flexible para que el texto largo envuelva correctamente
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11.5,
                fontFamily: 'Poppins',
                height: 1.4, // Altura de línea premium
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NeonGridPainter extends CustomPainter {
  final Color color;
  NeonGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.3;

    const double spacing = 60.0;

    // Lineas verticales
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Lineas horizontales
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Lineas diagonales para el patrón geométrico
    for (double i = -size.height; i < size.width; i += spacing * 2) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
