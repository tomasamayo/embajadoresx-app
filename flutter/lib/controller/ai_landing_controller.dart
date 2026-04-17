import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_controller.dart';
import 'vendor_products_controller.dart';
import '../service/api_service.dart';
import '../utils/session_manager.dart';
import '../model/vendor_product_model.dart';

import 'package:http/http.dart' as http;

class AiLandingController extends GetxController {
  final SharedPreferences preferences;
  AiLandingController({required this.preferences});

  var isLoading = false.obs;
  var landingUrl = "".obs;
  var landingText = "".obs; // TAREA 4 (v12.0.0): Texto generado por la IA
  var selectedProductId = "".obs;
  var userPrompt = "".obs;
  var contactPhone = "".obs; // TAREA 2 (v10.0.0): WhatsApp de contacto

  // TAREA 2: LIMPIEZA TOTAL (v34.0.0) - Solo datos reales del servidor
  var strategies = <Map<String, dynamic>>[].obs;
  var selectedStrategyId = "".obs;
  var isLoadingStrategies = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStrategies();
  }

  Future<void> fetchStrategies() async {
    print('📡 [AI LANDING] Obteniendo estrategias de prompts...');
    isLoadingStrategies.value = true;
    try {
      // TAREA 1 (v19.0.0): Rutas exactas sin /api/ y con Token
      final String token = SessionManager.instance.token ?? "";
      final String url = 'https://embajadoresx.com/Subscription_Plan/get_prompt_strategies?v=${DateTime.now().millisecondsSinceEpoch}';
      
      // TAREA 2: DEBUG TOKEN (v33.0.0)
      print('DEBUG TOKEN AI: $token');

      // TAREA 2: VALIDACIÓN DE TOKEN (v32.0.0)
      if (token.isEmpty) {
        print('❌ [AI LANDING] Token vacío. Redirigiendo a Login.');
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "Cache-Control": "no-cache",
          "Pragma": "no-cache"
        },
      );
      
      print('📊 [AI LANDING] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true || data['status'] == 1) {
          // Solo llenamos con lo que viene del servidor
          strategies.value = List<Map<String, dynamic>>.from(data['data'] ?? []);
          print('✅ [AI LANDING] ${strategies.length} estrategias cargadas.');
        } else {
          print('❌ [AI LANDING] Error en respuesta: ${data['message']}');
          strategies.value = [];
        }
      } else {
        print('❌ [AI LANDING] Error de servidor: ${response.statusCode}');
        strategies.value = [];
      }
    } catch (e) {
      print('❌ [AI LANDING] Error excepcional: $e');
      strategies.value = [];
    } finally {
      isLoadingStrategies.value = false;
    }
  }

  Map<String, dynamic>? get selectedStrategy {
    if (selectedStrategyId.value.isEmpty) return null;
    return strategies.firstWhereOrNull((s) => s['id'].toString() == selectedStrategyId.value);
  }

  bool get showWhatsAppField {
    final strategy = selectedStrategy;
    if (strategy == null) return false;
    
    // TAREA 4 (v25.0.0): Sincronización de tags con el servidor (Búsqueda exhaustiva + Obligatorio en Master)
    final String prompt = strategy['prompt_base']?.toString().toUpperCase() ?? "";
    final String name = strategy['name']?.toString().toUpperCase() ?? "";
    
    return prompt.contains('[NUMERO_WHATSAPP]') || 
           prompt.contains('[WHATSAPP]') || 
           prompt.contains('[CONTACT_PHONE]') ||
           name.contains('MASTER') ||
           name.contains('PREMIUM') ||
           selectedStrategyId.value == 'master';
  }

  Future<void> generateLandingTemplate() async {
    if (selectedProductId.value.isEmpty) {
      Get.snackbar(
        "Atención",
        "Selecciona un producto primero",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
      );
      return;
    }

    if (contactPhone.value.trim().isEmpty) {
      Get.snackbar(
        "WhatsApp Requerido",
        "Ingresa tu número de WhatsApp para los botones de la landing.",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
      );
      return;
    }

    try {
      isLoading(true);
      landingUrl.value = ""; 
      
      final String token = SessionManager.instance.token ?? "";
      
      if (token.isEmpty) {
        Get.offAllNamed('/login');
        return;
      }

      final Map<String, dynamic> bodyParams = {
        "product_id": selectedProductId.value,
        "whatsapp_number": contactPhone.value.trim(),
        "template_id": "landing.html"
      };

      print('🚀 [AI LANDING] Generando Landing con nuevo motor backend...');
      print('📦 [AI LANDING] Payload: ${jsonEncode(bodyParams)}');

      final response = await http.post(
        Uri.parse('https://embajadoresx.com/Subscription_Plan/generate_landing_template'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(bodyParams),
      ).timeout(const Duration(seconds: 60));

      print('📊 [AI LANDING] Status Code: ${response.statusCode}');
      print('📄 [AI LANDING] Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isSuccess = data['status'] == 1 || data['status'] == true;

        if (isSuccess) {
          landingUrl.value = data['url']?.toString() ?? "";
          print('✅ [AI LANDING] ¡Éxito! URL: ${landingUrl.value}');
        } else {
          final String errorMsg = data['message']?.toString() ?? "Error al generar la landing.";
          Get.snackbar("Error", errorMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error de Servidor", "Error ${response.statusCode}", backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('❌ [AI LANDING] Error: $e');
      Get.snackbar("Error de Conexión", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> generateLanding() async {
    final strategy = selectedStrategy;
    if (selectedProductId.value.isEmpty || strategy == null) {
      Get.snackbar(
        "Atención",
        "Selecciona un producto y una estrategia",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
      );
      return;
    }

    // v1.1.0: Se elimina restricción de 9 dígitos para permitir números internacionales
    if (showWhatsAppField && contactPhone.value.trim().isEmpty) {
      Get.snackbar(
        "WhatsApp Requerido",
        "Ingresa tu número de WhatsApp para los botones de la landing.",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
      );
      return;
    }

    try {
      isLoading(true);
      landingUrl.value = ""; 
      landingText.value = "";
      
      final String currentUserIdStr = Get.find<DashboardController>().userId.value;
      final String token = SessionManager.instance.token ?? "";
      
      // TAREA 2 (v12.0.0): Procesamiento de Tags
      String finalPrompt = strategy['prompt_base'] ?? "";
      
      // Reemplazar [PRODUCT_NAME]
      if (Get.isRegistered<VendorProductsController>()) {
        final products = Get.find<VendorProductsController>().vendorProducts.value?.products ?? [];
        final p = products.firstWhereOrNull((p) => p.id == selectedProductId.value);
        if (p != null) {
          finalPrompt = finalPrompt.replaceAll('[PRODUCT_NAME]', p.name);
        }
      }

      // Reemplazar [NUMERO_WHATSAPP]
      if (showWhatsAppField) {
        finalPrompt = finalPrompt.replaceAll('[NUMERO_WHATSAPP]', contactPhone.value);
      }

      // TAREA 1 (v19.0.0): POST a Subscription_Plan/generate_landing_copy
      Map<String, dynamic> bodyParams = {
        'user_id': int.tryParse(currentUserIdStr) ?? 37,
        'product_id': int.tryParse(selectedProductId.value) ?? 0,
        'contact_phone': contactPhone.value,
        'strategy': selectedStrategyId.value == 'master' ? 'master_landing_ex' : selectedStrategyId.value,
        'final_prompt': finalPrompt,
      };

      print('🤖 [AI LANDING PRO] Iniciando generación con motor Senior EX...');
      print('📦 [AI LANDING] Payload PRO: ${jsonEncode(bodyParams)}');

      final response = await http.post(
        Uri.parse('https://embajadoresx.com/Subscription_Plan/generate_landing_copy'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(bodyParams),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // TAREA 1 (v48.0.0): VALIDACIÓN DE ÉXITO ROBUSTA (Acepta 1, true, '1', 'true')
        final bool isSuccess = data['status'] == 1 || 
                             data['status'] == true || 
                             data['status']?.toString() == "1" || 
                             data['status']?.toString() == "true";

        if (isSuccess) {
          // TAREA 5 (v19.0.0): Atribución ref_id=37 en checkout_url
          landingUrl.value = data['landing_url']?.toString() ?? "";
          // TAREA 2 (v25.0.0): Conectar campo texto_ia (Prioritario)
          landingText.value = data['texto_ia']?.toString() ?? data['generated_text']?.toString() ?? "";
          print('✅ [AI LANDING PRO] ¡Éxito! URL generada: ${landingUrl.value}');
        } else {
          // TAREA 1 (v47.0.0): LOG CRUDO DEL ERROR (status: false)
          print('DEBUG ERROR RESPONSE (status:false): ${response.body}');
          
          final String errorMsg = data['message']?.toString() ?? data['msg']?.toString() ?? data['error']?.toString() ?? "El servidor devolvió status:false sin mensaje.";
          print('❌ ERROR DE SERVIDOR: $errorMsg');
          Get.snackbar(
            "Error de Generación", 
            errorMsg, 
            backgroundColor: Colors.redAccent, 
            colorText: Colors.white,
            duration: const Duration(seconds: 10),
          );
        }
      } else {
        // TAREA 1 (v47.0.0): LOG CRUDO DEL ERROR (statusCode != 200)
        print('DEBUG ERROR RESPONSE (status:${response.statusCode}): ${response.body}');
        
        String errorMsg = "Error del Servidor (${response.statusCode})";
        try {
          final data = jsonDecode(response.body);
          errorMsg = data['message']?.toString() ?? data['msg']?.toString() ?? data['error']?.toString() ?? errorMsg;
        } catch (_) {}

        Get.snackbar(
          "Error de Servidor", 
          errorMsg, 
          backgroundColor: Colors.redAccent, 
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
        );
      }
    } catch (e) {
      // TAREA 2 (v46.0.0): IMPRIMIR EL ERROR REAL EN CONSOLA
      print('❌ ERROR CRÍTICO DE GENERACIÓN: $e');
      if (e is dio.DioException) print('❌ RESPUESTA DEL SERVIDOR: ${e.response?.data}');
      
      String errorMsg = "Error: $e";
      if (e.toString().contains("TimeoutException")) {
        errorMsg = "TIMEOUT (120s): La IA tardó demasiado tiempo en responder. El servidor podría estar saturado.";
      }
      
      Get.snackbar(
        "Error de Conexión", 
        errorMsg, 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );
    } finally {
      isLoading(false);
    }
  }

  void reset() {
    landingUrl.value = "";
    landingText.value = "";
    selectedProductId.value = "";
    userPrompt.value = "";
    selectedStrategyId.value = "";
    contactPhone.value = "";
  }
}
