import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExCoinController extends GetxController {
  final SharedPreferences preferences;
  ExCoinController({required this.preferences});

  var isLoading = false.obs;
  var excoinBalance = 0.0.obs;
  var availableEarnings = 0.0.obs;
  var paymentGateways = <Map<String, dynamic>>[].obs;
  var selectedGateway = "".obs;
  var buyAmount = TextEditingController();
  var redeemAmount = TextEditingController();
  
  var usdToPay = "0.00".obs;
  var excoinToReceive = 0.obs;

  // TAREA 1: TEXTOS DINÁMICOS (RxString)
  var infoText = "".obs;
  var warningText = "".obs;
  var exchangeRate = "".obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 [EXCOIN] Inicializando ExCoinController...');
    fetchExCoinData();
    
    buyAmount.addListener(() {
      if (buyAmount.text.isNotEmpty) {
        double amount = double.tryParse(buyAmount.text) ?? 0;
        usdToPay.value = (amount / 100).toStringAsFixed(2);
        print('⌨️ [EXCOIN] Cambio en cantidad compra: ${buyAmount.text} ExCoin -> \$${usdToPay.value} USD');
      } else {
        usdToPay.value = "0.00";
      }
    });

    redeemAmount.addListener(() {
      if (redeemAmount.text.isNotEmpty) {
        double amount = double.tryParse(redeemAmount.text) ?? 0;
        excoinToReceive.value = (amount * 100).toInt();
        print('⌨️ [EXCOIN] Cambio en monto canje: \$${redeemAmount.text} USD -> ${excoinToReceive.value} ExCoin');
      } else {
        excoinToReceive.value = 0;
      }
    });
  }

  /// REQUERIMIENTO v2.0.2: Recuperación robusta del ID del usuario (Mismo método que Loglist/Dashboard)
  dynamic _getUserId() {
    dynamic userId;
    
    // Fuente 1: DashboardController (Dato en memoria caliente)
    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      userId = dash.loginModel?.data?.userId;
    }

    // Fuente 2: SharedPreferences (Persistencia)
    if (userId == null) {
      final String? userIdRaw = preferences.getString('user_id') ?? preferences.getString('id');
      userId = int.tryParse(userIdRaw ?? "");
    }

    return userId;
  }

  Future<void> fetchExCoinData() async {
    print('📡 [EXCOIN] Solicitando datos de balance y pasarelas...');
    isLoading.value = true;
    try {
      final userIdDinamico = _getUserId();
      
      if (userIdDinamico == null) {
        print('❌ [EXCOIN] Error Crítico: User ID no encontrado en Dashboard ni SharedPreferences.');
        return;
      }

      // TAREA 1 (v3.1.0): Log de conexión con ID Real
      print('🔑 [SISTEMA] Conectando con ID Real: $userIdDinamico');

      // TAREA 1: REVISIÓN DE RUTA Y PARSEO (HTTP RAW)
      final String url = 'https://embajadoresx.com/api/get_coinx_data?user_id=$userIdDinamico';
      print('🔗 [EXCOIN URL]: $url');

      final response = await http.get(Uri.parse(url));
      print('📊 [EXCOIN STATUS CODE]: ${response.statusCode}');

      // TAREA 1: DEBUG EXTREMO DEL JSON RAW
      print('📦 [EXCOIN RAW JSON]: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // TAREA 1: FIX CRÍTICO DE PARSEO (MODO DIOS v2.0.7)
        // Parseo a prueba de fallos convirtiendo a String primero y revisando ambas rutas
        excoinBalance.value = double.tryParse(responseData['data']?['coinx_balance']?.toString() ?? "") ?? 
                            double.tryParse(responseData['coinx_balance']?.toString() ?? "") ?? 0.0;
        
        availableEarnings.value = double.tryParse(responseData['data']?['available_earnings']?.toString() ?? "") ?? 
                                 double.tryParse(responseData['available_earnings']?.toString() ?? "") ?? 0.0;
        
        infoText.value = responseData['data']?['info_text']?.toString() ?? 
                        responseData['info_text']?.toString() ?? 'Moneda virtual para canjear por productos de forma rápida y segura.';
        
        warningText.value = responseData['data']?['warning_text']?.toString() ?? 
                           responseData['warning_text']?.toString() ?? 'Esta acción descontará el dinero de tu saldo de ganancias y lo convertirá en monedas virtuales.';
        
        exchangeRate.value = responseData['data']?['exchange_rate']?.toString() ?? 
                            responseData['exchange_rate']?.toString() ?? '1 USD = 100 ExCoin';

        // Pasarelas
        final data = responseData['data'] ?? {};
        paymentGateways.value = List<Map<String, dynamic>>.from(data['payment_gateways'] ?? responseData['payment_gateways'] ?? []);

        // TAREA 3: LOG DE COMPROBACIÓN
        print('✅ [EXCOIN FIX] Balance final asignado: ${excoinBalance.value}');
        print('   - Ganancias: ${availableEarnings.value}');
        
        if (paymentGateways.isNotEmpty) {
          selectedGateway.value = paymentGateways[0]['id'].toString();
          print('   - Pasarela seleccionada por defecto: ${paymentGateways[0]['title']}');
        }
      } else {
        print('⚠️ [EXCOIN] La respuesta de la API no es 200 OK: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [EXCOIN] Error crítico al obtener datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onGatewaySelected(String id, String title) {
    selectedGateway.value = id;
    print('💳 [EXCOIN] Pasarela seleccionada: $title (ID: $id)');
  }

  void onTabChanged(int index) {
    print('🔄 [EXCOIN] Cambio de pestaña: ${index == 0 ? "COMPRAR" : "CANJEAR"}');
  }

  Future<dynamic> confirmBuyExCoin() async {
    print('🔘 [EXCOIN] Botón "Confirmar Compra" presionado.');
    
    final userIdDinamico = _getUserId();

    if (buyAmount.text.isEmpty || selectedGateway.value.isEmpty || userIdDinamico == null) {
      print('⚠️ [EXCOIN] Validación fallida: Campos incompletos o ID nulo');
      Get.snackbar("Error", "Ingresa una cantidad y selecciona una pasarela", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return null;
    }

    print('📡 [EXCOIN] Llamando a confirm_buy_coinx con ID: $userIdDinamico');
    isLoading.value = true;
    try {
      final response = await ApiService.instance.postData('CoinX/confirm_buy_coinx', {
        'user_id': userIdDinamico.toString(),
        'amount': buyAmount.text,
        'gateway_id': selectedGateway.value,
      });

      if (response != null && response['status'] == true) {
        print('✅ [EXCOIN] Respuesta exitosa. HTML recibido para WebView.');
      } else {
        print('❌ [EXCOIN] Error en respuesta del servidor: ${response?['message']}');
      }

      return response;
    } catch (e) {
      print('❌ [EXCOIN] Error excepcional en compra: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void onWebViewClosed(String status) {
    print('🌐 [EXCOIN] WebView cerrado. Status detectado: $status');
    if (status == "success") {
      print('🎉 [EXCOIN] ¡Transacción confirmada con éxito!');
    } else {
      print('🚫 [EXCOIN] Transacción cancelada o fallida.');
    }
  }

  Future<void> redeemEarningsForExCoin() async {
    print('🔘 [EXCOIN] Botón "Canjear por ExCoin" presionado.');
    
    // TAREA 1 (v6.0.0): ID de usuario dinámico desde DashboardController
    final String currentUserIdStr = Get.find<DashboardController>().userId.value;

    if (redeemAmount.text.isEmpty || currentUserIdStr.isEmpty) {
      Get.snackbar("Error", "Ingresa un monto para canjear", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      // TAREA 1 (v6.0.0): Regreso al protocolo JSON Estricto
      final String url = 'https://embajadoresx.com/api/redeem_earnings_for_coinx';
      
      final int userId = int.parse(currentUserIdStr);
      final double amount = double.parse(redeemAmount.text);

      // 🛑 REGLA DE ORO (v6.0.0): Log de confirmación JSON
      print('📡 [CANJE] Enviando JSON Final: {"user_id": $userId, "amount": $amount}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "user_id": userId,
          "amount": amount
        }),
      );

      print('📊 [CANJE STATUS]: ${response.statusCode}');
      print('📦 [RESPUESTA SERVIDOR]: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['status'] == true) {
          // TAREA 2 (v6.0.0): SnackBar verde de éxito
          Get.snackbar(
            "¡Canje exitoso!", 
            responseData['message'] ?? "Tus ExCoin han sido acreditados.", 
            backgroundColor: const Color(0xFF00FF88), 
            colorText: Colors.black
          );
          
          // CRÍTICO: Limpiar campo y recargar balances real-time
          redeemAmount.clear();
          
          print('🔄 [EXCOIN] Disparando fetchExCoinData() para sincronización real-time...');
          await fetchExCoinData(); 
          print('✅ [CANJE] Actualización de balances completada.');
        } else {
          Get.snackbar("Error", responseData['message'] ?? "No se pudo realizar el canje", 
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "Error de servidor (${response.statusCode})", 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('❌ [COINX] Error excepcional en canje: $e');
      Get.snackbar("Error", "Ocurrió un error inesperado al procesar el canje", 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
