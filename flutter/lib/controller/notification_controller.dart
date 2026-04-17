import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/notification_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';

class NotificationsController extends GetxController {
  bool _isLoading = false;
  NotificationsListModel? _notificationsModel;
  int _pageId = 1;
  final int _perPage = 100;

  // 🛡️ LISTA NEGRA LOCAL (v1.9.0)
  // Guardamos los IDs borrados en la sesión actual para evitar que reaparezcan por lag de servidor
  final Set<String> _deletedIds = {};

  bool get isLoading => _isLoading;
  NotificationsListModel? get notificationsData => _notificationsModel;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 NotificationsController: onInit called');
  }

  void changeLoading(bool value) {
    _isLoading = value;
    update();
  }

  void updateData(NotificationsListModel model) {
    // APLICAR FILTRO MAESTRO (v1.9.0)
    // Filtramos los datos frescos contra nuestra "Lista Negra" local
    if (_deletedIds.isNotEmpty) {
      model.data.removeWhere((item) => _deletedIds.contains(item.id));
    }
    
    _notificationsModel = model;
    update();
  }

  Future<void> getNotificationsData() async {
    if (_isLoading) return;
    
    // 1️⃣ LIMPIEZA PREVIA (HARD REFRESH v1.8.0)
    _notificationsModel = null; 
    update();
    
    changeLoading(true);

    try {
      final user = await SharedPreference.getUserData();
      final token = user?.data?.token;
      final userId = user?.data?.userId;

      if (token == null) {
        changeLoading(false);
        return;
      }

      const endPoint = 'Notification/notification_list';
      
      final body = {
        'page_id': _pageId, 
        'per_page': 20, 
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final res = await ApiService.instance.postData2(endPoint, body, token: token);

      if (res == null || (res['status'] != true && res['status'] != 1)) {
        updateData(
          NotificationsListModel(status: false, message: res?['message'] ?? 'No notifications', data: []),
        );
        return;
      }

      updateData(NotificationsListModel.fromJson(res));
    } catch (e) {
      debugPrint('🔔 [NOTIFICACIONES] Error: $e');
      updateData(NotificationsListModel(status: false, message: 'No notifications', data: []));
    } finally {
      changeLoading(false);
    }
  }

  // v1.7.5: Eliminación Optimista (Mejor rendimiento UI)
  Future<void> deleteNotificationOptimistically(int index) async {
    if (_notificationsModel == null || index < 0 || index >= _notificationsModel!.data.length) return;

    final deletedItem = _notificationsModel!.data[index];
    final String deletedId = deletedItem.id;

    // 🛡️ AGREGAR A LISTA NEGRA (v1.9.0)
    _deletedIds.add(deletedId);

    // 1️⃣ REMOCIÓN LOCAL (INSTANTÁNEA)
    _notificationsModel!.data.removeAt(index);
    update();

    print('🗑️ LOG: Intentando borrar en servidor ID: $deletedId (Index: $index)');
    print('1. Iniciando petición POST para ID: $deletedId (Index: $index)');

    try {
      final user = await SharedPreference.getUserData();
      final token = user?.data?.token;

      if (token == null) {
        _rollbackDeletion(index, deletedItem, 'Error de autenticación');
        return;
      }

      // 2️⃣ LLAMADA API REAL (CONFIGURACIÓN DEFINITIVA JSON)
      final int idAsInt = int.tryParse(deletedId) ?? 0;
      final Map<String, dynamic> data = {'notification_id': idAsInt};

      // v1.7.9: Verificación de URL sin slash extra
      final res = await ApiService.instance.postData2('Notification/delete_notification', data, token: token);

      print('2. Respuesta del servidor: $res');

      if (res != null && (res['status'] == true || res['status'] == 1)) {
        print('✅ [API] Borrado confirmado por el servidor.');
      } else {
        _rollbackDeletion(index, deletedItem, res?['message'] ?? 'Error de servidor');
      }
    } catch (e) {
      print('3. ERROR EN API: $e');
      _rollbackDeletion(index, deletedItem, 'Error de conexión');
    }
  }

  void _rollbackDeletion(int index, NotificationItem item, String error) {
    print('❌ [ROLLBACK] Restaurando notificación $index debido a: $error');
    
    // Rematamos de la lista negra si hay error
    _deletedIds.remove(item.id);

    if (_notificationsModel != null) {
      _notificationsModel!.data.insert(index, item);
      update();
    }

    Get.snackbar(
      '⚠️ ACCIÓN REVERTIDA', 
      'No se pudo eliminar la notificación. Reintentando...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  // // helper
  int min(int a, int b) => math.min(a, b);
}