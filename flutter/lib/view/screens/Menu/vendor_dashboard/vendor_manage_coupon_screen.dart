import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controller/vendor_coupons_controller.dart';
import '../../../../controller/vendor_products_controller.dart';
import '../../../../model/vendor_product_model.dart';
import '../../../../model/vendor_coupon_model.dart';

class VendorManageCouponScreen extends StatefulWidget {
  final VendorCoupon? coupon;
  const VendorManageCouponScreen({super.key, this.coupon});

  @override
  State<VendorManageCouponScreen> createState() => _VendorManageCouponScreenState();
}

class _VendorManageCouponScreenState extends State<VendorManageCouponScreen> {
  late VendorCouponsController controller;
  bool _isControllerReady = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _usesTotalController = TextEditingController();

  String _selectedType = 'percentage';
  String _selectedStatus = '1';
  String _allowFor = 's';
  List<String> _selectedProductIds = [];

  @override
  void initState() {
    super.initState();
    // TAREA 1: ASIGNACIÓN SÍNCRONA E INMEDIATA (Con filtro de caracteres)
    if (widget.coupon != null) {
      final coupon = widget.coupon!;
      
      // TAREA 1: LOG DE RASTREO JSON PARA ENCONTRAR LA LLAVE
      print('DEBUG JSON COMPLETO (MODELO): ${coupon.toString()}');

      // Función interna para limpiar caracteres extraños (UTF-8 stability)
      String clean(String? text) {
        if (text == null) return "";
        return text.replaceAll('\uFFFD', '').trim();
      }

      // TAREA 1: FUNCIÓN DE LIMPIEZA DINÁMICA (Regex)
      String cleanDiscount(String value) {
        try {
          double val = double.parse(value);
          // Regex para eliminar ceros innecesarios a la derecha y el punto decimal si no hay decimales significativos
          return val.toString().replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
        } catch (e) {
          return value;
        }
      }

      // Asignación directa con limpieza - TAREA 1: LLAVE 'CODE'
      _nameController.text = clean(coupon.name); 
      _codeController.text = clean(coupon.code);
      
      // TAREA 3: REASIGNACIÓN EN EL EDITOR (Valor limpio sin símbolos)
      _discountController.text = cleanDiscount(coupon.discount.toString());

      _dateStartController.text = clean(coupon.dateStart);
      _dateEndController.text = clean(coupon.dateEnd);
      _usesTotalController.text = coupon.usesTotal.toString();
      
      // Lógica de Dropdowns blindada
      _selectedType = (coupon.type.toLowerCase() == 'percentage' || coupon.type.toLowerCase() == 'fixed')
          ? coupon.type.toLowerCase()
          : 'percentage';

      _selectedStatus = coupon.status.toString();
      
      final String rawAllowFor = coupon.allowFor.toString().toLowerCase();
      _allowFor = (rawAllowFor == 'p' || rawAllowFor == 's') ? rawAllowFor : 's'; 

      // TAREA 4: LOG DE VERIFICACIÓN POS-ACTUALIZACIÓN
      print('✅ [API OK] Nombre: ${_nameController.text} | Código (code): ${_codeController.text}');
    }

    // TAREA 2: PROTECCIÓN DE NULOS EN CARGA ASÍNCRONA
    try {
      _initController();
    } catch (e) {
      print('[CRASH PREVENTED] Error en _initController: $e');
    }
  }

  Future<void> _initController() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // TAREA 1: Inyectar el controlador faltante de forma segura
      if (!Get.isRegistered<VendorCouponsController>()) {
        controller = Get.put(VendorCouponsController(preferences: prefs));
      } else {
        controller = Get.find<VendorCouponsController>();
      }
      
      // TAREA 2: Manejo seguro de la lista de productos
      print('[CUPONES] Cargando lista de productos para vinculacion...');
      
      if (!Get.isRegistered<VendorProductsController>()) {
        Get.lazyPut(() => VendorProductsController(preferences: prefs));
      }
      
