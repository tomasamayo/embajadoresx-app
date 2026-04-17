import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/service/admin_wallet_service.dart';
import 'package:animate_do/animate_do.dart';

class AdminValidateCommissionsScreen extends StatefulWidget {
  const AdminValidateCommissionsScreen({super.key});

  @override
  State<AdminValidateCommissionsScreen> createState() => _AdminValidateCommissionsScreenState();
}

class _AdminValidateCommissionsScreenState extends State<AdminValidateCommissionsScreen> {
  final AdminWalletService _service = AdminWalletService.instance;

  @override
  void initState() {
    super.initState();
    _service.fetchPendingCommissions();
  }

  Future<void> _updateStatus(int id, int status) async {
    // Mostrar loader circular pequeño
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
      barrierDismissible: false,
    );
    
    final success = await _service.updateCommissionStatus(id, status);
    
    Get.back(); // Cerrar loader

    if (success) {
      Get.snackbar(
        status == 1 ? "Comisión Aprobada" : "Comisión Rechazada", 
        "La operación se realizó con éxito.",
        backgroundColor: status == 1 ? Colors.green : Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM
      );
    } else {
      Get.snackbar("Error", "No se pudo actualizar el estado.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFF00FF88);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF003300)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: neonGreen, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Validar Comisiones",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (_service.isLoadingCommissions.value) {
                    return const Center(child: CircularProgressIndicator(color: neonGreen));
                  }

                  if (_service.pendingList.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => _service.fetchPendingCommissions(),
                    color: neonGreen,
                    backgroundColor: Colors.black,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _service.pendingList.length,
                        itemBuilder: (context, index) {
                          final item = _service.pendingList[index];
                          return _buildCommissionCard(item);
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 100, color: Colors.white.withOpacity(0.03)),
          const SizedBox(height: 25),
          const Text("LIBRE DE PENDIENTES", 
            style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _service.fetchPendingCommissions(), 
            child: const Text("Refrescar", style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(dynamic item) {
    const Color neonGreen = Color(0xFF00FF88);
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF001A0D), // Verde muy oscuro
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: neonGreen.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ]
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: neonGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.person_outline, color: neonGreen, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("@${item['username'] ?? 'Cliente'}", 
                        style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        _translateComment(item['comment']), 
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(_formatDate(item['created_at']), 
                        style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
                Text(
                  item['amount_with_format'] ?? "\$${item['amount']}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
          ),
          Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _updateStatus(int.parse(item['id'].toString()), 2),
                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                    label: const Text("RECHAZAR", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(int.parse(item['id'].toString()), 1),
                    icon: const Icon(Icons.check_rounded, color: Colors.black, size: 20),
                    label: const Text("APROBAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _translateComment(String? originalComment) {
    if (originalComment == null || originalComment.isEmpty) return 'Comisión de transacción';
    String translated = originalComment.replaceAll('<br>', '\n').replaceAll('<br/>', '\n');
    translated = translated.replaceAll(RegExp(r'order_id=\d+\s*\|\s*'), '');
    translated = translated.replaceAll('Commission for order Id', 'Comisión por pedido');
    translated = translated.replaceAll('Order By :', 'Cliente:');
    translated = translated.replaceAll('Sale done from ip_message', 'Origen: IP Externa');
    translated = translated.replaceAll('Membership plan Bonus', 'Bono de Membresía');
    return translated.trim();
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parts = rawDate.split(' ');
      if (parts.length >= 1) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          final year = dateParts[0];
          final month = _getMonthName(dateParts[1]);
          final day = dateParts[2];
          return "$day $month $year";
        }
      }
      return rawDate;
    } catch (e) {
      return rawDate;
    }
  }

  String _getMonthName(String m) {
    switch (m) {
      case '01': return 'Ene'; case '02': return 'Feb'; case '03': return 'Mar';
      case '04': return 'Abr'; case '05': return 'May'; case '06': return 'Jun';
      case '07': return 'Jul'; case '08': return 'Ago'; case '09': return 'Sep';
      case '10': return 'Oct'; case '11': return 'Nov'; case '12': return 'Dic';
      default: return m;
    }
  }
}
