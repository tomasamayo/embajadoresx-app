import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:affiliatepro_mobile/view/screens/login/login.dart';
import 'dashboard_controller.dart';
import '../model/loglist_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';

class LoglistController extends GetxController {
  LoglistController({required this.preferences});
  SharedPreferences preferences;

  bool _isLoading = false;
  bool _isLoglistLoading = false;
  LogListModel? _LoglistModel;

  // TAREA 1: 4 OBSERVABLES INDEPENDIENTES (v1.9.0)
  final urlTienda = "".obs;
  final compartirTienda = "".obs;
  final invitarProveedores = "".obs;
  final invitarAfiliados = "".obs;

  bool get isLoading => _isLoading;
  bool get isLoglistLoading => _isLoglistLoading;
  LogListModel? get LoglistData => _LoglistModel;

  String paid = 'paid';
  String action = 'actions';

  changeIsLoading(bool data) {
    _isLoading = data;
    update();
  }

  changeLoglistLoading(bool data) {
    _isLoglistLoading = data;
    update();
  }

  // TAREA 1: EL PAYLOAD EXACTO (v1.8.8)
  Future<dynamic> updateAffiliateLinks(String newSlug, String linkType) async {
    // REQUERIMIENTO v1.8.7: Extraer el ID desde la misma fuente que el Drawer (DashboardController)
    dynamic userIdDinamico;
    
    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      userIdDinamico = dash.loginModel?.data?.userId;
      
      // TAREA 3: ESCÁNER DE MEMORIA (DEBUG EXTREMO)
      print('🗄️ [DUMP MEMORIA] Datos del usuario actual (DashboardController):');
      print('   - Firstname: ${dash.loginModel?.data?.firstname}');
      print('   - UserID (Raw): $userIdDinamico');
      print('   - IsVendor: ${dash.loginModel?.data?.isVendor}');
    }

    // Fallback a SharedPreferences si el controlador no tiene el dato, pero sin redirección
    if (userIdDinamico == null) {
      final String? userIdRaw = preferences.getString('user_id') ?? preferences.getString('id');
      userIdDinamico = int.tryParse(userIdRaw ?? "");
      print('🗄️ [DUMP MEMORIA] Datos recuperados de SharedPreferences: $userIdDinamico');
    }

    if (userIdDinamico == null) {
      print('❌ [ENLACES] Error: User ID sigue siendo NULL tras escaneo. No se puede proceder.');
      
      Get.snackbar(
        "Atención", 
        "No se pudo verificar tu identidad. Intenta recargar el inicio.",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return {"success": false, "message": "ID no encontrado"};
    }

    // TAREA 1: EL TIPO AHORA ES DINÁMICO (v1.8.8)
    final String urlEndpoint = ApiService.updateAffiliateLinkUrl;
    final Map<String, String> payload = {
      'user_id': userIdDinamico.toString(),
      'related_id': userIdDinamico.toString(), // CRÍTICO: related_id == user_id para tiendas
      'new_slug': newSlug,
      'type': linkType, // TAREA 1: Uso de parámetro dinámico (store, register, etc.)
    };

    print('🔎 [ENLACES] Intentando actualizar alias desde Loglist...');
    print('📡 [ENLACES] URL: $urlEndpoint');
    print('📦 [ENLACES] Payload dinámico: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        Uri.parse(urlEndpoint),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      print('📥 [ENLACES] Status Code: ${response.statusCode}');
      
      if (response.headers['content-type']?.contains('text/html') == true || 
          response.body.trim().startsWith('<!DOCTYPE html>') ||
          response.statusCode == 404) {
        return false;
      }

      final data = jsonDecode(response.body);
      
      if (data != null) {
        print('📥 [ENLACES] Respuesta JSON: ${jsonEncode(data)}');
        if (data['status'] == true) {
          // TAREA 4: ACTUALIZACIÓN INDIVIDUAL EN PANTALLA (v1.9.0)
          String newUrl = data['slug_url'] ?? "";
          
          if (newUrl.isNotEmpty) {
            // Actualizamos el observable específico según el linkType enviado (v1.9.0)
            switch (linkType) {
              case 'url_tienda':
                urlTienda.value = newUrl;
                if (_LoglistModel != null) _LoglistModel!.data.urlTienda = newUrl;
                break;
              case 'compartir_tienda':
                compartirTienda.value = newUrl;
                if (_LoglistModel != null) _LoglistModel!.data.compartirTienda = newUrl;
                break;
              case 'register_vendor':
                invitarProveedores.value = newUrl;
                if (_LoglistModel != null) _LoglistModel!.data.invitarProveedores = newUrl;
                break;
              case 'register_affiliate':
                invitarAfiliados.value = newUrl;
                if (_LoglistModel != null) _LoglistModel!.data.invitarAfiliados = newUrl;
                break;
            }
          }

          // REQUERIMIENTO v1.8.4: Sincronización con Dashboard si es necesario
          if (Get.isRegistered<DashboardController>()) {
            final dash = Get.find<DashboardController>();
            if (dash.dashboardData != null) {
              if (linkType == 'store') {
                dash.dashboardData!.data.affiliateStoreUrl = newUrl;
              } else if (linkType == 'register_affiliate' || linkType == 'register') {
                dash.dashboardData!.data.uniqueResellerLink = newUrl;
              }
              dash.update();
            }
          }
          
          update(); 
          return {"success": true, "slug_url": newUrl};
        } else {
          // TAREA 4: MANEJO DE ERROR (ALIAS REPETIDO) (v1.8.4)
          String errorMsg = data['message'] ?? "Error desconocido";
          return {"success": false, "message": errorMsg};
        }
      }
      return false;
    } catch (e) {
      print('❌ [ENLACES] Error Crítico: $e');
      return false;
    }
  }

