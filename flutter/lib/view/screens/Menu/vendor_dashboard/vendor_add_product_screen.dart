import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../../../controller/vendor_add_product_controller.dart';
import '../../../../model/vendor_category_model.dart';
import '../../../../model/vendor_product_model.dart';

class VendorAddProductScreen extends StatefulWidget {
  final VendorProduct? product;
  const VendorAddProductScreen({super.key, this.product});

  @override
  State<VendorAddProductScreen> createState() => _VendorAddProductScreenState();
}

class _VendorAddProductScreenState extends State<VendorAddProductScreen> {
  late VendorAddProductController controller;
  bool _isControllerReady = false;

  // TAREA 1: LLAVES UNICAS PARA EVITAR DUPLICIDAD
  final GlobalKey<FormState> _mainFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _commissionFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      controller = Get.put(VendorAddProductController(preferences: prefs));
      
      // TAREA 1: ASIGNACIÓN INMEDIATA (Independiente de categorías)
      // Soporta tanto constructor como Get.arguments para máxima flexibilidad
      final VendorProduct? product = widget.product ?? Get.arguments;
      
      if (product != null) {
        controller.populateFormFields(product);
      }

      // Forzamos la carga de categorías si la lista está vacía
      if (controller.categories.isEmpty) {
        await controller.getCategories();
      }