      final productsController = Get.find<VendorProductsController>();
      if (productsController.vendorProducts.value == null) {
        await productsController.getVendorProducts();
      }
    } catch (e) {
      print('[CUPONES] Error inyectando dependencias: $e');
    } finally {
      setState(() {
        _isControllerReady = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController textController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF88),
              onPrimary: Colors.black,
              surface: Color(0xFF161B22),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF00FF88)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        textController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.coupon == null ? "CREAR NUEVO CUPÓN" : "EDITAR CUPÓN",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.coupon != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: _buildSectionTitle("INFORMACIÓN GENERAL"),
                  ),
                  const SizedBox(height: 20),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: _buildTextField(
                      controller: _nameController,
                      label: "NOMBRE DEL CUPÓN",
                      hint: "Eje: Descuento de Verano",
                      icon: Icons.label_outline,
                      validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 550),
                    child: _buildTextField(
                      controller: _codeController,
                      label: "CÓDIGO DEL CUPÓN",
                      hint: "Eje: DESCUENTO2026",
                      icon: Icons.qr_code,
                      validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildDropdown(
                            label: "TIPO",
                            value: _selectedType,
                            items: [
                              {'label': 'Porcentaje (%)', 'value': 'percentage'},
                              {'label': 'Fijo (\$)', 'value': 'fixed'},
                            ],
                            onChanged: (v) => setState(() => _selectedType = v!),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _discountController,
                            label: "DESCUENTO",
                            hint: "Eje: 10",
                            icon: Icons.percent,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? "Requerido" : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 650),
                    child: _buildTextField(
                      controller: _usesTotalController,
                      label: "USOS TOTALES",
                      hint: "Eje: 100",
                      icon: Icons.loop,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 670),
                    child: _buildDropdown(
                      label: "PERMITIR PRODUCTO",
                      value: _allowFor,
                      items: [
                        {'label': 'Todo el sitio', 'value': 's'},
                        {'label': 'Productos seleccionados', 'value': 'p'},
                      ],
                      onChanged: (v) => setState(() => _allowFor = v!),
                    ),
                  ),
                  if (_allowFor == 'p') ...[
                    const SizedBox(height: 20),
                    FadeInLeft(
                      duration: const Duration(milliseconds: 690),
                      child: _buildProductMultiSelector(),
                    ),
                  ],
                  const SizedBox(height: 30),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: _buildSectionTitle("VIGENCIA Y ESTADO"),
                  ),
                  const SizedBox(height: 20),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 700),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            controller: _dateStartController,
                            label: "FECHA INICIO",
                            icon: Icons.calendar_today,
                            onTap: () => _selectDate(context, _dateStartController),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildDateField(
                            controller: _dateEndController,
                            label: "FECHA FIN",
                            icon: Icons.event_available,
                            onTap: () => _selectDate(context, _dateEndController),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 800),
                    child: _buildDropdown(
                      label: "ESTADO DEL CUPÓN",
                      value: _selectedStatus,
                      items: [
                        {'label': 'Activo (Público)', 'value': '1'},
                        {'label': 'Inactivo (Pausado)', 'value': '0'},
                      ],
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Obx(() => FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF88),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                          shadowColor: const Color(0xFF00FF88).withOpacity(0.4),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                widget.coupon == null ? "GUARDAR CUPÓN" : "GUARDAR CAMBIOS",
                                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                              ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 15,
          decoration: BoxDecoration(
            color: const Color(0xFF00FF88),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white10),
            prefixIcon: Icon(icon, color: const Color(0xFF00FF88), size: 18),
            filled: true,
            fillColor: const Color(0xFF161B22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF00FF88), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "Seleccionar" : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty ? Colors.white10 : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    // TAREA 1: BLINDAJE TOTAL - Verificar si el valor existe en la lista
    final bool valueExists = items.any((item) => item['value'] == value);
    final String safeValue = valueExists ? value : items.first['value']!;

    if (!valueExists) {
      print('[DROPDOWN] Valor "$value" no encontrado en $label. Usando defecto: $safeValue');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue, // USAR VALOR SEGURO
              dropdownColor: const Color(0xFF161B22),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00FF88)),
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductMultiSelector() {
    // TAREA 3: REVISIÓN DE NULOS (STOP CRASH)
    if (!Get.isRegistered<VendorProductsController>()) {
      return const Center(child: Text("Cargando catálogo...", style: TextStyle(color: Colors.white24, fontSize: 12)));
    }

    final productsController = Get.find<VendorProductsController>();
    final products = productsController.vendorProducts.value?.products ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SELECCIONAR PRODUCTOS", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              if (products.isEmpty)
                const Text("No hay productos disponibles", style: TextStyle(color: Colors.white24, fontSize: 12))
              else
                ...products.map((product) {
                  final isSelected = _selectedProductIds.contains(product.id);
                  return CheckboxListTile(
                    title: Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00FF88), fontSize: 11)),
                    value: isSelected,
                    activeColor: const Color(0xFF00FF88),
                    checkColor: Colors.black,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedProductIds.add(product.id);
                        } else {
                          _selectedProductIds.remove(product.id);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_dateStartController.text.isEmpty || _dateEndController.text.isEmpty) {
        Get.snackbar("Atención", "Por favor selecciona las fechas de vigencia",
            backgroundColor: Colors.orangeAccent, colorText: Colors.black);
        return;
      }

      controller.manageCoupon(
        id: widget.coupon?.id,
        name: _nameController.text,
        code: _codeController.text,
        type: _selectedType,
        discount: _discountController.text,
        dateStart: _dateStartController.text,
        dateEnd: _dateEndController.text,
        usesTotal: _usesTotalController.text,
        status: _selectedStatus,
        allowFor: _allowFor,
        productIds: _selectedProductIds,
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
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
              const Text(
                "Esta acción eliminará el cupón permanentemente.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
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
                        Get.back(); // Cerrar diálogo
                        final success = await controller.deleteCoupon(widget.coupon!);
                        if (success) {
                          Navigator.pop(context, true); // Volver a la lista
                        }
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

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _discountController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    _usesTotalController.dispose();
    super.dispose();
  }
}
