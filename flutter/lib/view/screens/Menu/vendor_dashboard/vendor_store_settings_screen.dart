import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controller/vendor_store_settings_controller.dart';

class VendorStoreSettingsScreen extends StatefulWidget {
  const VendorStoreSettingsScreen({super.key});

  @override
  State<VendorStoreSettingsScreen> createState() => _VendorStoreSettingsScreenState();
}

class _VendorStoreSettingsScreenState extends State<VendorStoreSettingsScreen> with SingleTickerProviderStateMixin {
  late VendorStoreSettingsController controller;
  bool _isControllerReady = false;
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initController() async {
    final prefs = await SharedPreferences.getInstance();
    controller = Get.put(VendorStoreSettingsController(preferences: prefs));
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
          "AJUSTES DE TIENDA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00FF88),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00FF88),
          unselectedLabelColor: Colors.white38,
          dividerColor: Colors.transparent, // ELIMINA LA LÍNEA BLANCA
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
          tabs: const [
            Tab(text: "TIENDA", icon: Icon(Icons.storefront_outlined)),
            Tab(text: "PROVEEDOR", icon: Icon(Icons.business_center_outlined)),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A), // 100% oscuro
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
            }
            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStoreTab(),
                      _buildProviderTab(),
                    ],
                  ),
                ),
                _buildSaveButton(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Multimedia: Banner y Logo
            _buildVisualIdentityHeader(),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Toca para cambiar imagen (Multipart)",
                style: TextStyle(color: Color(0xFF00FF88), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("IDENTIDAD VISUAL"),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.shopNameController,
              label: "NOMBRE DE LA TIENDA",
              hint: "Eje: Mi Tienda Premium",
              icon: Icons.storefront,
              validator: (v) => v!.isEmpty ? "Campo requerido" : null,
            ),
            const SizedBox(height: 20),
            // Color de Texto
            _buildTextField(
              controller: controller.shopColorController,
              label: "COLOR DEL TEXTO DE PORTADA",
              hint: "#00FF88",
              icon: Icons.palette_outlined,
            ),
            const SizedBox(height: 20),
            // Muestra tu nombre en la portada -> Dropdown Sí/No
            _buildDropdownField(
              label: "MUESTRA TU NOMBRE EN LA PORTADA",
              value: controller.showNameOnCover.value,
              items: const [
                DropdownMenuItem(value: "1", child: Text("Sí")),
                DropdownMenuItem(value: "0", child: Text("No")),
              ],
              onChanged: (val) => controller.showNameOnCover.value = val!,
              icon: Icons.visibility_outlined,
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("INFORMACIÓN ADICIONAL"),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.shopMapController,
              label: "TIENDA VENDEDORA CONTÁCTANOS MAPA",
              hint: "Pega el código del mapa aquí...",
              icon: Icons.map_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.shopTermsController,
              label: "CONDICIONES DE LOS TÉRMINOS",
              hint: "Escribe las reglas de tu tienda...",
              icon: Icons.gavel_outlined,
              maxLines: 5,
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("DATOS DE CONTACTO"),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.contactController,
              label: "TELF. MÓVIL DE LA TIENDA",
              hint: "+123456789",
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.emailController,
              label: "CORREO DE LA TIENDA",
              hint: "tienda@ejemplo.com",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.addressController,
              label: "DIRECCIÓN DE LA TIENDA",
              hint: "Calle Principal #123",
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualIdentityHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Banner
            GestureDetector(
              onTap: () => controller.pickBanner(),
              child: Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
                  image: controller.shopBannerBytes.value != null
                      ? DecorationImage(image: MemoryImage(controller.shopBannerBytes.value!), fit: BoxFit.cover)
                      : (controller.settings.value?.shopBanner.isNotEmpty == true
                          ? DecorationImage(image: NetworkImage(controller.settings.value!.shopBanner), fit: BoxFit.cover)
                          : null),
                ),
                child: controller.shopBannerBytes.value == null && (controller.settings.value?.shopBanner.isEmpty ?? true)
                    ? const Center(child: Icon(Icons.image_outlined, color: Colors.white24, size: 40))
                    : Stack(
                        children: [
                          Positioned(
                            right: 10,
                            top: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              radius: 15,
                              child: Icon(Icons.camera_alt, color: const Color(0xFF00FF88), size: 16),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // Logo Circular
            GestureDetector(
              onTap: () => controller.pickLogo(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00FF88), width: 2),
                  boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.2), blurRadius: 10)],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.black,
                  backgroundImage: controller.shopLogoBytes.value != null
                      ? MemoryImage(controller.shopLogoBytes.value!)
                      : (controller.settings.value?.shopLogo.isNotEmpty == true
                          ? NetworkImage(controller.settings.value!.shopLogo) as ImageProvider
                          : null),
                  child: (controller.shopLogoBytes.value == null && (controller.settings.value?.shopLogo.isEmpty ?? true))
                      ? const Icon(Icons.store, color: Colors.white24, size: 40)
                      : const Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF00FF88),
                            radius: 12,
                            child: Icon(Icons.camera_alt, color: Colors.black, size: 14),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("CONFIGURACIÓN DE COMISIONES DE PROVEEDORES"),
          const SizedBox(height: 20),
          // Otros afiliados venden Mis artículos
          _buildDropdownField(
            label: "OTROS AFILIADOS VENDEN MIS ARTÍCULOS",
            value: controller.vendorStatus.value,
            items: const [
              DropdownMenuItem(value: "1", child: Text("Vender todos los afiliados")),
              DropdownMenuItem(value: "0", child: Text("No vender a nadie")),
              DropdownMenuItem(value: "2", child: Text("Solo mis afiliados")),
            ],
            onChanged: (val) => controller.vendorStatus.value = val!,
            icon: Icons.group_add_outlined,
          ),
          const SizedBox(height: 40),
          _buildSectionTitle("COMISIÓN DE CLIC DE AFILIADO"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.clickCommController,
                  label: "CLICS",
                  hint: "0",
                  icon: Icons.mouse_outlined,
                  keyboardType: TextInputType.number,
                  readOnly: false, // TAREA 2: DESBLOQUEAR EL CAMPO "CLICS" (Imagen 56)
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  controller: controller.affiliateClickAmountController,
                  label: "VALOR POR CLIC",
                  hint: "0.00",
                  icon: Icons.ads_click_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildSectionTitle("COMISIÓN DE VENTA DE AFILIADOS"),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: "TIPO DE COMISIÓN",
            value: controller.affiliateSaleCommissionType.value,
            items: const [
              DropdownMenuItem(value: "percentage", child: Text("Porcentaje (%)")),
              DropdownMenuItem(value: "fixed", child: Text("Fijo (\$)")),
            ],
            onChanged: (val) => controller.affiliateSaleCommissionType.value = val!,
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: controller.affiliateCommissionValueController,
            label: "VALOR DE VENTA",
            hint: "0",
            icon: Icons.monetization_on_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNeonSwitch(String label, RxBool value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1)),
      ),
      child: Obx(() => SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        secondary: Icon(icon, color: const Color(0xFF00FF88), size: 20),
        value: value.value,
        onChanged: (val) => value.value = val,
        activeColor: const Color(0xFF00FF88),
      )),
    );
  }

  Widget _buildSaveButton() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: Border(top: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.1))),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: controller.isSaving.value ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF88),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 8,
              shadowColor: const Color(0xFF00FF88).withOpacity(0.4),
            ),
            child: controller.isSaving.value
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
                    "GUARDAR CONFIGURACIÓN",
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF161B22),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00FF88)),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
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
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
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
          maxLines: maxLines,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? Colors.white54 : Colors.white, fontSize: 14),
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

  void _handleSave() {
    // Si la pestaña actual es la 0 (TIENDA), validamos el form
    if (_tabController.index == 0) {
      if (_formKey.currentState!.validate()) {
        controller.updateSettings();
      }
    } else {
      controller.updateSettings();
    }
  }
}
