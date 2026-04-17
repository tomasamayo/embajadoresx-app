import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controller/vendor_orders_controller.dart';
import 'order_detail_screen.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  late VendorOrdersController controller;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final prefs = await SharedPreferences.getInstance();
    controller = Get.put(VendorOrdersController(preferences: prefs));
    setState(() {
      _isControllerReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "MIS PEDIDOS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF001A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TAREA 1: BOTONES FUERA DE OBX (Estáticos)
              _buildModernSearchHeader(),
              
              // TAREA 1: OBX ÚNICAMENTE PARA EL CONTENIDO QUE CAMBIA
              Expanded(
                child: Obx(() {
                  // Si está cargando y no hay órdenes, mostramos el loading central
                  if (controller.isLoading.value && controller.orders.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
                  }

                  // TAREA 1: La variable observable 'orders.isEmpty' quita el cuadro rojo
                  if (controller.orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.getOrders(),
                    color: const Color(0xFF00FF88),
                    backgroundColor: const Color(0xFF1A1A1A),
                    child: _buildOrdersList(),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSearchHeader() {
    final List<Map<String, String>> chipsToUse = [
      {'name': 'Todos', 'id': ''},
      {'name': 'Pago', 'id': '0'},
      {'name': 'Completo', 'id': '1'},
      {'name': 'Error Total', 'id': '2'},
      {'name': 'Denegado', 'id': '3'},
      {'name': 'Vencido', 'id': '4'},
      {'name': 'Fallido', 'id': '5'},
      {'name': 'Pendiente', 'id': '6'},
      {'name': 'Procesado', 'id': '7'},
      {'name': 'Reembolsado', 'id': '8'},
      {'name': 'Invertido', 'id': '9'},
      {'name': 'Anulado', 'id': '10'},
      {'name': 'Rev. Cancelada', 'id': '11'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: chipsToUse.length,
          itemBuilder: (context, index) {
            final chip = chipsToUse[index];
            
            return Obx(() {
              final isSelected = controller.selectedFilter.value == chip['name'];
              
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: InkWell(
                  onTap: () => controller.applyFilter(chip['name']!, chip['id']!),
                  borderRadius: BorderRadius.circular(15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFF00332B), Color(0xFF00E676)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey[850]!,
                        width: 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        )
                      ] : [],
                    ),
                    child: Text(
                      chip['name']!.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.orders.length,
      itemBuilder: (context, index) {
        final order = controller.orders[index];
        return FadeInUp(
          duration: Duration(milliseconds: 400 + (index * 100)),
          child: InkWell(
            onTap: () {
              print('📦 [PEDIDOS] Abriendo detalle del pedido ID: ${order.id}');
              Get.to(() => OrderDetailScreen(orderId: order.id), transition: Transition.rightToLeft);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1), width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "#${order.orderId}",
                            style: const TextStyle(
                              color: Color(0xFF00FF88),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      _buildStatusBadge(order.statusText, order.status),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TOTAL", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("\$${order.totalAmount}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("FECHA", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(order.createdAt, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String statusText, String statusId) {
    Color color = Colors.grey;
    
    switch (statusId) {
      case '1': // Completado
        color = const Color(0xFF00FF88);
        break;
      case '6': // Pendientes
      case '13':
      case '0':
        color = const Color(0xFFFFB800);
        break;
      case '3': // Cancelados
      case '10':
        color = const Color(0xFFFF5252);
        break;
      default:
        if (statusText.toLowerCase().contains('pend') || statusText.toLowerCase().contains('proc')) {
          color = const Color(0xFFFFB800);
        } else if (statusText.toLowerCase().contains('comp') || statusText.toLowerCase().contains('exito')) {
          color = const Color(0xFF00FF88);
        } else if (statusText.toLowerCase().contains('canc') || statusText.toLowerCase().contains('anul')) {
          color = const Color(0xFFFF5252);
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 24),
            const Text(
              "NO SE ENCONTRARON DATOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Ningún pedido coincide con el filtro seleccionado",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
