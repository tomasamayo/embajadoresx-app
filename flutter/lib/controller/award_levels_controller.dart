import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/award_levels_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';

class AwardLevelsController extends GetxController {
  bool _isLoading = false;
  AwardLevelsResponse? _response;
  bool _hasShownCelebration = false;

  bool get isLoading => _isLoading;
  AwardLevelsResponse? get response => _response;
  bool get hasShownCelebration => _hasShownCelebration;

  void markCelebrationAsShown() {
    _hasShownCelebration = true;
    update();
  }

  Future<void> fetch({bool withUser = true}) async {
    _isLoading = true;
    update();

    try {
      String? token;
      String? userId;
      
      // 1. Obtener Token y ID de SharedPreferences (LOGICA DE EMERGENCIA 1)
      final userModel = await SharedPreference.getUserData();
      token = userModel?.data?.token;
      userId = userModel?.data?.userId?.toString();
      
      if (token == null || token.isEmpty) {
        debugPrint('Error: No se encontró token de autenticación.');
        _isLoading = false;
        update();
        return;
      }

      // 2. OBTENER USER ID SI FALLA SHARED PREFERENCE (Paso 1)
      if (userId == null || userId.isEmpty || userId == 'null') {
        debugPrint('ID en SharedPreferences nulo, intentando obtener del perfil...');
        final profile = await ApiService.instance.getData('User/get_my_profile_details', token: token);
        
        if (profile != null && profile['data'] != null) {
          final data = profile['data'];
          if (data is Map<String, dynamic>) {
            // Búsqueda exhaustiva en múltiples niveles
            userId = (data['id'] ?? 
                     data['user_id'] ?? 
                     data['id_usuario'] ?? 
                     data['userId'] ??
                     (data['user'] is Map ? data['user']['id'] : null) ??
                     (data['user'] is Map ? data['user']['user_id'] : null))?.toString();
          }
          debugPrint('User ID obtenido de perfil (get_my_profile_details): $userId');
        }
      } else {
        debugPrint('User ID cargado de SharedPreferences: $userId');
      }

      // 3. VALIDAR USER ID ANTES DE LLAMAR A NIVELES
      if (userId == null || userId.isEmpty || userId == 'null') {
        debugPrint('Error: No se pudo obtener el User ID real. Abortando carga de niveles.');
        _response = null;
        return;
      }

      // 4. LLAMAR A NIVELES CON EL ID AL FINAL (URL CORRECTA SEGUN NUEVA API)
      final endpoint = 'Api/get_award_levels/$userId';
      
      debugPrint('LLAMADA CRÍTICA: $endpoint con token: ${token.substring(0, 10)}...');
      final data = await ApiService.instance.getData(endpoint, token: token);

      if (data != null) {
        debugPrint('RESPUESTA API NIVELES (JSON): $data');
        _response = AwardLevelsResponse.fromJson(data);
        debugPrint('User Stats Recibidas: Balance=${_response?.userStats?.userBalance}, Sales=${_response?.userStats?.totalPersonalSales}, Patrocinios=${_response?.userStats?.userPatrocinios}');
      } else {
        debugPrint('Error: La API de niveles devolvió null.');
      }
    } catch (e) {
      debugPrint('Error en flujo de datos crítico: $e');
    } finally {
      _isLoading = false;
      update(); // GetX refresca la UI (equivale a setState)
    }
  }
}
