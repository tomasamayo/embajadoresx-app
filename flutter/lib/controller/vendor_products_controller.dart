import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/api_service.dart';
import '../model/vendor_product_model.dart';
import '../utils/session_manager.dart';
import 'dashboard_controller.dart';

class VendorProductsController extends GetxController {
  final SharedPreferences preferences;
  VendorProductsController({required this.preferences});

  var isLoading = false.obs;
  var vendorProducts = Rxn<VendorProductsModel>();
  
  // TAREA: Catálogo Global para IA Landing (v1.2.9)
  var globalProducts = Rxn<VendorProductsModel>();

  @override
  void onInit() {
    super.onInit();
    getVendorProducts();
    getGlobalCatalog(); // Carga inicial del catálogo global
  }

  Future<void> getGlobalCatalog() async {
    try {
      final String token = SessionManager.instance.token ?? "";
      // REQUERIMIENTO: Sin vendor_id para ver todo el catálogo (IA Landing)
      final String fullUrl = 'https://embajadoresx.com/Subscription_Plan/get_vendor_products?v=${DateTime.now().millisecondsSinceEpoch}';
      
      print('[CATÁLOGO GLOBAL] Cargando desde: $fullUrl');
      isLoading(true);
      
      final responseHttp = await http.get(
        Uri.parse(fullUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (responseHttp.statusCode == 200) {
        final response = jsonDecode(responseHttp.body);
        globalProducts.value = VendorProductsModel.fromJson(response);
        print('[CATÁLOGO GLOBAL] ${globalProducts.value?.products.length ?? 0} productos cargados.');
      }
    } catch (e) {
      print("[CATÁLOGO GLOBAL] Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> getVendorProducts() async {
    try {
      final String token = SessionManager.instance.token ?? "";
      // TAREA 1: FILTRADO POR VENDOR_ID (v1.2.9) - Se agrega user_id de DashboardController para evitar catálogo global
      final String userId = Get.find<DashboardController>().userId.value;
      final String fullUrl = 'https://embajadoresx.com/Subscription_Plan/get_vendor_products?v=${DateTime.now().millisecondsSinceEpoch}&vendor_id=$userId';
      
      // TAREA 2: TOKEN CON CABECERAS EXPLICITAS (v36.0.0)
      print('DEBUG TOKEN PRO: $token');
      print('[LISTADO] Cargando productos desde: $fullUrl');
      isLoading(true);
      
      if (token.isEmpty) {
        print('[LISTADO] Error: Token nulo en SessionManager. Redirigiendo a Login.');
        isLoading(false);
        Get.offAllNamed('/login'); 
        return;
      }

      // Bypass del ApiService para asegurar headers puros
      final responseHttp = await http.get(
        Uri.parse(fullUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (responseHttp.statusCode == 200) {
        try {
          // TAREA 1 (v42.0.0): IMPRIMIR JSON CRUDO
          print('DEBUG RAW JSON: ${responseHttp.body}');
          
          final response = jsonDecode(responseHttp.body);
          
          // TAREA 1: VALIDACIÓN ROBUSTA DE RESPUESTA (v28.1.0)
          final bool isSuccess = response != null && (
            response['status'] == true || 
            response['status'] == 1 || 
            response['status']?.toString() == "true" || 
            response['status']?.toString() == "1"
          );

          if (isSuccess) {
            print('[LISTADO] Respuesta del servidor recibida correctamente');
            vendorProducts.value = VendorProductsModel.fromJson(response);
            
            final totalCount = vendorProducts.value?.products.length ?? 0;
            print('[LISTADO] Cantidad de productos detectados: $totalCount');
          } else {
            print('[LISTADO] El servidor respondio con error en el body.');
          }
        } catch (jsonError) {
          // TAREA 1 (v40.0.0): CAPTURAR ERROR HTML Y DIAGNOSTICAR
          print('❌ ERROR RESPUESTA SERVIDOR (JSON INVÁLIDO): $jsonError');
          print('📄 CONTENIDO RECIBIDO (HTML?): ${responseHttp.body}');
          
          // TAREA 2 (v40.0.0): MOSTRAR ALERTA AL USUARIO
          Get.snackbar(
            "Error del Servidor",
            "El catálogo no pudo cargar. Informa al soporte.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (responseHttp.statusCode == 403 || responseHttp.statusCode == 401) {
        print('🛡️ [BYPASS] Detectado ${responseHttp.statusCode}. Acceso denegado.');
        if (responseHttp.statusCode == 401) {
          print("🚨 ERROR 401 DETECTADO 🚨");
          try {
            final decodedBody = jsonDecode(responseHttp.body);
            print("📝 DEBUG INFO DEL BACKEND: ${decodedBody['debug_info']}");
            print("📝 MENSAJE COMPLETO: ${responseHttp.body}");
          } catch (e) {
            print("📝 NO SE PUDO DECODIFICAR EL BODY DEL 401");
          }

          Get.snackbar(
            "Sesión Expirada",
            "Por favor, vuelve a iniciar sesión para cargar los productos.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print('[LISTADO] Error de servidor: ${responseHttp.statusCode}');
      }
    } catch (e) {
      print("[LISTADO] Error fetching vendor products: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.deleteData(
        'Subscription_Plan/delete_vendor_product?product_id=$id',
        token: token,
      );

      // TAREA 2: VALIDACIÓN ROBUSTA DE ELIMINACIÓN (v28.1.0)
      final bool isSuccess = response != null && (
        response['status'] == true || 
        response['status'] == 1 || 
        response['status']?.toString() == "true" || 
        response['status']?.toString() == "1"
      );

      if (isSuccess) {
        Get.snackbar(
          "Éxito", 
          "Producto eliminado correctamente", 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
        );
        getVendorProducts();
        return true;
      } else {
        Get.snackbar(
          "Error", 
          response?['message'] ?? "No se pudo eliminar el producto", 
          backgroundColor: Colors.redAccent, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error deleting product: $e");
      return false;
    }
  }

  List<VendorProduct> get activeProducts => 
    vendorProducts.value?.products.where((p) => p.status == "1" || p.status.toString().toLowerCase() == "active").toList() ?? [];

  List<VendorProduct> get activeGlobalProducts => 
    globalProducts.value?.products.where((p) => p.status == "1" || p.status.toString().toLowerCase() == "active").toList() ?? [];

  List<VendorProduct> get reviewProducts => 
    vendorProducts.value?.products.where((p) => p.status != "1" && p.status.toString().toLowerCase() != "active").toList() ?? [];

  int get pendingCount => vendorProducts.value?.pendingCount ?? 0;
}
