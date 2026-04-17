import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/admin_controller.dart';
import 'package:animate_do/animate_do.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final AdminController controller = Get.put(AdminController());

  static const Color _neon = Color(0xFF00FF88);
  static const Color _card = Color(0xFF111916);
  static const Color _cardBorder = Color(0xFF1E2D25);

  @override
  void initState() {
    super.initState();
    controller.getComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050905),
              Color(0xFF0A1A10),
              Color(0xFF0F2318),
              Color(0xFF071208),
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingComplaints.value) {
                    return _buildLoading();
                  }
                  if (controller.complaints.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildList();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 16),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "LIBRO DE RECLAMACIONES",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _neon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _neon.withOpacity(0.2)),
            ),
            child: const Icon(Icons.assignment_outlined, color: _neon, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              color: _neon,
              backgroundColor: _neon.withOpacity(0.15),
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text("Cargando reclamaciones...",
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      duration: const Duration(milliseconds: 700),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono principal con efecto glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _neon.withOpacity(0.04),
                      boxShadow: [
                        BoxShadow(color: _neon.withOpacity(0.12), blurRadius: 50, spreadRadius: 10),
                      ],
                    ),
                  ),
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _neon.withOpacity(0.06),
                      border: Border.all(color: _neon.withOpacity(0.18), width: 1.5),
                    ),
                  ),
                  Icon(
                    Icons.verified_outlined,
                    color: _neon.withOpacity(0.75),
                    size: 42,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _neon.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _neon.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _neon,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      "SISTEMA LIMPIO",
                      style: TextStyle(
                        color: _neon,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "No hay reclamos\nregistrados aún.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Cuando los usuarios presenten\nreclamaciones, aparecerán aquí\npara tu gestión y seguimiento.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 40),
              // Estadística visual
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statPill(Icons.check_circle_outline, "Resueltos", "0", _neon),
                    Container(width: 1, height: 36, color: Colors.white.withOpacity(0.06)),
                    _statPill(Icons.pending_outlined, "Pendientes", "0", Colors.orangeAccent),
                    Container(width: 1, height: 36, color: Colors.white.withOpacity(0.06)),
                    _statPill(Icons.assignment_turned_in_outlined, "Total", "0", Colors.white54),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      itemCount: controller.complaints.length,
      itemBuilder: (context, index) {
        final complaint = controller.complaints[index];
        final statusInt = complaint.status;
        final bool isResolved = statusInt == 1;

        return FadeInUp(
          delay: Duration(milliseconds: index * 60),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isResolved
                    ? _neon.withOpacity(0.2)
                    : Colors.orangeAccent.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.white54, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${complaint.firstname} ${complaint.lastname}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            complaint.email,
                            style: const TextStyle(color: Color(0xFF00FF88), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(isResolved),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 14),
                Text(
                  complaint.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isResolved) {
    final Color color = isResolved ? _neon : Colors.orangeAccent;
    final String label = isResolved ? "RESUELTO" : "PENDIENTE";
    final IconData icon = isResolved ? Icons.check_circle_outline : Icons.pending_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
