import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/service/admin_wallet_service.dart';
import 'package:animate_do/animate_do.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen> {
  final AdminWalletService _service = AdminWalletService.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await _service.getAdminWallet();
    
    if (result == null) {
      Get.snackbar(
        "🔒 Error de Seguridad", 
        "El servidor bloqueó la petición (CORS/Redirect)",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }

    setState(() {
      _data = result;
      _isLoading = false;
    });
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
                        "Billetera Global",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 40), 
                  ],
                ),
              ),

              Expanded(
                child: _isLoading 
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: neonGreen),
                          const SizedBox(height: 15),
                          Text("Cargando finanzas...", style: TextStyle(color: neonGreen.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: neonGreen,
                      backgroundColor: Colors.black,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CARD DE BALANCE PRINCIPAL (v1.3.4 - Verde Esmeralda)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00FF88).withOpacity(0.25), // Verde Esmeralda brillante
                                      const Color(0xFF003300).withOpacity(0.5), // Verde Oscuro profundo
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FF88).withOpacity(0.1),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    )
                                  ]
                                ),
                                child: Column(
                                  children: [
                                    Text("BALANCE TOTAL ADMIN", 
                                      style: TextStyle(color: const Color(0xFF00FF88).withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                    const SizedBox(height: 15),
                                    Text(
                                      "\$${_data?['admin_balance'] ?? '0.00'}",
                                      style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Ventas de Tienda Local: \$ ${_data?['summary']?['sale_localstore_total']?.toString() ?? '0.00'}",
                                      style: TextStyle(color: neonGreen.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 20),
                                    const Divider(color: Colors.white10),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(
                                          "En Espera", 
                                          _data?['wallet_stats']?['on_hold']?['amount']?.toString() ?? '0.00', 
                                          Colors.orange
                                        ),
                                        _buildStatItem(
                                          "Pendiente", 
                                          _data?['wallet_stats']?['unpaid']?['amount']?.toString() ?? '0.00', 
                                          Colors.redAccent
                                        ),
                                        _buildStatItem(
                                          "Pagado", 
                                          _data?['wallet_stats']?['completed']?['amount']?.toString() ?? '0.00', 
                                          neonGreen
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              const SizedBox(height: 35),
                              const Text("HISTORIAL DE MOVIMIENTOS", 
                                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 20),

                              // LISTA DE TRANSACCIONES
                              if (_data?['transactions'] == null || (_data?['transactions'] as List).isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 50),
                                    child: Text("No hay movimientos registrados", style: TextStyle(color: Colors.white24)),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: (_data?['transactions'] as List).length,
                                  itemBuilder: (context, index) {
                                    final tx = _data?['transactions'][index];
                                    return FadeInUp(
                                      delay: Duration(milliseconds: 100 * index),
                                      from: 20,
                                      child: _buildTransactionItem(tx),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateComment(String? originalComment) {
    if (originalComment == null || originalComment.isEmpty) return 'Transacción de sistema';
    String translated = originalComment.replaceAll('<br>', '\n').replaceAll('<br/>', '\n');
    
    // 1. Limpiar la basura técnica (v1.4.1)
    translated = translated.replaceAll(RegExp(r'order_id=\d+\s*\|\s*'), '');
    
    // 2. Traducciones mejoradas
    translated = translated.replaceAll('Commission for order Id', 'Comisión por pedido');
    translated = translated.replaceAll('Order By :', 'Cliente:');
    translated = translated.replaceAll('Sale done from ip_message', 'Origen: IP Externa');
    translated = translated.replaceAll('Membership plan Bonus', 'Bono de Membresía');
    translated = translated.replaceAll('Recarga administrativa', 'Recarga manual');
    translated = translated.replaceAll('Vendor withdrawal', 'Retiro de vendedor');
    translated = translated.replaceAll('Request', 'Solicitud');
    
    return translated.trim();
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      // Intentamos un parseo simple si el formato coincide con 2026-04-02 17:31:27
      final parts = rawDate.split(' ');
      if (parts.length >= 1) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          final year = dateParts[0];
          final month = _getMonthName(dateParts[1]);
          final day = dateParts[2];
          final time = parts.length > 1 ? parts[1].substring(0, 5) : '';
          return "$day $month $year, $time";
        }
      }
      return rawDate;
    } catch (e) {
      return rawDate;
    }
  }

  String _getMonthName(String m) {
    switch (m) {
      case '01': return 'Ene';
      case '02': return 'Feb';
      case '03': return 'Mar';
      case '04': return 'Abr';
      case '05': return 'May';
      case '06': return 'Jun';
      case '07': return 'Jul';
      case '08': return 'Ago';
      case '09': return 'Sep';
      case '10': return 'Oct';
      case '11': return 'Nov';
      case '12': return 'Dic';
      default: return m;
    }
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 5),
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    const Color neonGreen = Color(0xFF00FF88);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: neonGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: neonGreen, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _translateComment(tx['comment']), 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(_formatDate(tx['created_at']), style: const TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "${tx['amount_with_format'] ?? tx['amount']}",
            style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