  @override
  void onClose() {
    // TAREA 3: LIMPIEZA DE CONTROLLER (v1.7.7)
    print('🧹 [SISTEMA] Cerrando LoglistController para liberar memoria y evitar conflictos.');
    super.onClose();
  }

  updateLoglistData(LogListModel model) {
    _LoglistModel = model;
    // TAREA 1: SINCRONIZAR OBSERVABLES (v1.9.0)
    urlTienda.value = model.data.urlTienda;
    compartirTienda.value = model.data.compartirTienda;
    invitarProveedores.value = model.data.invitarProveedores;
    invitarAfiliados.value = model.data.invitarAfiliados;
    update();
  }

  updateActionAndPaid(paidStatus, type) {
    if (paidStatus != null) paid = paidStatus;
    if (type != null) action = type;
  }

  getLoglistData(int pageId, int perPage) async {
    changeLoglistLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    final userId = userModel?.data?.userId; // TAREA 2: EXTRAER USER ID
    
    String endPoint = 'My_Log/my_log_list';
    
    // TAREA 2: ASEGURAR PAYLOAD CON USER_ID (v54.0.0)
    final Map<String, dynamic> requestBody = {
      'page_id': pageId > 0 ? pageId : 1,
      'per_page': 20,
      'user_id': userId, // Inyectamos el ID de usuario para evitar el 422
    };

    try {
      final value = await ApiService.instance.postData(endPoint, requestBody);
      debugPrint('Get Loglist : ${jsonEncode(value)}');

      if (value != null &&
          value is Map<String, dynamic> &&
          (value['status'] == true || value['status'] == 1) && // Blindaje de status
          value['data'] != null) {
        updateLoglistData(LogListModel.fromJson(value));
      } else {
        updateLoglistData(LogListModel(
          status: false,
          message: 'No data found',
          data: LogListData(
            clicks: [],
            startFrom: 0,
            affiliateStoreUrl: '',
            uniqueResellerLink: '',
            urlTienda: '',
            compartirTienda: '',
            invitarProveedores: '',
            invitarAfiliados: '',
          ),
        ));
      }
    } catch (e) {
      debugPrint('Error loading loglist: $e');
      updateLoglistData(LogListModel(
        status: false,
        message: 'Error occurred',
        data: LogListData(
          clicks: [],
          startFrom: 0,
          affiliateStoreUrl: '',
          uniqueResellerLink: '',
          urlTienda: '',
          compartirTienda: '',
          invitarProveedores: '',
          invitarAfiliados: '',
        ),
      ));
    }

    changeLoglistLoading(false);
  }
}