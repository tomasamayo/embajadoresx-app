import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controller/ai_landing_controller.dart';
import '../../../../controller/vendor_products_controller.dart';
import '../../../../model/vendor_product_model.dart';

class AiLandingScreen extends StatefulWidget {
  const AiLandingScreen({super.key});

  @override
  State<AiLandingScreen> createState() => _AiLandingScreenState();
}

class _AiLandingScreenState extends State<AiLandingScreen> {
  late AiLandingController controller;
  late VendorProductsController productsController;
  bool _isReady = false;
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  
  // v1.1.0: Configuración de Países (Reutilizando lógica de Detalle de Pago)
  String _selectedCountryIso = 'PE';
  final Map<String, String> _countryPhoneCodes = {
    'US': '+1', 'PE': '+51', 'MX': '+52', 'CO': '+57', 'AR': '+54', 'CL': '+56', 'EC': '+593', 'VE': '+58', 'BR': '+55', 'BO': '+591', 'PY': '+595', 'UY': '+598', 'CR': '+506', 'PA': '+507', 'DO': '+1-809', 'SV': '+503', 'GT': '+502', 'HN': '+504', 'NI': '+505', 'PR': '+1-787',
    'ES': '+34', 'PT': '+351', 'FR': '+33', 'DE': '+49', 'IT': '+39', 'NL': '+31', 'BE': '+32', 'CH': '+41', 'AT': '+43', 'IE': '+353', 'GB': '+44', 'SE': '+46', 'NO': '+47', 'DK': '+45', 'FI': '+358', 'IS': '+354', 'RO': '+40', 'BG': '+359', 'GR': '+30', 'HU': '+36', 'CZ': '+420', 'PL': '+48',
    'TR': '+90', 'AE': '+971', 'SA': '+966', 'EG': '+20', 'MA': '+212', 'ZA': '+27',
    'IN': '+91', 'PK': '+92', 'BD': '+880', 'JP': '+81', 'KR': '+82', 'CN': '+86', 'HK': '+852', 'TW': '+886', 'SG': '+65', 'MY': '+60', 'ID': '+62', 'TH': '+66', 'PH': '+63', 'VN': '+84',
    'AU': '+61', 'NZ': '+64', 'CA': '+1'
  };

  String _flagEmoji(String code) {
    if (code.length != 2) return '';
    final upper = code.toUpperCase();
    const int base = 0x1F1E6;
    final int first = upper.codeUnitAt(0) - 65;
    final int second = upper.codeUnitAt(1) - 65;
    return String.fromCharCode(base + first) + String.fromCharCode(base + second);
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    controller = Get.put(AiLandingController(preferences: prefs));
    
    // Vincular controladores
    _promptController.addListener(() => controller.userPrompt.value = _promptController.text);
    _whatsappController.addListener(() => controller.contactPhone.value = _whatsappController.text);
    
    if (!Get.isRegistered<VendorProductsController>()) {
      productsController = Get.put(VendorProductsController(preferences: prefs));
    } else {
      productsController = Get.find<VendorProductsController>();
    }
    
    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "IA LANDING BUILDER",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: const Text(
                "Genera tu Página de Ventas con GPT-4o",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text(
                "Sigue los pasos para crear tu landing optimizada.",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            
            // PASO 1: Selector de Producto
            FadeInLeft(
              delay: const Duration(milliseconds: 400),
              child: _buildSectionLabel("PASO 1: SELECCIONA TU PRODUCTO"),
            ),
            const SizedBox(height: 12),
            FadeInLeft(
              delay: const Duration(milliseconds: 500),
              child: _buildProductSelector(),
            ),
            
            // v1.0.0: NUEVO PASO 2: WhatsApp (Cascaada)
            Obx(() {
              final isProductSelected = controller.selectedProductId.value.isNotEmpty;
              return isProductSelected 
                ? SlideInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        FadeInLeft(
                          child: _buildSectionLabel("PASO 2: INGRESA TU WHATSAPP (CON CÓDIGO DE PAÍS)"),
                        ),
                        const SizedBox(height: 12),
                        FadeInLeft(
                          child: _buildWhatsAppField(),
                        ),

                      ],
                    ),
                  )
                : const SizedBox.shrink();
            }),
            
            const SizedBox(height: 32),
            
            // Botón Generar / Estado de Carga
            Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              
              if (controller.landingUrl.value.isNotEmpty) {
                return _buildResultCard();
              }
              
