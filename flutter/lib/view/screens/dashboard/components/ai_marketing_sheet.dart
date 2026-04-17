import 'dart:io'; // Para SocketException
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:affiliatepro_mobile/model/dashboard_model.dart';
import 'package:affiliatepro_mobile/model/bannerAndLinks_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/service/copy_history_service.dart';

// REQUERIMIENTO V4.4: Modelo para las plantillas de éxito
class MarketingTemplate {
  final String title;
  final IconData icon;
  final String content;
  final String description;

  MarketingTemplate({
    required this.title,
    required this.icon,
    required this.content,
    required this.description,
  });
}

// Unified class to handle both MarketTool and BannerData
class SearchableProduct {
  final String id;
  final String title;
  final String? iconUrl;

  SearchableProduct({
    required this.id,
    required this.title,
    this.iconUrl,
  });
}

class AIMarketingSheet extends StatefulWidget {
  final List<dynamic> productosDisponibles;

  const AIMarketingSheet({
    super.key,
    required this.productosDisponibles,
  });

  @override
  State<AIMarketingSheet> createState() => _AIMarketingSheetState();
}

class _AIMarketingSheetState extends State<AIMarketingSheet> {
  String? selectedProduct;
  String? selectedSocialMedia;
  bool isGenerating = false;
  String? generatedCopy;
  final TextEditingController _productSearchController = TextEditingController();
  late List<SearchableProduct> _searchableProducts;
  List<GeneratedCopy> _history = [];
  
  final List<MarketingTemplate> _successTemplates = [
    MarketingTemplate(
      title: "Lanzamiento",
      icon: Icons.rocket_launch_rounded,
      description: "Ideal para nuevos productos.",
      content: "¡EL MOMENTO HA LLEGADO! 🚀 Presentamos [Producto]. La revolución que esperabas para [Beneficio]. Únete ahora y sé de los primeros.",
    ),
    MarketingTemplate(
      title: "Ofertas",
      icon: Icons.local_offer_rounded,
      description: "Maximiza tus ventas hoy.",
      content: "¡OFERTA EXCLUSIVA! 🎯 Solo por tiempo limitado, obtén [Producto] con un beneficio único. No dejes pasar esta oportunidad.",
    ),
    MarketingTemplate(
      title: "Webinar",
      icon: Icons.videocam_rounded,
      description: "Atrae audiencia a tus eventos.",
      content: "Aprende cómo dominar [Tema] en nuestro próximo Webinar sobre [Producto]. Regístrate gratis en el enlace de mi bio. 🎥",
    ),
    MarketingTemplate(
      title: "Productos",
      icon: Icons.inventory_2_rounded,
      description: "Resalta las características pro.",
      content: "Descubre por qué [Producto] es el favorito de los expertos. Calidad, eficiencia y resultados garantizados. 💎",
    ),
  ];

  final List<String> socialMedia = [
    "TikTok",
    "Instagram",
    "Facebook",
    "YouTube Shorts"
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Pre-map the generic products to our unified SearchableProduct class
    _searchableProducts = widget.productosDisponibles.map((e) {
      if (e is MarketTool) {
        return SearchableProduct(id: e.id, title: e.title, iconUrl: e.feviIcon);
      } else if (e is BannerData) {
        return SearchableProduct(id: e.id, title: e.title, iconUrl: e.fevi_icon);
      } else {
        // Fallback for any other type
        return SearchableProduct(
          id: (e.id ?? e.product_id ?? "").toString(),
          title: e.title?.toString() ?? "",
          iconUrl: (e.fevi_icon ?? e.feviIcon)?.toString(),
        );
      }
    }).toList();
  }