      // TAREA 2: SINCRONIZACIÓN DE CATEGORÍA (Post-carga)
      if (product != null && controller.selectedCategory.value == null) {
        if (product.categoryId.isNotEmpty && controller.categories.isNotEmpty) {
          controller.selectedCategory.value = controller.categories.firstWhereOrNull(
            (cat) => cat.id.toString() == product.categoryId
          );
        }
      }
    } catch (e) {
      print('❌ ERROR EN _initController: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isControllerReady = true;
        });
      }
    }
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
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FF88), Color(0xFF008F4F)],
          ).createShader(bounds),
          child: const Text(
            "FORJA DE PRODUCTOS",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Poppins', letterSpacing: 1.5),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
        }

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0A0A), Color(0xFF001A0F)],
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.08),
                      blurRadius: 200,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Form(
                      key: _mainFormKey,
                      child: Column(
                        children: [
                          _buildNeonExpansionTile(
                            title: "DATOS DEL PRODUCTO",
                            icon: Icons.inventory_2_outlined,
                            initiallyExpanded: true,
                            children: [
                              _buildTextField("Nombre del producto", controller.nameController, Icons.shopping_bag_outlined, hintText: "Introduce el nombre del producto"),
                              _buildTextField("SKU", controller.skuController, Icons.fingerprint, hintText: "Introduce el codigo unico del producto (SKU)"),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField("Precio de venta del producto", controller.msrpPriceController, Icons.monetization_on_outlined, keyboardType: TextInputType.number, hintText: "150.00")),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField("Precio del producto", controller.priceController, Icons.monetization_on_outlined, keyboardType: TextInputType.number, hintText: "150.00")),
                                ],
                              ),
                              _buildTextField("Stock", controller.quantityController, Icons.all_inbox_outlined, keyboardType: TextInputType.number, hintText: "Cantidad disponible"),
                              const SizedBox(height: 10),
                              _buildCategoryField(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildNeonExpansionTile(
                            title: "GALERIA MULTIMEDIA",
                            icon: Icons.auto_awesome_motion_outlined,
                            children: [
                              _buildImagePicker(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildNeonExpansionTile(
                            title: "CONFIGURACION CYBER",
                            icon: Icons.settings_remote_outlined,
                            children: [
                              _buildNeonSwitch("Visibilidad en Tienda", controller.onStore, Icons.remove_red_eye_outlined),
                              _buildNeonSwitch("Envio a Domicilio", controller.allowShipping, Icons.local_shipping_outlined),
                              _buildNeonSwitch("Permitir subir archivo", controller.allowUploadFile, Icons.upload_file_outlined), // TAREA 2
                              _buildNeonSwitch("Muy pronto", controller.productIsComingSoon, Icons.timer_outlined), // TAREA 2
                              const SizedBox(height: 15),
                              _buildTagSystem(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildNeonExpansionTile(
                            title: "TIPO DE PRODUCTO",
                            icon: Icons.hub_outlined,
                            children: [
                              _buildProductTypeSelector(),
                              const SizedBox(height: 20),
                              if (controller.productType.value == 'downloadable') _buildDownloadableFilesSection(),
                              if (controller.productType.value == 'video') _buildTextField("Enlace de Video", controller.videoUrlController, Icons.play_lesson_outlined, hintText: "https://youtube.com/watch?v=..."),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildNeonExpansionTile(
                            title: "NARRATIVA DEL PRODUCTO",
                            icon: Icons.auto_stories_outlined,
                            children: [
                              _buildTextField("Descripcion corta", controller.shortDescController, Icons.bolt, maxLines: 2, hintText: "Un resumen de tu producto (max 150 caracteres)"),
                              _buildTextField("Descripcion larga", controller.longDescController, Icons.history_edu, maxLines: 5, hintText: "Introduce la descripcion detallada del producto"),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildNeonExpansionTile(
                            title: "Variantes de producto", // TAREA 1: Corrección de texto
                            icon: Icons.layers_outlined,
                            children: [_buildVariantsSection()],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _commissionFormKey,
                      child: _buildNeonExpansionTile(
                        title: "COMISION",
                        icon: Icons.percent_outlined,
                        children: [
                          _buildCommissionSection(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildNeonExpansionTile(
                      title: "COMENTARIOS DEL ADMINISTRADOR",
                      icon: Icons.comment_bank_outlined,
                      children: [
                        _buildAdminCommentField(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSaveButton(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            
            if (controller.isSaving.value) _buildLoadingOverlay(),
          ],
        );
      }),
    );
  }

  Widget _buildNeonExpansionTile({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return StatefulBuilder(
      key: ValueKey('expansion_tile_' + title), // Llave unica basada en el titulo
      builder: (context, setState) {
        bool isExpanded = initiallyExpanded;
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0.15, end: isExpanded ? 0.8 : 0.15),
          builder: (context, opacity, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00FF88).withOpacity(opacity),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withOpacity(opacity * 0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  onExpansionChanged: (val) => setState(() => isExpanded = val),
                  initiallyExpanded: initiallyExpanded,
                  leading: Icon(icon, color: const Color(0xFF00FF88), size: 24),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    ),
                  ),
                  trailing: Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF00FF88),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: children,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryField() {
    return Column(
      key: const ValueKey('category_field_container'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECCIONAR CATEGORIA",
          style: TextStyle(color: Color(0xFF00FF88), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        const SizedBox(height: 8),
        DropdownSearch<VendorCategory>(
          items: (filter, infiniteScrollProps) => controller.categories
              .where((cat) => cat.name.toLowerCase().contains(filter.toLowerCase()))
              .toList(),
          itemAsString: (VendorCategory u) => u.name.toString(),
          compareFn: (item, selectedItem) => item.id == selectedItem.id,
          onChanged: (VendorCategory? data) => controller.selectedCategory.value = data,
          selectedItem: controller.selectedCategory.value,
          enabled: !controller.isLoadingCategories.value,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: controller.isLoadingCategories.value ? "Cargando categorias..." : "Seleccionar categoria...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
              prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF00FF88), size: 20),
              suffixIcon: controller.isLoadingCategories.value 
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Color(0xFF00FF88), strokeWidth: 2)),
                  )
                : null,
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.15), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            menuProps: const MenuProps(
              backgroundColor: Color(0xFF0D1117),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                side: BorderSide(color: Color(0xFF00FF88), width: 0.5),
              ),
            ),
            searchFieldProps: TextFieldProps(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Filtrar...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF88)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF88))),
              ),
            ),
            itemBuilder: (context, item, isDisabled, isSelected) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00FF88).withOpacity(0.1) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: const Color(0xFF00FF88),
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.name,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF00FF88) : Colors.white70,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HISTORIAL DE MENSAJES",
          style: TextStyle(color: Color(0xFF00FF88), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        
        // TAREA 1: Sistema de Chat (Burbujas - Imagen 51 y 54)
        Obx(() {
          if (controller.previousAdminNote.value.isEmpty) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
              ),
              child: const Text(
                "No hay mensajes del administrador aún",
                style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            );
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88).withOpacity(0.15), // Burbuja Verde (Web Style)
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.4), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Color(0xFF00FF88), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "ADMINISTRADOR",
                      style: TextStyle(color: const Color(0xFF00FF88).withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  controller.previousAdminNote.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5, fontFamily: 'Poppins'),
                ),
              ],
            ),
          );
        }),

        const Text(
          "NUEVO MENSAJE",
          style: TextStyle(color: Color(0xFF00FF88), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1), width: 0.5),
          ),
          child: TextField(
            controller: controller.adminCommentController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: "Escriba su mensaje y guarde el producto para enviar",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(Icons.chat_bubble_outline, color: const Color(0xFF00FF88).withOpacity(0.7), size: 20),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, String? hintText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF00FF88), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF00FF88).withOpacity(0.7), size: 20),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.15), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonSwitch(String label, RxBool value, IconData icon) {
    return Obx(() => Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile.adaptive(
            value: value.value,
            onChanged: (val) => value.value = val,
            secondary: Icon(icon, color: const Color(0xFF00FF88), size: 22),
            title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
            activeColor: const Color(0xFF00FF88),
            activeTrackColor: const Color(0xFF00FF88).withOpacity(0.3),
          ),
    ));
  }

  Widget _buildTagSystem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ETIQUETAS DEL PRODUCTO (COMA O ESPACIO)",
          style: TextStyle(color: Color(0xFF00FF88), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        const SizedBox(height: 10),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.productTags.map((tag) => Chip(
            label: Text(tag, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF00FF88),
            deleteIcon: const Icon(Icons.close, size: 14, color: Colors.black),
            onDeleted: () => controller.removeTag(tag),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          )).toList(),
        )),
        const SizedBox(height: 10),
        TextField(
          controller: controller.tagsController,
          onChanged: (val) {
            if (val.endsWith(",") || val.endsWith(" ")) {
              controller.addTag(val.substring(0, val.length - 1));
            }
          },
          onSubmitted: (val) => controller.addTag(val),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Ej: premium, nuevo, oferta...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final VendorProduct? product = widget.product ?? Get.arguments;
    return GestureDetector(
      onTap: () => controller.pickFeaturedImage(),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2), width: 2),
        ),
        child: Obx(() {
          if (controller.featuredImageBytes.value != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.memory(controller.featuredImageBytes.value!, fit: BoxFit.cover),
            );
          } else if (product != null && product.imageUrl.isNotEmpty) {
            // TAREA 3: CARGAR IMAGEN ACTUAL EN EDICIÓN
            return ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 48),
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: const Color(0xFF00FF88).withOpacity(0.5), size: 48),
                const SizedBox(height: 12),
                const Text("SUBIR IMAGEN DESTACADA", style: TextStyle(color: Color(0xFF00FF88), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildProductTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          _buildTypeOption("virtual", "VIRTUAL", Icons.cloud_outlined),
          _buildTypeOption("downloadable", "DESCARGA", Icons.download_outlined),
          _buildTypeOption("video", "VIDEO", Icons.play_circle_outline),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String type, String label, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.productType.value = type,
        child: Obx(() {
          bool isSelected = controller.productType.value == type;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00FF88) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(icon, color: isSelected ? Colors.black : Colors.white38, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(color: isSelected ? Colors.black : Colors.white38, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDownloadableFilesSection() {
    return Column(
      children: [
        ...controller.downloadableFiles.asMap().entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  const Icon(Icons.file_present_rounded, color: Color(0xFF00FF88), size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value['name'], style: const TextStyle(color: Colors.white, fontSize: 13))),
                  IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20), onPressed: () => controller.removeDownloadableFile(entry.key)),
                ],
              ),
            )),
        ElevatedButton.icon(
          onPressed: () => controller.addDownloadableFile(),
          icon: const Icon(Icons.cloud_upload_outlined, size: 20),
          label: const Text("ADJUNTAR ARCHIVO MAESTRO", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF88).withOpacity(0.1),
            foregroundColor: const Color(0xFF00FF88),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsSection() {
    return Column(
      children: [
        ...controller.variants.asMap().entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF00FF88).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF00FF88), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${entry.value['type']}: ${entry.value['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("Incremento: +\$${entry.value['price']}", style: const TextStyle(color: Color(0xFF00FF88), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22), onPressed: () => controller.removeVariant(entry.key)),
                ],
              ),
            )),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showVariantDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF88),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text("FORJAR NUEVA VARIANTE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.1)),
        ),
      ],
    );
  }

  Widget _buildCommissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommissionRow(
          label: "Comision de clic",
          typeValue: controller.affiliateClickCommissionType,
          onTypeChanged: (val) => controller.affiliateClickCommissionType.value = val!,
          options: ['default', 'fixed'],
          amountController: controller.affiliateClickAmount,
          countController: controller.affiliateClickCount,
          showCount: true,
        ),
        const SizedBox(height: 20),
        Obx(() => _buildCommissionRow(
          label: "Comision de venta",
          typeValue: controller.affiliateSaleCommissionType,
          onTypeChanged: (val) => controller.affiliateSaleCommissionType.value = val!,
          options: ['default', ...controller.commissionTypes.map((e) => e['value']!)],
          labels: {'default': 'Default', ...Map.fromIterable(controller.commissionTypes, key: (e) => e['value'], value: (e) => e['label'])},
          amountController: controller.affiliateCommissionValue,
        )),
        const Divider(color: Colors.white10, height: 40),
        _buildSectionSubtitle("FINALIZAR COMISION"),
        const SizedBox(height: 16),
        _buildFinalCommissionSummary(),
      ],
    );
  }

  Widget _buildCommissionRow({
    required String label,
    required RxString typeValue,
    required Function(String?) onTypeChanged,
    required List<String> options,
    Map<String, String>? labels,
    required TextEditingController amountController,
    TextEditingController? countController,
    bool showCount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1), width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: options.contains(typeValue.value) ? typeValue.value : 'default',
                    dropdownColor: const Color(0xFF1A1A1A),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00FF88), size: 20),
                    items: options.map((opt) => DropdownMenuItem(
                      value: opt, 
                      child: Text(
                        labels != null ? (labels[opt] ?? opt) : (opt == 'default' ? "Default" : opt == 'fixed' ? "Fixed" : "Percentage (%)"), 
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      )
                    )).toList(),
                    onChanged: onTypeChanged,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (typeValue.value != 'default') 
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    if (showCount && typeValue.value == 'fixed' && countController != null) ...[
                      Expanded(
                        child: _buildCompactTextField(
                          controller: countController,
                          hint: "Clicks",
                          icon: Icons.mouse_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactTextField(
                          controller: amountController,
                          hint: "Amount",
                          icon: Icons.attach_money,
                        ),
                      ),
                    ] else
                      Expanded(
                        child: _buildCompactTextField(
                          controller: amountController,
                          hint: typeValue.value == 'percentage' ? "Valor (%)" : "Valor",
                          icon: typeValue.value == 'percentage' ? Icons.percent : Icons.attach_money,
                        ),
                      ),
                  ],
                ),
              ),
            if (typeValue.value == 'default') 
              const Expanded(flex: 3, child: SizedBox()),
          ],
        )),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF00FF88).withOpacity(0.5), size: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFinalCommissionSummary() {
    return Row(
      children: [
        _buildSummaryBox("PROVEEDOR", "0"),
        const SizedBox(width: 10),
        _buildSummaryBox("ADMINISTRACION", "0"),
        const SizedBox(width: 10),
        _buildSummaryBox("AFILIADO", "0"),
      ],
    );
  }

  Widget _buildSummaryBox(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF00FF88), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  void _showVariantDialog() {
    final typeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22).withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "CONFIGURACION DE VARIANTE",
                    style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField("Atributo (Color, Talla...)", typeCtrl, Icons.tune_outlined),
                  _buildTextField("Valor (Zafiro, XXL...)", nameCtrl, Icons.edit_note_outlined),
                  _buildTextField("Incremento de Precio", priceCtrl, Icons.add_chart_outlined, keyboardType: TextInputType.number),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("CANCELAR", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (typeCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                              controller.addVariant(typeCtrl.text, nameCtrl.text, priceCtrl.text.isEmpty ? "0" : priceCtrl.text);
                              Get.back();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF88),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("FORJAR", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF00FF88), strokeWidth: 5),
              const SizedBox(height: 24),
              FadeIn(
                child: const Text(
                  "SINCRONIZANDO CON LA RED ESMERALDA...",
                  style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final VendorProduct? product = widget.product ?? Get.arguments;
    return FadeInUp(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF00FF88), Color(0xFF008F4F)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.isSaving.value ? null : () => controller.saveProduct(id: product?.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            product != null ? "GUARDAR CAMBIOS" : "GUARDAR Y ENVIAR A REVISION",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }
}
