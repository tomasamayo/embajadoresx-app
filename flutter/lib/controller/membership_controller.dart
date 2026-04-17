import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';
import '../model/membership_model.dart';

class MembershipController extends GetxController {
  MembershipController({required this.preferences});
  SharedPreferences preferences;

  final _isLoadingPlans = false.obs;
  final _isLoadingHistory = false.obs;
  final _plans = Rxn<MembershipPlansModel>();
  final _history = Rxn<MembershipHistoryModel>();

  bool get isLoadingPlans => _isLoadingPlans.value;
  bool get isLoadingHistory => _isLoadingHistory.value;
  MembershipPlansModel? get plans => _plans.value;
  MembershipHistoryModel? get history => _history.value;

  @override
  void onInit() {
    super.onInit();
    // REQUERIMIENTO V18.3: Forzar carga inmediata tras construcción
    Future.microtask(() {
      getPlans();
      getHistory();
    });
  }

  void _setLoadingPlans(bool v) {
    _isLoadingPlans.value = v;
  }

  void _setLoadingHistory(bool v) {
    _isLoadingHistory.value = v;
  }

  void _setPlans(MembershipPlansModel m) {
    _plans.value = m;
  }

  void _setHistory(MembershipHistoryModel m) {
    _history.value = m;
  }

  Future<void> getPlans() async {
    // REQUERIMIENTO V1.2.5: Logs detallados y manejo de Error 500
    print('💎 API: Intentando cargar planes de membresía...');
    _setLoadingPlans(true);
    
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    const endpoint = 'Subscription_Plan/get_membership_plan';
    
    try {
      final value = await ApiService.instance.getData(endpoint, token: token);
      
      if (value != null && value is Map<String, dynamic>) {
        print('✅ API SUCCESS: Planes recibidos correctamente.');
        _setPlans(MembershipPlansModel.fromJson(value));
      } else {
        print('⚠️ API WARNING: La respuesta no es un mapa válido o está vacía.');
        _setPlans(MembershipPlansModel(status: false, message: 'Respuesta inválida del servidor', data: []));
      }
    } catch (error) {
      // Captura detallada del error (Error 500 u otros)
      print('❌ API CRITICAL ERROR: Fallo total en la petición de planes.');
      print('📝 Detalle técnico: $error');
      
      // Si el error contiene información de respuesta (DioError/etc), intentamos extraer el status
      String errorMessage = 'Error de conexión con el servidor';
      if (error.toString().contains('500')) {
        errorMessage = 'Error Interno del Servidor (500). El backend está siendo reparado.';
      }
      
      _setPlans(MembershipPlansModel(status: false, message: errorMessage, data: []));
    } finally {
      _setLoadingPlans(false);
      print('🏁 API: Proceso de carga de planes finalizado.');
    }
  }

  Future<void> getHistory() async {
    // REQUERIMIENTO V18.3: Logs de auditoría de red
    print('📡 API: Iniciando petición de Historial de Compras...');
    _setLoadingHistory(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    const endpoint = 'user/all_transaction?per_page=20&page_id=1';
    try {
      final value = await ApiService.instance.getData(endpoint, token: token);
      if (value != null && value is Map<String, dynamic>) {
        final rawData = value['data'];
        final list = rawData is List ? rawData : <dynamic>[];
        
        print('✅ API: Historial recibido con ${list.length} elementos.');
        final items = <MembershipHistoryItem>[];

        for (final e in list) {
          if (e is! Map<String, dynamic>) continue;
          final module = e['module']?.toString() ?? '';
          final lower = module.toLowerCase();
          if (!(lower.contains('membership') || lower.contains('subscription') || lower.contains('plan'))) {
            continue;
          }

          final rawDetail = e['payment_detail']?.toString() ?? '';
          final hasDetail = rawDetail.isNotEmpty && rawDetail != '[]';
          
          // REQUERIMIENTO V18.1/18.2: Limpiar visualización de ID de transacción
          String planName = 'Plan de membresía';
          String transactionDisplayId = '';
          
          if (hasDetail) {
            if (rawDetail.contains('{') && rawDetail.contains('}')) {
              try {
                // Si es un JSON crudo, intentamos extraer solo el transaction_id o similar
                final Map<String, dynamic> detailJson = Map<String, dynamic>.from(e['payment_detail'] is Map ? e['payment_detail'] : {});
                
                if (detailJson.containsKey('transaction_id')) {
                  transactionDisplayId = detailJson['transaction_id'].toString();
                }
                
                if (detailJson.containsKey('plan_name')) {
                  planName = detailJson['plan_name'].toString();
                } else {
                  planName = 'Plan de membresía';
                }
              } catch (_) {
                planName = 'Plan de membresía';
              }
            } else {
              planName = rawDetail;
            }
          }

          // REQUERIMIENTO V18.2: Fallback TRX si no hay ID
          if (transactionDisplayId.isEmpty) {
            transactionDisplayId = "TRX-${e['id'] ?? '000000'}";
          }

          final rawPrice = e['price']?.toString() ?? '';
          final price = (rawPrice == '0' || rawPrice == '0.00') ? 'Gratis' : rawPrice;

          final statusId = e['status_id']?.toString() ?? '';
          final statusText = _mapStatus(statusId);

          final paymentMethod = e['payment_gateway']?.toString() ?? '';
          final dateTime = e['datetime']?.toString() ?? '';

          items.add(
            MembershipHistoryItem(
              id: transactionDisplayId, // Usamos el ID de transacción mapeado o TRX-
              planName: planName,
              price: price,
              planType: '',
              statusText: statusText,
              paymentMethod: paymentMethod,
              startedAt: dateTime,
              endedAt: '',
              createdAt: dateTime,
            ),
          );
        }

        _setHistory(MembershipHistoryModel(status: true, message: 'ok', data: items));
      } else {
        _setHistory(MembershipHistoryModel(status: false, message: 'No data', data: []));
      }
    } catch (error) {
      print('❌ API ERROR: Fallo al cargar historial: $error');
      _setHistory(MembershipHistoryModel(status: false, message: 'Error', data: []));
    }
    _setLoadingHistory(false);
  }

  String _mapStatus(String statusId) {
    switch (statusId) {
      case '0':
        return 'Pendiente';
      case '1':
        return 'Completado';
      case '2':
        return 'Procesando';
      case '3':
        return 'Cancelado';
      case '4':
        return 'Rechazado';
      default:
        return statusId;
    }
  }
}
