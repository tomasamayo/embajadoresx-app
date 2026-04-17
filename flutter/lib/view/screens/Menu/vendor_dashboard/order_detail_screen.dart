import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../controller/vendor_orders_controller.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late VendorOrdersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<VendorOrdersController>();
    controller.getOrderDetails(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
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
          "DETALLE DE PEDIDO",
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
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF001A0F)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isDetailLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
            }

            final order = controller.orderDetail.value;
            if (order == null) {
              return const Center(child: Text("No se encontró el pedido", style: TextStyle(color: Colors.white)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: _buildHeader(order),
                  ),
                  const SizedBox(height: 30),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: _buildCustomerCard(order),
                  ),
                  const SizedBox(height: 30),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: _buildStatusSelector(order),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: _buildProductList(order),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ORDEN #${order.orderId}", style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(order.createdAt, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("TOTAL", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("\$${order.total}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(dynamic order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CLIENTE VIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildCustomerRow(Icons.person_outline, order.customer.name),
              const Divider(color: Colors.white10, height: 20),
              _buildCustomerRow(Icons.email_outlined, order.customer.email),
              const Divider(color: Colors.white10, height: 20),
              _buildCustomerRow(Icons.phone_outlined, order.customer.phone),
              const Divider(color: Colors.white10, height: 20),
              _buildCustomerRow(Icons.location_on_outlined, "${order.customer.city}, ${order.customer.country}"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00FF88), size: 18),
        const SizedBox(width: 15),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 14))),
      ],
    );
  }

  Widget _buildStatusSelector(dynamic order) {
    final List<Map<String, String>> statuses = [
      {'label': 'Pendiente', 'value': '0'},
      {'label': 'En Proceso', 'value': '1'},
      {'label': 'Completado', 'value': '2'},
      {'label': 'Cancelado', 'value': '3'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ESTADO DEL PEDIDO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: order.status,
              dropdownColor: const Color(0xFF161B22),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00FF88)),
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              items: statuses.map((s) {
                return DropdownMenuItem<String>(
                  value: s['value'],
                  child: Text(s['label']!.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.updateOrderStatus(order.id, val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(dynamic order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PRODUCTOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
        const SizedBox(height: 15),
        ...order.products.map((product) => Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.white10),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white10),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("${product.quantity} x \$${product.price}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text("\$${product.total}", style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold)),
                ],
              ),
            )),
      ],
    );
  }
}