              // v1.0.0: BLOQUEO ESTRICTO DEL BOTÓN - Solo producto y whatsapp
              final hasProduct = controller.selectedProductId.value.isNotEmpty;
              final hasValidWhatsApp = controller.contactPhone.value.trim().isNotEmpty;
              
              final isReady = hasProduct && hasValidWhatsApp;
              
              return isReady ? _buildGenerateButton() : _buildDisabledButton();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "COMPLETA LOS PASOS PARA GENERAR",
          style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF00FF88),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildProductSelector() {
    return Obx(() {
      final products = productsController.activeGlobalProducts;
      final selectedProduct = products.firstWhereOrNull((p) => p.id == controller.selectedProductId.value);
      
      return InkWell(
        onTap: () => _showProductSearchModal(context, products),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: controller.selectedProductId.value.isNotEmpty 
                ? const Color(0xFF00FF88).withOpacity(0.3) 
                : Colors.white.withOpacity(0.05)
            ),
          ),
          child: Row(
            children: [
              Icon(
                selectedProduct != null ? Icons.check_circle : Icons.search,
                color: selectedProduct != null ? const Color(0xFF00FF88) : Colors.white24,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedProduct?.name ?? "Buscar producto...",
                  style: TextStyle(
                    color: selectedProduct != null ? Colors.white : Colors.white24,
                    fontSize: 14,
                    fontWeight: selectedProduct != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_right, color: Colors.white24),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStrategySelector() {
    return Obx(() {
      if (controller.isLoadingStrategies.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
      }
      
      final strategy = controller.selectedStrategy;
      
      return InkWell(
        onTap: () => _showStrategyModal(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: controller.selectedStrategyId.value.isNotEmpty 
                ? const Color(0xFF00FF88).withOpacity(0.3) 
                : Colors.white.withOpacity(0.05)
            ),
          ),
          child: Row(
            children: [
              Icon(
                strategy != null ? Icons.auto_awesome : Icons.list_alt,
                color: strategy != null ? const Color(0xFF00FF88) : Colors.white24,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strategy?['name'] ?? "Selecciona una estrategia...",
                  style: TextStyle(
                    color: strategy != null ? Colors.white : Colors.white24,
                    fontSize: 14,
                    fontWeight: strategy != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_right, color: Colors.white24),
            ],
          ),
        ),
      );
    });
  }

  void _showStrategyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          // TAREA 1: Priorizar "Master Landing EX (Premium)"
          final sortedStrategies = List<Map<String, dynamic>>.from(controller.strategies);
          sortedStrategies.sort((a, b) {
            final nameA = a['name']?.toString().toLowerCase() ?? "";
            if (nameA.contains("master") || nameA.contains("premium")) return -1;
            return 1;
          });

          return Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "ESTRATEGIAS DE VENTA",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedStrategies.length,
                  itemBuilder: (context, index) {
                    final s = sortedStrategies[index];
                    final isSelected = controller.selectedStrategyId.value == s['id'].toString();
                    final strategyName = s['name']?.toString().toLowerCase() ?? "";
                    final isMaster = strategyName.contains("master") || strategyName.contains("premium");
                    final isDirect = strategyName.contains("direct") || strategyName.contains("venta directa");

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isMaster ? const Color(0xFF00FF88).withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isMaster ? Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)) : null,
                      ),
                      child: ListTile(
                        onTap: () {
                          controller.selectedStrategyId.value = s['id'].toString();
                          Navigator.pop(context);
                        },
                        leading: Icon(
                          isMaster ? Icons.stars : (isDirect ? Icons.bolt : Icons.auto_awesome), 
                          color: isSelected || isMaster || isDirect ? const Color(0xFF00FF88) : Colors.white24
                        ),
                        title: Row(
                          children: [
                            Expanded( // TAREA 3 (v23.0.0): Expanded para evitar overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['name'], 
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    s['description'] ?? "Generación inteligente con IA", 
                                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                                    maxLines: 2, // TAREA 3: maxLines 2 para descripción
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isMaster) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00FF88),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("PRO", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00FF88)) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showProductSearchModal(BuildContext context, List<VendorProduct> products) {
    if (products.isEmpty) {
      productsController.getGlobalCatalog();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: Color(0xFF00FF88)),
                  const SizedBox(width: 12),
                  const Text(
                    "SELECCIONA UN PRODUCTO",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Buscar por nombre o SKU...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF88)),
                  filled: true,
                  fillColor: const Color(0xFF161B22),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  // Implementar filtro local si se desea
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final currentProducts = productsController.activeGlobalProducts;
                if (currentProducts.isEmpty && !productsController.isLoading.value) {
                  return const Center(child: Text("No hay productos disponibles", style: TextStyle(color: Colors.white54)));
                }
                if (productsController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
                }
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: currentProducts.length,
                  itemBuilder: (context, index) {
                    final p = currentProducts[index];
                    final isSelected = controller.selectedProductId.value == p.id;
                    return ListTile(
                      onTap: () {
                        controller.selectedProductId.value = p.id;
                        Navigator.pop(context);
                      },
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(8),
                          image: p.imageUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(p.imageUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: p.imageUrl.isEmpty ? const Icon(Icons.image_not_supported, color: Colors.white10) : null,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.name, 
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (p.isTopProduct) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF88).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
                              ),
                              child: const Text(
                                "SUGERIDO",
                                style: TextStyle(color: Color(0xFF00FF88), fontSize: 7, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text("SKU: ${p.sku}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00FF88)) : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptField() {
    return TextField(
      controller: _promptController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: "Ej: Resalta que tenemos envío gratis y garantía de 30 días...",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.15)),
        filled: true,
        fillColor: const Color(0xFF161B22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1),
        ),
      ),
    );
  }

  Widget _buildWhatsAppField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF06FD71), width: 1.5),
          ),
          child: Row(
            children: [
              // Selector de País (Reutilizado de Detalle de Pago)
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: DropdownButton<String>(
                  value: _selectedCountryIso,
                  underline: const SizedBox(),
                  dropdownColor: const Color(0xFF1A1D1A),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF06FD71), size: 16),
                  items: _countryPhoneCodes.keys.map((String iso) {
                    return DropdownMenuItem<String>(
                      value: iso,
                      child: Text(
                        "${_flagEmoji(iso)} ${_countryPhoneCodes[iso]}",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCountryIso = val!;
                      // Actualizar el controlador con el código de país + número actual
                      controller.contactPhone.value = "${_countryPhoneCodes[_selectedCountryIso]}${_whatsappController.text}";
                    });
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: VerticalDivider(color: Colors.white24, width: 1),
              ),
              // Campo de Número
              Expanded(
                child: TextField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
                  onChanged: (value) {
                    // Combinar código de país con el número ingresado
                    controller.contactPhone.value = "${_countryPhoneCodes[_selectedCountryIso]}$value";
                  },
                  decoration: InputDecoration(
                    hintText: "Número de WhatsApp",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 0, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "El enlace de WhatsApp incluirá automáticamente el código ${_countryPhoneCodes[_selectedCountryIso]}",
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
        ),
      ],
    );
  }


  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06FD71).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => controller.generateLandingTemplate(), // v1.0.0: Nuevo motor backend
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06FD71), // Verde Neón
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text(
          "GENERAR LANDING AHORA",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFF00FF88)),
          const SizedBox(height: 20),
          FadeIn(
            duration: const Duration(seconds: 2),
            child: const Text(
              "Estamos procesando tu solicitud y creando tu Landing Page... Esto tardará unos segundos.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return FadeInUp(
      child: Column(
        children: [
          // Card de éxito con links (v45.0.0)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF88).withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF00FF88), size: 60),
                const SizedBox(height: 16),
                const Text(
                  "¡Tu Landing Page está lista!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Copia el enlace y compártelo con tus clientes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                // Campo de URL (v45.0.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Color(0xFF00FF88), size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.landingUrl.value,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildActionButton(
                  "COPIAR ENLACE",
                  Icons.copy,
                  () => _copyToClipboard(controller.landingUrl.value),
                  isPrimary: true,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  "ABRIR EN NAVEGADOR",
                  Icons.open_in_new,
                  () => _launchUrl(controller.landingUrl.value),
                  isPrimary: false,
                ),
                const SizedBox(height: 24),
                
                TextButton.icon(
                  onPressed: () => controller.reset(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    "VOLVER A GENERAR",
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF00FF88) : Colors.white.withOpacity(0.05),
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      "Copiado",
      "El texto se ha copiado al portapapeles",
      backgroundColor: const Color(0xFF00FF88),
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