  Future<void> _loadHistory() async {
    final history = await CopyHistoryService.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _saveToHistory(String productTitle, String copy, String socialMedia) async {
    await CopyHistoryService.saveCopy(productTitle, copy, socialMedia);
    _loadHistory();
  }

  @override
  void dispose() {
    _productSearchController.dispose();
    super.dispose();
  }

  Future<void> _generateCopy() async {
    if (selectedProduct == null || selectedSocialMedia == null) return;

    // Search for the product by title in our unified list
    final index = _searchableProducts.indexWhere(
      (e) => e.title == selectedProduct,
    );

    if (index == -1) {
      if (mounted) {
        setState(() => isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent, 
            content: Text("Por favor, selecciona un producto válido primero.")
          )
        );
      }
      return;
    }

    final productToGenerate = _searchableProducts[index];

    setState(() {
      isGenerating = true;
      generatedCopy = null;
    });

    try {
      const String dominioReal = "https://embajadoresx.com";
      final url = Uri.parse('$dominioReal/api/generate_ai_copy');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'product_id': productToGenerate.id,
          'social_network': selectedSocialMedia!,
          'prompt_modifier': "Regla Negativa Absoluta: NO escribas más de 150 palabras. NO uses más de 2 párrafos. NO hagas listas de más de 3 puntos. NO uses más de 4 emojis. Instrucción de Éxito: Genera un copy directo al grano para ${productToGenerate.title} en $selectedSocialMedia, persuasivo y corto. Ve directo a la oferta. Incluye un CTA al final."
        },
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          if (mounted) {
            setState(() => generatedCopy = data['copy']);
            // REQUERIMIENTO V4.4: Guardar en historial local
            _saveToHistory(productToGenerate.title, data['copy'], selectedSocialMedia!);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.redAccent, content: Text(data['message'] ?? 'Error al generar copy'))
            );
          }
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text("Error inesperado: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  void _copyToClipboard() {
    if (generatedCopy != null) {
      Clipboard.setData(ClipboardData(text: generatedCopy!));
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Copy copiado al portapapeles", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF00FF88),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // --- REQUERIMIENTO V4.4: Helpers de UI ---

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        if (onSeeMore != null)
          IconButton(
            onPressed: onSeeMore,
            icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00FF88), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildHistoryCard(GeneratedCopy item) {
    return GestureDetector(
      onTap: () => _showHistoryDetail(item),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.02),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_edu_rounded, color: Color(0xFF00FF88), size: 16),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.copy));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Copiado", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        backgroundColor: const Color(0xFF00FF88),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        width: 100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      )
                    );
                  },
                  child: const Text("USAR", style: TextStyle(color: Color(0xFF00FF88), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.productTitle,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.socialMedia,
              style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(MarketingTemplate template) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Plantilla ${template.title} seleccionada", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF00FF88),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        );
        _showTemplateDetail(template);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(template.icon, color: const Color(0xFF00FF88), size: 16),
            ),
            const SizedBox(height: 12),
            Text(
              template.title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              template.description,
              style: const TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'Poppins'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDetail(GeneratedCopy item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => _buildDetailModal(
        title: item.productTitle,
        subtitle: "Generado para ${item.socialMedia}",
        content: item.copy,
      ),
    );
  }

  void _showTemplateDetail(MarketingTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => _buildDetailModal(
        title: template.title,
        subtitle: template.description,
        content: template.content,
      ),
    );
  }

  Widget _buildDetailModal({required String title, required String subtitle, required String content}) {
    const Color neonGreen = Color(0xFF00FF88);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white24),
                )
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: SelectableText(
                content,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Copiado al portapapeles", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: neonGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 20),
                label: const Text("COPIAR TEXTO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllTemplates() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Plantillas de Éxito", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              const Text("Explora nuestras mejores estrategias de copy", style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Poppins')),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _successTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _successTemplates[index];
                    return GestureDetector(
                      onTap: () => _showTemplateDetail(template),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(template.icon, color: const Color(0xFF00FF88), size: 32),
                            const SizedBox(height: 12),
                            Text(
                              template.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template.description,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFF00FF88);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: neonGreen.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: neonGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: neonGreen, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "IA Marketing Center",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          "Genera copys persuasivos en segundos",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Divider(color: Colors.white10),
              const SizedBox(height: 24),

              // Form Fields
              _buildLabel("Selecciona el Producto"),
              _buildProductSearch(),
              const SizedBox(height: 20),

              _buildLabel("Red Social"),
              _buildDropdown(
                hint: "Plataforma de destino",
                items: socialMedia,
                value: selectedSocialMedia,
                onChanged: (val) => setState(() => selectedSocialMedia = val),
              ),
              const SizedBox(height: 40),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (selectedProduct == null || selectedSocialMedia == null || isGenerating)
                      ? null
                      : _generateCopy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: neonGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isGenerating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                        )
                      : const Text(
                          "GENERAR COPY",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),

              // Result Section (Glassmorphism)
              if (generatedCopy != null) ...[
                const SizedBox(height: 32),
                _buildLabel("Copy Generado"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        generatedCopy!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy_rounded, color: neonGreen, size: 18),
                        label: const Text(
                          "COPIAR AL PORTAPAPELES",
                          style: TextStyle(
                            color: neonGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSearch() {
    const Color neonGreen = Color(0xFF00FF88);

    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<SearchableProduct>(
          displayStringForOption: (option) => option.title,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<SearchableProduct>.empty();
            }
            return _searchableProducts.where((product) {
              return product.title.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: "Escribe para buscar producto...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                prefixIcon: const Icon(Icons.search, color: neonGreen, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: neonGreen, width: 1),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                        onPressed: () {
                          controller.clear();
                          setState(() => selectedProduct = null);
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                if (val.isEmpty) setState(() => selectedProduct = null);
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              image: (option.iconUrl != null && option.iconUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(option.iconUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (option.iconUrl == null || option.iconUrl!.isEmpty)
                                ? const Icon(Icons.shopping_bag_outlined, color: Colors.white24, size: 16)
                                : null,
                          ),
                          title: Text(
                            option.title,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            onSelected(option);
                            setState(() {
                              selectedProduct = option.title;
                            });
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true, // Soluciona el overflow para textos largos
      hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 14)),
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item, 
            overflow: TextOverflow.ellipsis, // Corta el texto con "..." si es muy largo
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
