import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart'; // v71.0.0: Import necesario
import 'package:shared_preferences/shared_preferences.dart'; // v73.0.0: Import necesario

import '../../../controller/main_controller.dart';
import '../../theme/ex_futuristic_theme.dart';
import '../../widgets/navigation/ex_bottom_nav.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Widget _buildSharedTooltip(
      BuildContext context, String title, String description,
      {bool isFirst = false, bool isLast = false, bool isAbove = false}) {
    const Color neonGreen = Color(0xFF06FD71);

    return Container(
      width: 280,
      margin: EdgeInsets.only(
        top: isAbove ? 0 : 40,
        bottom: isAbove ? 100 : 0,
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
                  final dashContext = context;
                  final controller = Get.find<MainController>();
                  // 1. PRIMERO: cerrar Showcase (destruir overlay)
                  ShowCaseWidget.of(dashContext).dismiss();

                  // 2. LUEGO: diferir el update de GetX para evitar race condition
                  Future.delayed(const Duration(milliseconds: 300), () {
                    controller.isTourActive = false;
                    controller.update();
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white38, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isFirst)
                TextButton(
                  onPressed: () {
                    final dashContext = context;
                    ShowCaseWidget.of(dashContext).previous();
                  },
                  child: const Text(
                    "ATRÁS",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final dashContext = context;
                  final controller = Get.find<MainController>();
                  // 1. PRIMERO: avanzar Showcase (en el último paso, esto lo finaliza)
                  ShowCaseWidget.of(dashContext).next();

                  // 2. LUEGO: si es el último, diferir el update de GetX
                  if (isLast) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      controller.isTourActive = false;
                      controller.update();
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: neonGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isLast ? "FINALIZAR" : "SIGUIENTE",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      disableBarrierInteraction: true,
      disableMovingAnimation: true,
      autoPlay: false,
      blurValue: 1,
      scrollDuration: const Duration(milliseconds: 500),
      onStart: (index, key) {
        final mainController = Get.find<MainController>();
        mainController.isTourActive = true;
      },
      onFinish: () async {
        final mainController = Get.find<MainController>();
        Future.delayed(const Duration(milliseconds: 300), () {
          mainController.isTourActive =
              false; // v3.0.0: DESBLOQUEO CRÍTICO AL FINALIZAR
          mainController.update(); // v2.5.0: Asegurar refresco de UI tras tour
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('guia_vista', true);
      },
      onComplete: (index, key) async {
        final mainController = Get.find<MainController>();

        // v2.9.2: Notificar cambio en cada paso por seguridad para el estado de isTourActive
        if (index == 6) {
          // Si es el último paso (Mi Red tiene índice 6 en la lista de 7 pasos)
          Future.delayed(const Duration(milliseconds: 300), () {
            mainController.isTourActive = false;
            mainController.update();
          });
        }
        // v73.0.0: Scroll forzado con delay para el Paso 4 (Enlaces)
        if (index == 2) {
          // Termina Paso 3 (ExCoin) -> Va a Paso 4 (Enlaces)
          await Future.delayed(const Duration(milliseconds: 200));
          if (mainController.btnEnlacesKey.currentContext != null) {
            await Scrollable.ensureVisible(
              mainController.btnEnlacesKey.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
            debugPrint(
                "ERROR: Llave de enlaces no encontrada en el contexto actual");
          }
        }

        // v94.0.0: Scroll optimizado para los pasos finales tras eliminar Rango
        if (index != null && index >= 3 && index <= 5) {
          await Future.delayed(const Duration(milliseconds: 200));

          // v74.0.0: Forzar scroll del dashboard al final antes de iluminar pasos bajos
          if (mainController.dashboardScrollController.hasClients) {
            await mainController.dashboardScrollController.animateTo(
              mainController.dashboardScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }

          GlobalKey? nextKey;
          if (index == 3) nextKey = mainController.btnEventosKey;
          if (index == 4) nextKey = mainController.btnRankingKey;
          if (index == 5) nextKey = mainController.btnRedKey;

          if (nextKey?.currentContext != null) {
            await Scrollable.ensureVisible(
              nextKey!.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      builder: (context) {
        return GetBuilder<MainController>(builder: (mainController) {
          // v71.0.0: Blindaje: Verificar que el controlador esté listo
          if (mainController.pageController == null) {
            return const Scaffold(
              backgroundColor: Color(0xFF0B0B0F),
              body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FF88))),
            );
          }

          return Scaffold(
            body: PageView.builder(
              controller: mainController.pageController,
              itemCount: mainController.pageList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                // Cada ítem del PageView debe ser su propia página; NO repetir
                // pageList[selectedIndex] en todos los índices: si no, el mismo widget
                // (p. ej. Dashboard) se monta N veces y un GlobalKey (dashboardContextKey)
                // provoca "A GlobalKey was used multiple times".
                // KeyedSubtree: identidad estable por índice (viewport puede montar varias páginas).
                return KeyedSubtree(
                  key: ValueKey<int>(index),
                  child: mainController.pageList[index],
                );
              },
            ),
            bottomNavigationBar: ExBottomNav(
              currentIndex: mainController.selectedIndex,
              onTap: (int i) {
                mainController.changePageIndex(i);
              },
              items: [
                const ExBottomNavItem(
                  label: "Inicio",
                  icon: Icon(Icons.grid_view_rounded,
                      color: Colors.white70, size: 24),
                  activeIcon: Icon(Icons.grid_view_rounded,
                      color: ExFuturisticTheme.primary, size: 24),
                ),
                ExBottomNavItem(
                  label: "Eventos",
                  icon: Showcase.withWidget(
                    key: mainController.btnEventosKey,
                    height: 200,
                    width: 280,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.85,
                    container: _buildSharedTooltip(
                      context,
                      'Eventos',
                      '📅 Mantente al día con los próximos eventos y lanzamientos.',
                      isAbove: true,
                    ),
                    tooltipPosition: TooltipPosition.top,
                    child: const Icon(Icons.track_changes_rounded,
                        color: Colors.white70, size: 24),
                  ),
                  activeIcon: const Icon(Icons.track_changes_rounded,
                      color: ExFuturisticTheme.primary, size: 24),
                ),
                ExBottomNavItem(
                  label: "Enlaces",
                  icon: Showcase.withWidget(
                    key: mainController.btnEnlacesKey,
                    height: 200,
                    width: 280,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.85,
                    container: _buildSharedTooltip(
                      context,
                      'Tus Enlaces',
                      '🔗 Tus Enlaces: El corazón de tu negocio. Toca aquí para vender',
                      isAbove: true,
                    ),
                    targetPadding: const EdgeInsets.all(20),
                    tooltipPosition: TooltipPosition.top,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ExFuturisticTheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ExFuturisticTheme.primary.withOpacity(0.32),
                        ),
                      ),
                      child: const Icon(Icons.link_rounded,
                          color: ExFuturisticTheme.primary, size: 24),
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ExFuturisticTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ExFuturisticTheme.primary.withOpacity(0.45),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.link_rounded,
                        color: Color(0xFF06100C), size: 24),
                  ),
                ),
                ExBottomNavItem(
                  label: "Ranking",
                  icon: Showcase.withWidget(
                    key: mainController.btnRankingKey,
                    height: 200,
                    width: 280,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.85,
                    container: _buildSharedTooltip(
                      context,
                      'Ranking',
                      '🏆 Ranking: Mira quiénes son los mejores y compite por el primer lugar.',
                      isAbove: true,
                    ),
                    tooltipPosition: TooltipPosition.top,
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Colors.white70, size: 24),
                  ),
                  activeIcon: const Icon(Icons.emoji_events_rounded,
                      color: ExFuturisticTheme.primary, size: 24),
                ),
                ExBottomNavItem(
                  label: "Mi Red",
                  icon: Showcase.withWidget(
                    key: mainController.btnRedKey,
                    height: 200,
                    width: 280,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.85,
                    container: _buildSharedTooltip(
                      context,
                      'Mi Red',
                      '👥 Mi Red: Visualiza tu equipo y gestiona tus afiliados.',
                      isLast: true,
                      isAbove: true,
                    ),
                    tooltipPosition: TooltipPosition.top,
                    child: const Icon(Icons.account_tree_rounded,
                        color: Colors.white70, size: 24),
                  ),
                  activeIcon: const Icon(Icons.account_tree_rounded,
                      color: ExFuturisticTheme.primary, size: 24),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
