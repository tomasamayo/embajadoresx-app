import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import '../model/vendor_order_model.dart';
import '../service/api_service.dart';
import '../utils/session_manager.dart';

class VendorOrdersController extends GetxController {
  final SharedPreferences preferences;
  VendorOrdersController({required this.preferences});

  var isLoading = false.obs;
  var orders = <VendorOrder>[].obs;
  var filteredOrders = <VendorOrder>[].obs;
  var orderDetail = Rxn<VendorOrderDetail>();
  var isDetailLoading = false.obs;
  var selectedFilter = "Todos".obs;
  var selectedFilterId = "".obs; // TAREA 2: ID numérico para el filtro
  var lastSearchQuery = "".obs;

  // TAREA 3: Estados dinámicos
  var orderStatuses = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    getOrderStatusList(); // Cargar estados primero
    getOrders();
  }

  Future<void> getOrderStatusList() async {
    try {
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData('Order/my_orders_status_list', token: token);

      if (response != null) {
        // TAREA 1: BLINDAJE INTEGRAL (Fix TypeError v1.4.4)
        List<Map<String, String>> fetchedStatuses = [];
        
        try {
          if (response is List) {
            for (var item in response) {
              if (item is Map) {
                fetchedStatuses.add({
                  'name': item['status_name']?.toString() ?? '',
                  'id': item['status_id']?.toString() ?? '',
                });
              }
            }
          } else if (response is Map) {
            final dynamic data = response['data'];
            if (data is List) {
              for (var item in data) {
                if (item is Map) {
                  fetchedStatuses.add({
                    'name': item['status_name']?.toString() ?? '',
                    'id': item['status_id']?.toString() ?? '',
                  });
                }
              }
            }
          }
          
          if (fetchedStatuses.isNotEmpty) {
            orderStatuses.assignAll(fetchedStatuses);
            print('🚀 [SISTEMA] ¡TODO LIMPIO! Sin TypeErrors en Estados.');
          }
        } catch (e) {
          debugPrint("Error parsing status list: $e");
        }
      }
    } catch (e) {
      debugPrint("Error fetching order status list: $e");
    }
  }

  Future<void> getOrders() async {
    try {
      isLoading(true);
      orders.clear(); // Limpiar antes de cargar
      final token = SessionManager.instance.token;
      
      String endPoint = 'Order/my_orders_list'; 
      Map<String, dynamic> dataMap = {
        'page_id': '1',
        'per_page': '10',
      };

      if (selectedFilter.value.toUpperCase() != "TODOS" && selectedFilterId.value.isNotEmpty) {
        dataMap['filter_status'] = selectedFilterId.value;
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await ApiService.instance.postData2(endPoint, formData, token: token);

      if (response != null) {
        // TAREA 1: BLINDAJE INTEGRAL (Fix TypeError v1.4.4)
        try {
          final dynamic responseData = response;
          List rawOrders = [];

          if (responseData is List) {
            rawOrders = responseData;
          } else if (responseData is Map) {
            if (responseData['data'] != null && responseData['data'] is Map && responseData['data']['orders'] != null) {
              rawOrders = responseData['data']['orders'] is List ? responseData['data']['orders'] : [];
            } else if (responseData['orders'] != null) {
              rawOrders = responseData['orders'] is List ? responseData['orders'] : [];
            }
          }
          
          orders.assignAll(rawOrders.map((e) => VendorOrder.fromJson(e)).toList());
          print('🚀 [SISTEMA] ¡TODO LIMPIO! Sin TypeErrors en Pedidos.');
          filteredOrders.assignAll(orders);
        } catch (e) {
          print('❌ [ERROR CRÍTICO EN MAPEO]: $e');
        }
      }
    } catch (e) {
      debugPrint("❌ Error en getOrders: $e");
    } finally {
      isLoading(false);
    }
  }

  void applyFilter(String name, String id) {
    selectedFilter.value = name;
    selectedFilterId.value = id;
    getOrders();
  }

  void applySearch(String query) {
    lastSearchQuery.value = query;
    getOrders();
  }

  Future<void> getOrderDetails(String id) async {
    try {
      isDetailLoading(true);
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData('Subscription_Plan/get_vendor_order_details?id=$id', token: token);

      if (response != null) {
        final model = VendorOrderDetailModel.fromJson(response);
        orderDetail.value = model.data;
      }
    } catch (e) {
      debugPrint("Error fetching order details: $e");
    } finally {
      isDetailLoading(false);
    }
  }

  Future<bool> updateOrderStatus(String id, String status) async {
    try {
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.postData2(
        'Subscription_Plan/update_vendor_order_status',
        {'id': id, 'status': status},
        token: token,
      );

      if (response != null && response['status'] == true) {
        Get.snackbar("Éxito", "Estado actualizado", backgroundColor: Colors.green, colorText: Colors.white);
        getOrders();
        if (orderDetail.value?.id == id) {
          getOrderDetails(id);
        }
        return true;
      } else {
        Get.snackbar("Error", response?['message'] ?? "Error al actualizar estado", backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      debugPrint("Error updating order status: $e");
      return false;
    }
  }
}
