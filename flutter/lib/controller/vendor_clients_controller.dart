import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/vendor_client_model.dart';
import '../service/api_service.dart';
import '../utils/session_manager.dart';

class VendorClientsController extends GetxController {
  final SharedPreferences preferences;
  VendorClientsController({required this.preferences});

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var clients = <VendorClient>[].obs;
  var currentPage = 1;
  var totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    getClients();
  }

  Future<void> getClients({bool refresh = true}) async {
    if (refresh) {
      currentPage = 1;
      isLoading(true);
    } else {
      if (currentPage >= totalPages) return;
      isMoreLoading(true);
      currentPage++;
    }

    try {
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData(
        'Subscription_Plan/get_vendor_clients?page=$currentPage',
        token: token,
      );

      if (response != null) {
        final model = VendorClientModel.fromJson(response);
        if (refresh) {
          clients.assignAll(model.data);
        } else {
          clients.addAll(model.data);
        }
        if (model.pagination != null) {
          totalPages = model.pagination!.totalPages;
          currentPage = model.pagination!.currentPage;
        }

        // LOG DE DEPURACIÓN
        print('👥 [CLIENTES] Cantidad recibida: ${clients.length} | Página actual: $currentPage');
      }
    } catch (e) {
      debugPrint("Error fetching vendor clients: $e");
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }
}
