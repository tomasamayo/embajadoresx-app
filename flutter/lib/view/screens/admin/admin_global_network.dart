import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/admin_controller.dart';
import '../../../model/admin_model.dart';
import 'package:animate_do/animate_do.dart';

class AdminGlobalNetworkScreen extends StatefulWidget {
  const AdminGlobalNetworkScreen({super.key});

  @override
  State<AdminGlobalNetworkScreen> createState() => _AdminGlobalNetworkScreenState();
}

class _AdminGlobalNetworkScreenState extends State<AdminGlobalNetworkScreen> {
  final AdminController controller = Get.put(AdminController());

  static const Color _neon = Color(0xFF00FF88);
  static const Color _card = Color(0xFF111916);
  static const Color _cardBorder = Color(0xFF1E2D25);

  @override
  void initState() {
    super.initState();
    controller.getGlobalNetwork();
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
                  if (controller.isLoadingNetwork.value) {
                    return _buildLoading();
                  }
                  if (controller.rootNodes.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildTree();
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
                "RED GLOBAL",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 2,
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
            child: const Icon(Icons.account_tree_outlined, color: _neon, size: 18),
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
          Text("Cargando árbol de red...",
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono central con glow
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _neon.withOpacity(0.05),
                border: Border.all(color: _neon.withOpacity(0.15), width: 1.5),
                boxShadow: [
                  BoxShadow(color: _neon.withOpacity(0.08), blurRadius: 30, spreadRadius: 8),
                ],
              ),
              child: Icon(Icons.hub_outlined, color: _neon.withOpacity(0.6), size: 44),
            ),
            const SizedBox(height: 28),
            const Text(
              "RED VACÍA",
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "El administrador aún no tiene\nafiliados registrados en su red.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            // Nodo raíz visual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _neon.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(color: _neon.withOpacity(0.05), blurRadius: 20),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_neon.withOpacity(0.3), _neon.withOpacity(0.1)],
                      ),
                      border: Border.all(color: _neon.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Color(0xFF00FF88), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nodo Raíz — Admin",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text(
                        "Sin referidos directo",
                        style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _neon.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _neon.withOpacity(0.2)),
                    ),
                    child: const Text("0", style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTree() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      itemCount: controller.rootNodes.length,
      itemBuilder: (context, index) {
        return FadeInDown(
          delay: Duration(milliseconds: index * 60),
          child: _buildNetworkNode(controller.rootNodes[index], level: 0),
        );
      },
    );
  }

  Widget _buildNetworkNode(GlobalNetworkNode node, {int level = 0}) {
    bool hasChildren = node.children.isNotEmpty;
    final Color accent = level == 0 ? _neon : _neon.withOpacity(0.6 - (level * 0.1).clamp(0, 0.4));

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.15 - (level * 0.02).clamp(0, 0.1))),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Theme(
            data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey(node.id),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.1),
                  border: Border.all(color: accent.withOpacity(0.25)),
                ),
                child: node.profileAvatar != null && node.profileAvatar!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          node.profileAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.person_outline, color: accent, size: 18),
                        ),
                      )
                    : Icon(Icons.person_outline, color: accent, size: 18),
              ),
              title: Text(
                "${node.firstname} ${node.lastname}".trim().isEmpty ? "Usuario Principal" : "${node.firstname} ${node.lastname}",
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Text(
                      "ID: ${node.id}",
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    if (hasChildren) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${node.children.length} afiliados",
                          style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: hasChildren
                  ? Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 22)
                  : const SizedBox.shrink(),
              childrenPadding: const EdgeInsets.only(left: 24, bottom: 12, right: 8),
              children: node.children
                  .map((child) => _buildNetworkNode(child, level: level + 1))
                  .toList(),
            ),
          ),
        ),
        if (level == 0 && !hasChildren)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FadeIn(
              child: Text(
                "No hay referidos en la red todavía.",
                style: TextStyle(
                  color: _neon.withOpacity(0.4),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
