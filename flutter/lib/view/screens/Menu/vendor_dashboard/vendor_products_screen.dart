import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vendor_add_product_screen.dart';
import '../../../../controller/vendor_products_controller.dart';
import '../../../../model/vendor_product_model.dart';

class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VendorProductsController controller;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initController();
  }

  Future<void> _initController() async {
    final prefs = await SharedPreferences.getInstance();
    if (!Get.isRegistered<VendorProductsController>()) {
      controller = Get.put(VendorProductsController(preferences: prefs));
    } else {
      controller = Get.find<VendorProductsController>();
    }
    if (mounted) {
      setState(() {
        _isControllerReady = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF101010),
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
          "Mis Productos",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00FF88),
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF00FF88),
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 14),
          tabs: [
            const Tab(text: "Productos"),
            Tab(
              child: Obx(() {
                final count = controller.pendingCount;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Revisar"),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF88),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$count",
                          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FadeInRight(
        duration: const Duration(milliseconds: 600),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Get.to(() => const VendorAddProductScreen(), transition: Transition.rightToLeft);
              if (result == true) {
                controller.getVendorProducts();
              }
            },
            backgroundColor: const Color(0xFF00FF88),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.vendorProducts.value == null) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
        }

        return FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A2518),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: SafeArea(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsTab(),
                  _buildReviewTab(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductsTab() {
    final products = controller.activeProducts;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: _buildHeaderButton("Gestionar a granel", Colors.transparent, Colors.white.withOpacity(0.6), hasBorder: true),
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => controller.getVendorProducts(),
                  color: const Color(0xFF00FF88),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) => _buildProductCard(products[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildReviewTab() {
    final products = controller.reviewProducts;
    return products.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
            onRefresh: () => controller.getVendorProducts(),
            color: const Color(0xFF00FF88),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductCard(products[index], isReview: true),
            ),
          );
  }

  void _handleEditProduct(VendorProduct product) {
    Get.to(() => const VendorAddProductScreen(), arguments: product, transition: Transition.rightToLeft);
  }

  void _showDeleteProductConfirmation(VendorProduct product) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 60),
              const SizedBox(height: 20),
              const Text(
                "¿ESTÁS SEGURO?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "¿Estás seguro de eliminar el producto ${product.name}?",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("CANCELAR", style: TextStyle(color: Colors.white60)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        print('🗑️ [ELIMINANDO PRODUCTO] Nombre: ${product.name} | ID: ${product.id}');
                        Get.back();
                        await controller.deleteProduct(product.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("ELIMINAR", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // TAREA: Diferenciar entre Estado Vacío (Éxito) y Error (Fallo) - v1.2.9
    final bool isSuccess = controller.vendorProducts.value?.status == true;

    return RefreshIndicator(
      onRefresh: () => controller.getVendorProducts(),
      color: const Color(0xFF00FF88),
      backgroundColor: const Color(0xFF1A1A1A),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.white.withOpacity(0.1), size: 60),
                const SizedBox(height: 16),
                Text(
                  isSuccess ? "Aún no tienes productos creados" : "Error al cargar productos",
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontFamily: 'Poppins'),
                ),
                
                // TAREA: Mostrar botón de reintento SOLO si no fue exitosa (isSuccess == false)
                if (!isSuccess) ...[
                  const SizedBox(height: 32),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('🔄 [REINTENTO] Forzando recarga de productos...');
                        controller.getVendorProducts();
                      },
                      icon: const Icon(Icons.refresh_rounded, color: Colors.black, size: 20),
                      label: const Text(
                        "REINTENTAR CARGAR PRODUCTOS",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF88),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor: const Color(0xFF00FF88).withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Si el error persiste, informa al soporte técnico.",
                    style: TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String label, Color bgColor, Color textColor, {bool hasBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: hasBorder ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
      ),
    );
  }

  Widget _buildProductCard(VendorProduct product, {bool isReview = false}) {
    final bool isInfinite = product.stock < 0; 
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReview 
            ? Colors.orange.withOpacity(0.3) 
            : const Color(0xFF00FF88).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FF88).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00FF88))),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: const Color(0xFF00FF88).withOpacity(0.3),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              product.name.toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.w900, 
                                fontSize: 14, 
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.isTopProduct) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF88).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                              ),
                              child: const Text(
                                "Sugerido",
                                style: TextStyle(color: Color(0xFF00FF88), fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF00FF88), size: 18),
                          onPressed: () => _handleEditProduct(product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 18),
                          onPressed: () => _showDeleteProductConfirmation(product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PRECIO", 
                          style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "\$${product.price.toStringAsFixed(2)}", 
                          style: const TextStyle(
                            color: Color(0xFF00FF88),
                            fontWeight: FontWeight.w900, 
                            fontSize: 16
                          )
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "STOCK", 
                          style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isInfinite ? "INFINITO" : product.stock.toString(), 
                          style: TextStyle(
                            color: isInfinite ? const Color(0xFF00FF88) : Colors.white70, 
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                if (isReview) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Text(
                      (product.status.toString() == "1" ? "ACTIVO" : "PENDIENTE"),
                      style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
