import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../../../../controller/store_controller.dart';
import '../../../../utils/colors.dart';

class StorePage extends StatefulWidget {
  final String? initialUrl;
  final String? title;
  const StorePage({super.key, this.initialUrl, this.title});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isGeneratingToken = true;

  // 🛡️ [GETX FIX] Inyección segura del controlador para evitar crash "Not Found"
  final StoreController _storeController = Get.put(StoreController());

  @override
  void initState() {
    super.initState();
    
    // 🛡️ [WEB/NATIVE FIX] Compatibilidad kIsWeb aplicada. dart:io protegido.
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        print("🛡️ [WEBVIEW FIX] Plataforma Android inicializada para el WebView. Previniendo pantalla roja.");
      }
    }

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColor.dashboardBgColor)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
               if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        );
      
      if (widget.initialUrl != null) {
        _loadInitialUrl();
      } else {
        _loadStoreWithMagicLink();
      }
    } else {
      // En Web, desactivamos los estados de carga ya que no habrá WebView
      _isLoading = false;
      _isGeneratingToken = false;
    }
  }

  void _loadInitialUrl() {
    if (kIsWeb) return;
    setState(() {
      _isGeneratingToken = false;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(widget.initialUrl!));
  }

  Future<void> _loadStoreWithMagicLink() async {
    if (kIsWeb) return;
    setState(() => _isGeneratingToken = true);
    
    print("🛡️ [GETX FIX] StoreController inyectado exitosamente usando Get.put(). Previendo crash Not Found.");
    final magicLink = await _storeController.fetchAutoLoginUrl();
    
    if (mounted) {
      setState(() {
        _isGeneratingToken = false;
        _isLoading = false; // TAREA 3: Liberamos el estado de carga inicial para disparar la transición al WebView
      });
      
      // Disparamos la carga de la URL (Mágica o Respaldo)
      _controller.loadRequest(Uri.parse(magicLink ?? 'https://embajadoresx.com/store'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.dashboardBgColor,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.appPrimary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title ?? "Tienda",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                widget.title != null ? "CASINO EXCLUSIVO" : "MARKETPLACE EXCLUSIVO",
                                style: TextStyle(
                                  color: AppColor.appPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  child: kIsWeb 
                    ? const Center(
                        child: Text(
                          "El WebView no está soportado en Chrome,\nusa un dispositivo real o emulador.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                        ),
                      )
                    : WebViewWidget(controller: _controller),
                ),
              ),
            ],
          ),
          
          if (_isLoading || _isGeneratingToken)
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColor.appPrimary.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColor.appPrimary,
                      strokeWidth: 3,
                    ),
                    if (_isGeneratingToken) ...[
                      const SizedBox(height: 20),
                      const Text(
                        "SEGURIDAD ACTIVA",
                        style: TextStyle(
                          color: AppColor.appPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        "Validando Sesión...",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
