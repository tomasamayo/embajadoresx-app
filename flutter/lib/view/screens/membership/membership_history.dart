import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/colors.dart';
import '../../../controller/membership_controller.dart';
import '../../../controller/dashboard_controller.dart';

class MembershipHistoryPage extends StatefulWidget {
  const MembershipHistoryPage({super.key});

  @override
  State<MembershipHistoryPage> createState() => _MembershipHistoryPageState();
}

class _MembershipHistoryPageState extends State<MembershipHistoryPage> {
  @override
  void initState() {
    super.initState();
    _ensureControllerAndLoadHistory();
  }

  Future<void> _ensureControllerAndLoadHistory() async {
    if (!Get.isRegistered<MembershipController>()) {
      final prefs = await SharedPreferences.getInstance();
      Get.put(MembershipController(preferences: prefs), permanent: true);
    }
    Get.find<MembershipController>().getHistory();
  }

  @override
  Widget build(BuildContext context) {
    // REQUERIMIENTO V18.4: Inyección automática de dependencia (MembershipController not found fix)
    final MembershipController c = Get.isRegistered<MembershipController>()
        ? Get.find<MembershipController>()
        : Get.put(MembershipController(preferences: Get.find<DashboardController>().preferences), permanent: true);
    
    const Color neonGreen = Color(0xFF00FF88);
    const Color neonYellow = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "HISTORIAL DE COMPRAS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final items = c.history?.data ?? [];
          
          if (c.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator(color: neonGreen));
          }

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, color: Colors.white.withOpacity(0.2), size: 60),
                  const SizedBox(height: 16),
                  Text(
                    "Sin historial de compras",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Poppins'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final it = items[index];
              final bool isCompleted = it.statusText.toLowerCase() == 'completado' || it.statusText.toLowerCase() == 'succeeded';
              
              // REQUERIMIENTO V18.2: Estética Neón Refinada
              final Color statusTextColor = isCompleted ? neonGreen : neonYellow;
              final Color statusBgColor = isCompleted ? const Color(0xFF002211) : const Color(0xFF222200);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // REQUERIMIENTO V18.1/18.2: Nombre del plan y Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.planName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                it.id, // TRX ID extraído
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusTextColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            it.statusText.toUpperCase(),
                            style: TextStyle(
                              color: statusTextColor, 
                              fontSize: 10, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(color: Colors.white10, thickness: 1),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MÉTODO",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.2),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              it.paymentMethod.isEmpty ? "N/A" : it.paymentMethod.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6), 
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "FECHA",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.2),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              it.createdAt,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6), 
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          it.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
  }
