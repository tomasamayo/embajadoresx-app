
import 'package:get/get.dart';
import '../service/api_service.dart';
import '../utils/session_manager.dart';
import '../model/admin_model.dart';
import 'package:flutter/material.dart';

class AdminController extends GetxController {
  var isLoadingDashboard = false.obs;
  var adminDashboard = Rxn<AdminDashboard>();

  var isLoadingNetwork = false.obs;
  var rootNodes = <GlobalNetworkNode>[].obs;

  var isLoadingComplaints = false.obs;
  var complaints = <Complaint>[].obs;

  // 1. Dashboard Pro
  Future<void> getAdminDashboard() async {
    isLoadingDashboard(true);
    try {
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData('Admin_Api/dashboard', token: token);

      debugPrint('🔍 [ADMIN DASHBOARD RAW]: $response');

      final String status = response?['status']?.toString() ?? 'false';

      if (response != null && (status == '1' || status == 'true' || status == '200')) {
        final rawData = response['data'];
        if (rawData is Map) {
          // SOLUCIÓN CLAVE: Map.from() convierte Map<String, Object> → Map<String, dynamic>
          adminDashboard.value = AdminDashboard.fromJson(Map<String, dynamic>.from(rawData));
        }
      } else if (response != null && (response['code']?.toString() == '403')) {
        _showAccessDenied();
      }
    } catch (e, stack) {
      debugPrint("Error fetching admin dashboard: $e");
      debugPrint("Stack: $stack");
    } finally {
      isLoadingDashboard(false);
    }
  }

  // 2. Red Global
  Future<void> getGlobalNetwork() async {
    isLoadingNetwork(true);
    try {
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData('Admin_Api/global_network', token: token);

      debugPrint('🔍 [ADMIN NETWORK RAW]: $response');

      final String status = response?['status']?.toString() ?? 'false';

      if (response != null && (status == '1' || status == 'true' || status == '200')) {
        // SOLUCIÓN CLAVE: nunca usar 'as List?' — usar 'is List' para verificar tipo
        final rawData = response['data'];
        if (rawData is List) {
          rootNodes.value = rawData
              .map((n) => GlobalNodeWrapper.parseNode(
                  n is Map ? Map<String, dynamic>.from(n) : <String, dynamic>{}))
              .toList();
        }
      } else if (response != null && (response['code']?.toString() == '403')) {
        _showAccessDenied();
      }
    } catch (e, stack) {
      debugPrint("Error fetching global network: $e");
      debugPrint("Stack: $stack");
    } finally {
      isLoadingNetwork(false);
    }
  }

  // 3. Libro de Reclamaciones
  Future<void> getComplaints() async {
    isLoadingComplaints(true);
    try {
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData('Admin_Api/complaints', token: token);

      debugPrint('🔍 [ADMIN COMPLAINTS RAW]: $response');

      final String status = response?['status']?.toString() ?? 'false';

      if (response != null && (status == '1' || status == 'true' || status == '200')) {
        // SOLUCIÓN CLAVE: nunca usar 'as List?' — usar 'is List'
        final rawData = response['data'];
        if (rawData is List) {
          complaints.value = rawData
              .map((c) => Complaint.fromJson(
                  c is Map ? Map<String, dynamic>.from(c) : <String, dynamic>{}))
              .toList();
        }
      } else if (response != null && (response['code']?.toString() == '403')) {
        _showAccessDenied();
      }
    } catch (e, stack) {
      debugPrint("Error fetching complaints: $e");
      debugPrint("Stack: $stack");
    } finally {
      isLoadingComplaints(false);
    }
  }

  void _showAccessDenied() {
    Get.snackbar(
      "Acceso Denegado",
      "No tienes permisos de administrador para ver esta sección.",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
