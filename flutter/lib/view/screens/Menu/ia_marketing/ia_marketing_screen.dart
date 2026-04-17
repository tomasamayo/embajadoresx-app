import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:affiliatepro_mobile/controller/bannerAndLinks_controller.dart';
import 'package:affiliatepro_mobile/model/bannerAndLinks_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:affiliatepro_mobile/service/copy_history_service.dart';

import 'package:affiliatepro_mobile/view/screens/Menu/ia_marketing/ai_landing_screen.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/utils/session_manager.dart';
import 'package:dio/dio.dart' as dio;

class IAMarketingScreen extends StatefulWidget {
  const IAMarketingScreen({super.key});

  @override
  State<IAMarketingScreen> createState() => _IAMarketingScreenState();
}

class _IAMarketingScreenState extends State<IAMarketingScreen> {
  bool _isGenerating = false;
  bool _isLoadingProducts = true;
  List<BannerData> _listaProductos = [];
  List<GeneratedCopy> _history = [];

  @override
  void initState() {
    super.initState();
    _cargarProductosReales();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await CopyHistoryService.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _cargarProductosReales() async {
    try {
      final linksController = Get.find<BannerAndLinksController>();
      
      if (linksController.bannerAndLinksData != null && linksController.bannerAndLinksData!.data.isNotEmpty) {
        setState(() {
          _listaProductos = linksController.bannerAndLinksData!.data;
          _isLoadingProducts = false;
        });
      } else {
        await linksController.getBannerAndLinksData();
        if (mounted) {
          setState(() {
            _listaProductos = linksController.bannerAndLinksData?.data ?? [];
            _isLoadingProducts = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando productos en IA Marketing: $e");
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar( 
          backgroundColor: const Color(0xFF0B0B0F), 
          surfaceTintColor: Colors.transparent, 
          elevation: 0, 
          scrolledUnderElevation: 0, 
          leading: IconButton( 
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white), 
            onPressed: () => Navigator.pop(context), 
          ), 
          title: Row( 
            mainAxisSize: MainAxisSize.min, 
            children: const [ 
              Icon(Icons.smart_toy, color: Color(0xFF00FF88)), 
              SizedBox(width: 8), 
              Text(
                "Centro de IA Marketing", 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins', 
                ),
              ), 
            ], 
          ), 
          centerTitle: true, 
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.8, -0.5),
              radius: 1.5,
              colors: [
                Color(0xFF003318),
                Color(0xFF08080C),
                Color(0xFF050011),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF003311), Color(0xFF000000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF88).withOpacity(0.2),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Genera Marketing",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                "Automático con IA",
                                style: TextStyle(
                                  color: Color(0xFF00FF88),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "⚡ en segundos",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.smart_toy, color: Color(0xFF00FF88), size: 50),
                      ],
                    ),
                  ),
                ),

              if (_isGenerating) 
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF00FF88)),
                  ),
                ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Text(
                  "HERRAMIENTAS DISPONIBLES",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    FadeSlideEntrance(index: 0, child: _buildGlowCard(context, "Generar Anuncio", Icons.campaign, const Color(0xFF00FF88), "Facebook")),
                    FadeSlideEntrance(index: 1, child: _buildGlowCard(context, "Guion TikTok", Icons.video_library, Colors.pinkAccent, "TikTok")),
                    FadeSlideEntrance(index: 2, child: _buildGlowCard(context, "Copy Instagram", Icons.camera_alt, Colors.purpleAccent, "Instagram")),
                    FadeSlideEntrance(index: 3, child: _buildGlowCard(context, "Página de Ventas", Icons.language_rounded, Colors.lightBlueAccent, "Landing")),
                    FadeSlideEntrance(index: 4, child: _buildGlowCard(context, "Email Marketing", Icons.email_rounded, Colors.amber, "Webinar")),
                    FadeSlideEntrance(index: 5, child: _buildGlowCard(context, "Diseño Creativo", Icons.play_circle_outline_rounded, Colors.orangeAccent, "Niche")),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(18, 24, 18, 12),
                child: Text(
                  "PLANTILLAS INTELIGENTES",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildTemplateItem("Lanzamiento", Icons.rocket_launch_rounded),
                    _buildTemplateItem("Ofertas", Icons.local_offer_rounded),
                    _buildTemplateItem("Webinar", Icons.videocam_rounded),
                    _buildTemplateItem("Productos", Icons.inventory_2_rounded),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(18, 24, 18, 12),
                child: Text(
                  "ÚLTIMOS CONTENIDOS GENERADOS",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              if (_history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      "No hay contenidos generados aún",
                      style: TextStyle(color: Colors.white24, fontSize: 13, fontFamily: 'Poppins'),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length > 5 ? 5 : _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return FadeSlideEntrance(
                      index: index + 10,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151520),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FF88).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.description, color: Color(0xFF00FF88), size: 20),
                          ),
                          title: Text(
                            item.productTitle,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "Para ${item.socialMedia}",
                            style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Poppins'),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF88).withOpacity(0.1),
                              foregroundColor: const Color(0xFF00FF88),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Color(0xFF00FF88), width: 0.5),
                              ),
                            ),
                            onPressed: () async { 
                              await Clipboard.setData(ClipboardData(text: item.copy)); 
                              if (context.mounted) { 
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar( 
                                  const SnackBar( 
                                    backgroundColor: Color(0xFF00FF88), 
                                    behavior: SnackBarBehavior.floating, 
                                    content: Text( 
                                      "¡Copy copiado con éxito! 🚀", 
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold) 
                                    ), 
                                  ), 
                                ); 
                              } 
                            },
                            child: const Text("USAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTemplateItem(String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Plantilla $name seleccionada", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF00FF88),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF151520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF00FF88), size: 28),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowCard(BuildContext context, String title, IconData icon, Color glowColor, String tipoRedSocial) {
    return GestureDetector(
      onTap: () {
        if (_isLoadingProducts) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cargando productos, por favor espera..."))
          );
          return;
        }
        if (_listaProductos.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se encontraron productos en tu cuenta."))
          );
          return;
        }

        // TAREA: Si es Página de Ventas, abrir el nuevo generador élite
        if (tipoRedSocial == "Landing") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiLandingScreen()),
          );
          return;
        }

        _abrirModalIA(context, title, tipoRedSocial, icon, glowColor, _listaProductos);
      },
      child: Container(
        width: 105,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF151520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: glowColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirModalIA(BuildContext context, String titulo, String tipoRedSocial, IconData icono, Color colorNeon, List<BannerData> listaProductosReales) { 
    String? productoSeleccionadoId; 
    String? productoSeleccionadoTitulo;
    String? textoGenerado;
    bool isLoadingIA = false;
    final TextEditingController productSearchController = TextEditingController();
 
    showModalBottomSheet( 
      context: context, 
      backgroundColor: Colors.transparent, 
      isScrollControlled: true, 
      builder: (context) { 
        return StatefulBuilder( 
          builder: (BuildContext context, StateSetter setModalState) { 
            return Container( 
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85, 
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24), 
              decoration: BoxDecoration( 
                color: const Color(0xFF121212), 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), 
                border: Border.all(color: colorNeon.withOpacity(0.2), width: 1), 
                boxShadow: [BoxShadow(color: colorNeon.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)], 
              ), 
              child: SingleChildScrollView( 
                child: Column( 
                  mainAxisSize: MainAxisSize.min, 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))), 
                    const SizedBox(height: 20), 
                    Row( 
                      children: [ 
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorNeon.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icono, color: colorNeon, size: 24),
                        ),
                        const SizedBox(width: 16), 
                        Expanded(
                          child: Text(
                            titulo, 
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ), 
                      ], 
                    ), 
                    const SizedBox(height: 24), 
                    const Text("Selecciona el Producto", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')), 
                    const SizedBox(height: 8), 
                    
                    // REQUERIMIENTO V4.7: Buscador Predictivo (HotFix Assertion Error)
                    RawAutocomplete<BannerData>(
                      displayStringForOption: (option) => option.title ?? "",
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const Iterable<BannerData>.empty();
                        return listaProductosReales.where((p) => (p.title ?? "").toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Escribe para buscar producto...",
                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            prefixIcon: Icon(Icons.search, color: colorNeon, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colorNeon, width: 1),
                            ),
                            suffixIcon: controller.text.isNotEmpty ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                              onPressed: () {
                                controller.clear();
                                setModalState(() {
                                  productoSeleccionadoId = null;
                                  productoSeleccionadoTitulo = null;
                                });
                              },
                            ) : null,
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: MediaQuery.of(context).size.width - 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option.title ?? "", style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins')),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onSelected: (BannerData selection) {
                        setModalState(() {
                          productoSeleccionadoId = selection.id.toString();
                          productoSeleccionadoTitulo = selection.title;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 30), 
                    SizedBox( 
                      width: double.infinity, 
                      child: ElevatedButton( 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorNeon, 
                          padding: const EdgeInsets.symmetric(vertical: 16), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: colorNeon.withOpacity(0.3),
                        ), 
                        onPressed: (productoSeleccionadoId == null || isLoadingIA) ? null : () async { 
                          setModalState(() {
                            isLoadingIA = true;
                            textoGenerado = null;
                          });

                          try {
                            final result = await _generarCopyReal(productoSeleccionadoId!, tipoRedSocial);
                            
                            await CopyHistoryService.saveCopy(productoSeleccionadoTitulo ?? "Producto", result, tipoRedSocial);
                            _loadHistory();

                            setModalState(() {
                              isLoadingIA = false;
                              textoGenerado = result;
                            });
                          } catch (e) {
                            setModalState(() {
                              isLoadingIA = false;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: Colors.redAccent, content: Text("Error: $e"))
                              );
                            }
                          }
                        }, 
                        child: isLoadingIA 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          : Text(
                              "GENERAR AHORA", 
                              style: TextStyle(
                                color: productoSeleccionadoId == null ? Colors.black38 : Colors.black, 
                                fontWeight: FontWeight.w900, 
                                fontSize: 16, 
                                fontFamily: 'Poppins'
                              )
                            ), 
                      ), 
                    ), 

                    const SizedBox(height: 24), 
                    if (textoGenerado != null) 
                      Container( 
                        padding: const EdgeInsets.all(20), 
                        decoration: BoxDecoration( 
                          color: Colors.white.withOpacity(0.03), 
                          borderRadius: BorderRadius.circular(20), 
                          border: Border.all(color: Colors.white.withOpacity(0.08)), 
                        ), 
                        child: Column( 
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [ 
                            SelectableText(textoGenerado!, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontFamily: 'Poppins')), 
                            const Divider(color: Colors.white10, height: 30), 
                            Row( 
                              mainAxisAlignment: MainAxisAlignment.end, 
                              children: [ 
                                TextButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: textoGenerado!));
                                    HapticFeedback.mediumImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(backgroundColor: colorNeon, behavior: SnackBarBehavior.floating, content: const Text("¡Copy copiado con éxito! 🚀", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                                    );
                                  },
                                  icon: Icon(Icons.copy_rounded, color: colorNeon, size: 18),
                                  label: Text("COPIAR", style: TextStyle(color: colorNeon, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ], 
                            ), 
                          ], 
                        ), 
                      ), 
                    const SizedBox(height: 30), 
                  ], 
                ),
              ), 
            ); 
          } 
        ); 
      }, 
    ); 
  }

  Future<String> _generarCopyReal(String productId, String socialNetwork) async {
    const String dominioReal = "https://embajadoresx.com"; 
    final url = Uri.parse('$dominioReal/api/generate_ai_copy');
    
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'product_id': productId,
        'social_network': socialNetwork,
        'prompt_modifier': "Regla Negativa Absoluta: NO escribas más de 150 palabras. NO uses más de 2 párrafos. NO hagas listas de más de 3 puntos. NO uses más de 4 emojis. Instrucción de Éxito: Genera un copy directo al grano para el producto en $socialNetwork, persuasivo y corto. Ve directo a la oferta. Incluye un CTA al final."
      },
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return data['copy'];
      } else {
        throw Exception(data['message'] ?? 'Error al generar copy');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}

class FadeSlideEntrance extends StatelessWidget { 
  final Widget child; 
  final int index; 
  const FadeSlideEntrance({Key? key, required this.child, required this.index}) : super(key: key); 
 
  @override 
  Widget build(BuildContext context) { 
    return TweenAnimationBuilder<double>( 
      tween: Tween(begin: 0.0, end: 1.0), 
      duration: Duration(milliseconds: 400 + (index * 150)), 
      curve: Curves.easeOutQuart, 
      builder: (context, value, widget) { 
        return Transform.translate( 
          offset: Offset(0, 50 * (1 - value)), 
          child: Opacity( 
            opacity: value.clamp(0.0, 1.0), 
            child: child, 
          ), 
        ); 
      }, 
    ); 
  } 
}
