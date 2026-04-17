import 'dart:convert';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:get/get.dart';

class AdminWalletService extends GetxController {
  static final AdminWalletService instance = Get.isRegistered<AdminWalletService>() 
      ? Get.find<AdminWalletService>() 
      : Get.put(AdminWalletService._());
      
  AdminWalletService._();

  // Lista reactiva para las comisiones pendientes
  final RxList<dynamic> pendingList = <dynamic>[].obs;
  final RxBool isLoadingCommissions = false.obs;

  Future<dynamic> getAdminWallet() async {
    print("📡 [ADMIN] Solicitando Billetera Global (admin_api)...");
    try {
      final user = await SharedPreference.getUserData();
      final String token = user?.data?.token ?? '';

      if (token.isEmpty) return null;

      const String finalUrl = 'https://embajadoresx.com/admin_api/wallet';
      
      final response = await ApiService.instance.dio.get(
        finalUrl,
        options: dio_pkg.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      print("📦 [ADMIN RAW DATA]: ${response.data}");

      if (response.data is String && response.data.toString().contains('<!DOCTYPE html>')) {
        return null;
      }

      final rawData = response.data is String ? jsonDecode(response.data) : response.data;
      
      if (rawData != null && rawData['status'] == true) {
         return rawData['data']; 
      }
      return null;
    } catch (e) {
      print("🔥 [ADMIN ERROR]: $e");
      return null;
    }
  }

  Future<void> fetchPendingCommissions() async {
    print("📡 [ADMIN] Solicitando Historial para Filtrado Local (v1.4.2)...");
    isLoadingCommissions.value = true;
    try {
      final user = await SharedPreference.getUserData();
      final String token = user?.data?.token ?? '';

      if (token.isEmpty) return;

      const String finalUrl = 'https://embajadoresx.com/admin_api/wallet';
      
      final response = await ApiService.instance.dio.get(
        finalUrl,
        options: dio_pkg.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      final rawData = response.data is String ? jsonDecode(response.data) : response.data;
      
      if (rawData != null && rawData['status'] == true) {
        List<dynamic> allTransactions = rawData['data']['transactions'] ?? [];
        
        // FILTRO MAESTRO: Solo aquellas con commission_status == 0
        List<dynamic> pendingOnly = allTransactions.where((t) {
          return t['commission_status'].toString() == '0';
        }).toList();

        pendingList.assignAll(pendingOnly);
        print("✅ [ADMIN] Filtro Local Exitoso: ${pendingList.length} comisiones pendientes encontradas.");
      }
    } catch (e) {
      print("🔥 [ADMIN PENDING ERROR]: $e");
    } finally {
      isLoadingCommissions.value = false;
    }
  }

  Future<bool> updateCommissionStatus(int commissionId, int status) async {
    print("📡 [ADMIN] Actualizando Comisión: $commissionId -> $status");
    try {
      final user = await SharedPreference.getUserData();
      final String token = user?.data?.token ?? '';

      if (token.isEmpty) return false;

      final formData = dio_pkg.FormData.fromMap({
        'id': commissionId,
        'status': status,
      });

      const String finalUrl = 'https://embajadoresx.com/admin_api/update_commission_status';

      final response = await ApiService.instance.dio.post(
        finalUrl,
        data: formData,
        options: dio_pkg.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      final rawData = response.data is String ? jsonDecode(response.data) : response.data;
      if (rawData != null && rawData['status'] == true) {
        print("✅ [ADMIN] Estado actualizado. Refrescando lista...");
        // Eliminamos el ítem localmente para una UI inmediata o refrescamos todo
        pendingList.removeWhere((item) => item['id'].toString() == commissionId.toString());
        return true;
      }
      return false;
    } catch (e) {
      print("🔥 [ADMIN COMM ERROR]: $e");
      return false;
    }
  }
}
