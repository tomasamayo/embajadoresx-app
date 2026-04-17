import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../model/vendor_coupon_model.dart';
import '../service/api_service.dart';
import '../utils/session_manager.dart';

class VendorCouponsController extends GetxController {
  final SharedPreferences preferences;
  VendorCouponsController({required this.preferences});

  var isLoading = false.obs;
  var coupons = <VendorCoupon>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCoupons();
  }

  Future<void> getCoupons() async {
    try {
      print('[CUPONES] Pidiendo data actualizada...');
      isLoading(true);
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData('Subscription_Plan/get_vendor_coupons', token: token);

      if (response != null) {
        // TAREA 1: REVELACIÓN DEL JSON CRUDO
        print('📡 [REVELACIÓN] JSON CRUDO DEL SERVIDOR: ${jsonEncode(response)}');

        final model = VendorCouponModel.fromJson(response);
        coupons.assignAll(model.data);
        
        print('[CUPONES] El servidor entrego ${coupons.length} cupones reales.');
        if (coupons.isNotEmpty) {
          print('[CUPONES] Primer cupon detectado: ${coupons[0].code}');
        }
      } else {
        print('[CUPONES] No se pudieron sincronizar los cupones (Respuesta nula)');
      }
    } catch (e) {
      print("[CUPONES] Error fetching coupons: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteCoupon(VendorCoupon coupon) async {
    try {
      // TAREA 3: LOG DE SEGURIDAD (DIFERENTE) - RASTREO DE OBJETO
      print('🕵️ [RASTREO] Cupon recibido en controller: ${coupon.name} | ID: ${coupon.id}');

      if (coupon.id.isEmpty) {
        print('❌ [ERROR] ID nulo o vacio detectado en deleteCoupon');
        throw Exception("ID nulo detectado");
      }
      
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.deleteData(
        'Subscription_Plan/delete_vendor_coupon?coupon_id=${coupon.id}',
        token: token,
      );

      if (response != null && response['status'] == true) {
        // TAREA 3: REFRESH AUTOMÁTICO (getCoupons)
        coupons.removeWhere((element) => element.id == coupon.id);
        Get.snackbar(
          "Exito", 
          "Cupon eliminado correctamente", 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
        );
        getCoupons(); 
        return true;
      } else {
        String errorMsg = response?['message'] ?? "Error: El cupon no existe o la ruta es incorrecta";
        print('❌ [BORRADO FALLIDO] Servidor respondio: $errorMsg');
        
        Get.snackbar(
          "Error de Eliminacion", 
          errorMsg, 
          backgroundColor: Colors.redAccent, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
        );
        return false;
      }
    } catch (e) {
      print("❌ [EXCEPCION BORRADO] Error: $e");
      return false;
    }
  }

  Future<void> manageCoupon({
    String? id,
    required String name,
    required String code,
    required String type,
    required String discount,
    required String dateStart,
    required String dateEnd,
    required String usesTotal,
    required String status,
    required String allowFor,
    required List<String> productIds,
  }) async {
    try {
      print('[CUPONES] Intentando ${id == null ? "crear" : "editar"} cupon: $code');
      isLoading(true);
      final token = SessionManager.instance.token;
      Map<String, dynamic> body = {
        'name': name,
        'code': code, // TAREA 1: Cambiado de 'coupon_code' a 'code'
        'type': type,
        'discount': discount,
        'date_start': dateStart,
        'date_end': dateEnd,
        'uses_total': usesTotal,
        'status': status,
        'allow_for': allowFor,
      };
      
      // TAREA 2: Vinculación de productos (Key: products[])
      for (int i = 0; i < productIds.length; i++) {
        body['products[$i]'] = productIds[i];
      }

      if (id != null) body['id'] = id;

      // TAREA 3: REVISION DE LOGS POST
      print('[PAQUETE POST] allow_for: $allowFor');
      print('[PAQUETE POST] products: $productIds');
      print('[API POST] Enviando Cupon: ${jsonEncode(body)}');

      final response = await ApiService.instance.postData2(
        'Subscription_Plan/manage_vendor_coupon',
        body,
        token: token,
      );

      if (response != null) {
        print('[API RESPONSE] Status: ${response['status']} | Body: $response');

        if (response['status'] == true) {
          getCoupons(); // Sincronizacion automatica
          _showSuccessModal(code); // TAREA 2 y 3: Modal Esmeralda VIP
        } else {
          // TAREA 4: Log de error ya esta en ApiService, pero lo reforzamos aqui
          print('[CUPONES] Error del servidor: ${response['message'] ?? response}');
          Get.snackbar(
            "Error", 
            response['message'] ?? "Error al procesar cupon", 
            backgroundColor: Colors.redAccent, 
            colorText: Colors.white
          );
        }
      } else {
        print('[CUPONES] Respuesta del servidor fue NULL o Error 422');
        Get.snackbar(
          "Error de Conexion", 
          "El servidor no respondio. Verifica los logs (Tarea 4).", 
          backgroundColor: Colors.orangeAccent, 
          colorText: Colors.black
        );
      }
    } catch (e) {
      print("[CUPONES] Error managing coupon: $e");
    } finally {
      isLoading(false);
    }
  }

  void _showSuccessModal(String couponCode) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00FF88), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de check animado
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: const Icon(Icons.check_circle_outline, color: Color(0xFF00FF88), size: 80),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
                child: const Text(
                  "¡CUPÓN FORJADO!",
                  style: TextStyle(
                    color: Color(0xFF00FF88),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 1.5,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              FadeIn(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  "El cupón $couponCode se ha creado correctamente.",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Cierra el modal
                      Get.back(result: true); // Vuelve a la pantalla anterior (Lista)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF88),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 10,
                      shadowColor: const Color(0xFF00FF88).withOpacity(0.3),
                    ),
                    child: const Text(
                      "ENTENDIDO",
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
