import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/text.dart';
import '../../../controller/login_controller.dart';
import '../../../controller/main_controller.dart';
import '../dashboard/components/menu.dart';
import '../main_container/main_container.dart';
import 'edit_profile.dart';

class ProfilePageProfile extends StatelessWidget {
  const ProfilePageProfile({super.key, required this.controller});

  final DashboardController controller;

  // Add these constants at the top of your class
  final double kVerticalSpacing = 16.0;
  final double kHorizontalPadding = 16.0;

  // Add these text style getters
  TextStyle _titleStyle(double width) => TextStyle(
        fontFamily: 'Poppins',
        color: AppColor.appGrey,
        fontSize: width * 0.035,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  TextStyle _contentStyle(double width, {bool isEmail = false}) => TextStyle(
        fontFamily: 'Poppins',
        color: AppColor.appWhite,
        fontSize: width * (isEmail ? 0.04 : 0.05),
        fontWeight: isEmail ? FontWeight.w400 : FontWeight.w600,
        letterSpacing: isEmail ? 0 : 0.3,
      );

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var model = controller.loginModel;
    final String avatarUrl = model?.data?.profileAvatar?.trim() ?? "";
    final String fullName =
        "${model?.data?.firstname ?? ''} ${model?.data?.lastname ?? ''}".trim();

    return model == null
        ? const SizedBox.shrink()
        : Stack(
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Custom Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final firstName = model.data?.firstname ?? '';
                                final lastName = model.data?.lastname ?? '';
                                final email = model.data?.email ?? '';
                                final phone = model.data?.phoneNumber ?? '';

                                Get.put(LoginController(
                                        preferences: controller.preferences))
                                    .setData(
                                  firstName,
                                  lastName,
                                  email,
                                  phone,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfile(
                                      image: avatarUrl,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2923),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          AppColor.appPrimary.withOpacity(0.3)),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.pencil,
                                  color: AppColor.appPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Avatar Section
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColor.appPrimary.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.appPrimary.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColor.appPrimaryLight,
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl.isEmpty
                                    ? Text(
                                        _initials(fullName),
                                        style: const TextStyle(
                                          color: AppColor.appPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColor.appPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Nombre & Email Reactivo con Check Azul
                        Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    fullName.isEmpty
                                        ? 'Embajador EX'
                                        : fullName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (controller.isVerified.value == 1) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 22,
                                  ),
                                ],
                              ],
                            )),
                        Text(
                          model.data?.email ?? '',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Details Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            children: [
                              _buildProfileRow(
                                icon: Icons.person_outline,
                                label: "NOMBRE COMPLETO",
                                value:
                                    "${model.data?.firstname ?? ''} ${model.data?.lastname ?? ''}",
                              ),
                              const Divider(color: Colors.white10, height: 30),
                              _buildProfileRow(
                                icon: Icons.email_outlined,
                                label: "CORREO ELECTRÓNICO",
                                value: model.data?.email ?? '',
                              ),
                              const Divider(color: Colors.white10, height: 30),
                              _buildProfileRow(
                                icon: Icons.phone_outlined,
                                label: "TELÉFONO",
                                value:
                                    model.data?.phoneNumber?.isNotEmpty == true
                                        ? model.data!.phoneNumber!
                                        : 'N/A',
                              ),
                              const Divider(color: Colors.white10, height: 30),
                              _buildPlanRow(
                                icon: Icons.verified_user_outlined,
                                label: "ESTADO DEL PLAN",
                                value: (controller.dashboardData?.data.userPlan
                                                .planName !=
                                            null &&
                                        controller.dashboardData!.data.userPlan
                                            .planName.isNotEmpty)
                                    ? controller
                                        .dashboardData!.data.userPlan.planName
                                    : ((controller.loginModel?.data?.planName
                                                ?.isNotEmpty ??
                                            false)
                                        ? controller.loginModel!.data!.planName!
                                        : "Sin plan visible"),
                                isActive:
                                    model.data?.userStatus?.toLowerCase() ==
                                        'ok',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Modo Proveedor Card (Premium UI)
                        Obx(() => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: controller.isVendorMode.value
                                          ? const Color(0xFF00FF88)
                                              .withOpacity(0.1)
                                          : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                        controller.isVendorMode.value
                                            ? Icons.storefront
                                            : Icons.business_center,
                                        color: controller.isVendorMode.value
                                            ? const Color(0xFF00FF88)
                                            : Colors.grey[400],
                                        size: 22),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "MODO PROVEEDOR",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          "Vende tus propios productos",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: controller.isVendorMode.value,
                                    activeColor: const Color(0xFF00FF88),
                                    activeTrackColor: const Color(0xFF00FF88)
                                        .withOpacity(0.3),
                                    onChanged: (val) =>
                                        controller.toggleVendorMode(),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),

                        // TAREA: v56.0.0 - Opción para reiniciar el App Tour
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();

                            final mainController = Get.find<MainController>();
                            final dashboardController =
                                Get.find<DashboardController>();

                            // 1. Borrar el registro del tutorial en SharedPreferences (Persistencia)
                            final prefs = await SharedPreferences.getInstance();
                            final userId =
                                dashboardController.loginModel?.data?.userId ??
                                    'default';
                            final String tourKey = 'has_seen_tour_v128_$userId';
                            await prefs.setBool(tourKey, false);

                            // 2. ACTIVAR BLOQUEO (v2.7.0)
                            mainController.isTourActive = true;
                            mainController.update();

                            // 3. NAVEGACIÓN ESTRICTA (v2.4.0): Cambio de índice puro y cierre de vista actual
                            mainController.selectedIndex = 0;
                            mainController.pageController?.jumpToPage(0);
                            mainController.update();
                            Navigator.pop(context);

                            // 4. DISPARAR TOUR USANDO GPS DE CONTEXTO (v2.7.0)
                            // ≥600 ms tras pop + cambio de pestaña; +1 frame para que el Scaffold del Dashboard monte la key.
                            Future.delayed(const Duration(milliseconds: 600),
                                () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final dashContext = mainController
                                    .dashboardContextKey.currentContext;

                                if (dashContext != null) {
                                  ShowCaseWidget.of(dashContext).startShowCase([
                                    mainController.perfilKey,
                                    mainController.saldoUSDKey,
                                    mainController.saldoExCoinKey,
                                    mainController.btnEnlacesKey,
                                    mainController.btnEventosKey,
                                    mainController.btnRankingKey,
                                    mainController.btnRedKey,
                                  ]);
                                } else {
                                  debugPrint(
                                      "❌ [TOUR] No se pudo obtener el contexto del Dashboard");
                                  mainController.isTourActive = false;
                                  mainController.update();
                                }
                              });
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color:
                                      const Color(0xFF06FD71).withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06FD71)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.help_outline,
                                      color: Color(0xFF06FD71), size: 20),
                                ),
                                const SizedBox(width: 15),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "AYUDA Y TUTORIAL",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Text(
                                        "Ver tutorial de nuevo",
                                        style: TextStyle(
                                          color: Color(0xFF06FD71),
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white24, size: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  String _initials(String value) {
    final List<String> parts = value
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'EX';
    }
    return parts.take(2).map((String part) => part[0]).join().toUpperCase();
  }

  Widget _buildProfileRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey[400], size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanRow(
      {required IconData icon,
      required String label,
      required String value,
      required bool isActive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.appPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColor.appPrimary, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColor.appPrimary.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColor.appPrimary : Colors.red,
              width: 1,
            ),
          ),
          child: Text(
            isActive ? "ACTIVO" : "INACTIVO",
            style: TextStyle(
              color: isActive ? AppColor.appPrimary : Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
} // Class closing bracket
