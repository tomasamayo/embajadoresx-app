import 'package:affiliatepro_mobile/controller/coinx/coinx_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:affiliatepro_mobile/model/dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/model/user_model.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:affiliatepro_mobile/utils/session_manager.dart';
import 'package:affiliatepro_mobile/service/notification_service.dart';

class DashboardController extends GetxController {
  DashboardController({required this.preferences});
  SharedPreferences preferences;

  bool _isLoading = false;
  bool _isDashboardDataLoading = false;
  UserModel? _loginModel;
  DashboardModel? _dashboardModel;

  // For AI suggestion tracking
  int _currentSuggestionIndex = -1;
  List<String> _cachedSuggestions = [];

  final RxString planName = "".obs;
  final RxString planStatus = "INACTIVO".obs;
  final RxString daysLeftStr = "0 días".obs;
  final RxBool hasActivePlan = false.obs;
  final RxBool isVendorMode = false.obs; // REQUERIMIENTO V1.2.2: Toggle de Modo Proveedor
  final RxString currentRank = "Nivel Inicial".obs; // REQUERIMIENTO V1.2.3: Rango observable
  final RxDouble excoinBalance = 0.0.obs; // REQUERIMIENTO v2.0.7: Balance de ExCoin en Dashboard
  final RxString userId = "".obs; // REQUERIMIENTO v5.3.0: ID de usuario observable para canje dinámico
  
  // REQUERIMIENTO V1.5.0: Gestión de Verificación Premium (Check Azul)
  final RxInt isVerified = 0.obs;
  final RxMap verificationRequestData = {}.obs;
  final RxBool isVerificationLoading = false.obs;

  bool get isLoading => _isLoading;
  bool get isDashboardDataLoading => _isDashboardDataLoading;
  UserModel? get loginModel => _loginModel;
  DashboardModel? get dashboardData => _dashboardModel;

  // Getters for suggestion count display
  int get currentSuggestionIndex => _currentSuggestionIndex >= 0 ? _currentSuggestionIndex : 0;
  int get totalSuggestionCount => _cachedSuggestions.isEmpty ? 0 : _cachedSuggestions.length;

  @override
  void onInit() {
    super.onInit();
    _loadSavedSuggestionIndex();
    // REQUERIMIENTO V14.1: Forzar carga de datos al inicializar
    print('🚀 DISPARANDO DASHBOARD REAL - BUSCANDO PLAN ULTRA...');
    getUser();
    getDashboardData();

    // TAREA 2 (v3.0.0): Inyección segura de ExCoinController
    if (!Get.isRegistered<ExCoinController>()) {
      Get.lazyPut(() => ExCoinController(preferences: preferences));
    }
  }

  @override
  void onReady() {
    super.onReady();
    // TAREA 1 & 2 (v3.0.0): Sincronización Maestra al estar listos
    refreshAllBalances();
  }

  // TAREA 3 (v3.1.0): Reestructurar refreshAllBalances() con orden de ejecución asegurado
  Future<void> refreshAllBalances() async {
    print('🔄 [DASHBOARD] Iniciando Sincronización Maestra (v3.1.0)...');
    
    // 1. Asegurar que el ID esté cargado antes de disparar peticiones
    await getUser(); 
    
    // 2. Disparar fetch de ExCoin usando el ID real obtenido
    if (Get.isRegistered<ExCoinController>()) {
      final exCoin = Get.find<ExCoinController>();
      print('💰 [DASHBOARD] Disparando fetch de ExCoin...');
      await exCoin.fetchExCoinData();
      print('✅ [DASHBOARD] Sincronización con ExCoin completa.');
    }
    
    // 3. Actualizar datos tradicionales (para gráficos y resto de UI)
    await getDashboardData();
    
    update();
  }

  // Load the saved suggestion index from preferences
  Future<void> _loadSavedSuggestionIndex() async {
    _currentSuggestionIndex = preferences.getInt('current_suggestion_index') ?? -1;
  }

  // Save the current suggestion index to preferences
  Future<void> _saveSuggestionIndex() async {
    await preferences.setInt('current_suggestion_index', _currentSuggestionIndex);
  }

  changeIsLoading(bool data) {
    _isLoading = data;
    // v71.0.0: Blindaje de ciclo de vida - No disparar update() si ya estamos en build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  changeDashboardLoading(bool data) {
    _isDashboardDataLoading = data;
    // v71.0.0: Blindaje de ciclo de vida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  // REQUERIMIENTO V1.2.2: Método para alternar entre Afiliado y Proveedor
  Future<void> toggleVendorMode() async {
    changeIsLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;

    // Si isVendorMode es true (estamos en modo proveedor), queremos volver a ser afiliado
    // Si isVendorMode es false (estamos en modo afiliado), queremos ser proveedor
    String endPoint = isVendorMode.value ? 'user/become_affiliate' : 'user/become_vendor';

    try {
      final response = await ApiService.instance.postData2(endPoint, {}, token: token);
      
      if (response != null && response['status'] == true) {
        // REQUERIMIENTO V1.2.2: Actualizar estado reactivo inmediatamente
        isVendorMode.value = !isVendorMode.value;
        
        // Mostrar Snackbar Premium (Verde Neón)
        Get.snackbar(
          "Éxito",
          response['message'] ?? "Cambio de rol exitoso",
          backgroundColor: const Color(0xFF00FF88),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_outline, color: Colors.black),
        );
        
        // Actualizar datos del usuario para reflejar el cambio en el backend
        await getUser();
        // Forzar notificación a todos los listeners
        update();
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "No se pudo cambiar el rol",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("Error toggling vendor mode: $e");
    } finally {
      changeIsLoading(false);
    }
  }

  updateUserData(UserModel? model) {
    _loginModel = model;
    // REQUERIMIENTO V1.2.2: Sincronizar estado inicial del Modo Proveedor
    isVendorMode.value = model?.data?.isVendor == "1";

    // El ID se actualiza si el modelo trae uno válido.
    final String newId = model?.data?.userId?.toString() ?? "";
    if (newId.isNotEmpty && newId != "0") {
      userId.value = newId;
      debugPrint('[DashboardController] userId actualizado: $newId');
    }
    
    // Sincronizar verificación
    if (model?.data?.isVerified != null) {
      if (model!.data!.isVerified == 1) {
        isVerified.value = 1;
      }
    }
    if (model?.data?.verificationRequest != null) {
      final req = model!.data!.verificationRequest!;
      verificationRequestData.value = {
        'exists': req.exists,
        'status': req.status,
        'admin_comment': req.adminComment,
      };
    }
    update();
  }

  // REQUERIMIENTO V1.2.3: Sanitizador de strings para eliminar HTML/datos corruptos
  String _sanitizeHtml(String html) {
    if (html.isEmpty) return "";
    return html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
  }

  updateDashboardData(DashboardModel? model) {
    _dashboardModel = model;
    _cachedSuggestions = [];
    update();
  }

  Future<void> fetchVerificationStatus() async {
    print("🛡️ [VERIFICACIÓN] Consultando estado de Check Azul...");
    isVerificationLoading.value = true;
    
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    
    try {
      final response = await ApiService.instance.getData('api/get_user_details', token: token);
      
      if (response != null && response['status'] == true) {
        final data = response['data'];
        isVerified.value = int.tryParse(data['is_verified']?.toString() ?? '0') ?? 0;
        
        final request = data['verification_request'] ?? {};
        verificationRequestData.value = Map<String, dynamic>.from(request);

        print("✅ [VERIFICACIÓN] Estado sincronizado: ${isVerified.value}");
      }
    } catch (e) {
      print("🔥 [VERIFICACIÓN ERROR] No se pudo obtener el estado: $e");
    } finally {
      isVerificationLoading.value = false;
      update();
    }
  }

  Future<void> getUser() async {
    changeIsLoading(true);
    try {
      final userModel = await SharedPreference.getUserData();
      final token = userModel?.data?.token;
      
      await fetchVerificationStatus();

      final response = await ApiService.instance.getData('User/get_my_profile_details', token: token);
      
      if (response != null && response is Map<String, dynamic>) {
        // PASO 2 — Persistir el ID inmediatamente al recibirlo del Flujo B
        final Map<String, dynamic> dataPart = response['data'] is Map ? response['data'] : response;
        final int? extractedId = SessionManager.extractUserId(dataPart);
        
        if (extractedId != null && extractedId > 0) {
          final String idStr = extractedId.toString();
          await SessionManager.instance.setUserId(idStr);
          userId.value = idStr;
          print('✅ [SESSION] userId=$extractedId guardado en disco y RAM');
          
          // PASO 3 — Registrar el token FCM DESPUÉS del userId
          await NotificationService().registerFCMTokenIfReady();
        }

        final model = UserModel.fromJson(response);
        updateUserData(model);
        
        if (model.data?.planName != null && model.data!.planName!.isNotEmpty && model.data!.planName != "N/A") {
          planName.value = model.data!.planName!.split(' (')[0].trim();
          planStatus.value = "ACTIVO";
          hasActivePlan.value = true;
        }
      }
    } catch (e) {
      debugPrint("Error in getUser: $e");
    } finally {
      changeIsLoading(false);
    }
  }

  getDashboardData() async {
    changeDashboardLoading(true);
    // REQUERIMIENTO V14.1: Limpiar datos previos para evitar mostrar "Proveedor" o estáticos
    if (_dashboardModel != null) {
      _dashboardModel!.data.userPlan.planName = "";
    }
    
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    String endPoint = 'User/dashboard';
    String params =
        '?includes=totals_count,chart_data,notifications,recent_activities,weekly_chart_data,plan_details';
    await ApiService.instance
        .getData(endPoint + params, token: token)
        .then((value) {
      if (value != null && value is Map<String, dynamic>) {
        // --- SANITIZACIÓN DE DATOS (Hotfix V1.2.3) ---
        if (value['data'] != null && value['data'] is Map<String, dynamic>) {
          var dataMap = value['data'] as Map<String, dynamic>;
          
          // Sanitizar Notificaciones/Actividades
          if (dataMap.containsKey('notifications') && dataMap['notifications'] is List) {
            var notifications = dataMap['notifications'] as List;
            for (var i = 0; i < notifications.length; i++) {
              if (notifications[i] is Map) {
                var n = notifications[i] as Map<String, dynamic>;
                if (n.containsKey('description')) {
                  n['description'] = _sanitizeHtml(n['description'].toString());
                }
              }
            }
          }
        }

        final model = DashboardModel.fromJson(value);
        
        // REQUERIMIENTO V1.2.2: Mapeo estricto del objeto user_plan nativo del Dashboard
        final data = value['data'];
        if (data != null && data is Map<String, dynamic> && data.containsKey('user_plan') && data['user_plan'] != null) {
          var userPlan = data['user_plan'];
          // Leemos is_active que viene como String o Int ("1" o 1)
          if (userPlan['is_active'].toString() == "1") {
            planStatus.value = "ACTIVO";
            hasActivePlan.value = true;
            // Leemos plan_name directo (el backend ya lo manda limpio)
            planName.value = userPlan['plan_name'].toString().split(' (')[0].trim();
          } else {
            planStatus.value = "INACTIVO";
            hasActivePlan.value = false;
            planName.value = "Sin Plan Activo";
          }
          
          // Sincronizar con el modelo por si acaso
          model.data.userPlan.planName = planName.value;
          model.data.userPlan.isActive = hasActivePlan.value ? "1" : "0";
        }

        // REQUERIMIENTO v2.0.7: Extraer saldo de ExCoin del Dashboard (si existe)
        if (data != null && data is Map<String, dynamic> && data.containsKey('excoin_balance')) {
          excoinBalance.value = double.tryParse(data['excoin_balance'].toString()) ?? 0.0;
          print('✅ [DASHBOARD] ExCoin Balance actualizado: ${excoinBalance.value}');
        }

        updateDashboardData(model);
        
        // REQUERIMIENTO V1.2.3: Actualizar Rango observable
        if (data != null && data is Map<String, dynamic> && data.containsKey('user_plan') && data['user_plan'] != null) {
          var userPlan = data['user_plan'];
          if (userPlan['current_rank_name'] != null && userPlan['current_rank_name'].toString().isNotEmpty) {
            currentRank.value = userPlan['current_rank_name'].toString();
          } else {
            currentRank.value = "Nivel Inicial";
          }
        }
        
        // REQUERIMIENTO V15.0: Forzar reactividad del Plan
        // Recalcular días restantes para reactividad
        if (model.data.userPlan.isLifetime == "1") {
          daysLeftStr.value = "Ilimitado";
        } else {
          final now = DateTime.now();
          final date1 = DateTime(now.year, now.month, now.day);
          final date2 = DateTime(model.data.userPlan.expireAt.year, model.data.userPlan.expireAt.month, model.data.userPlan.expireAt.day);
          final diff = date2.difference(date1).inDays;
          daysLeftStr.value = "${diff > 0 ? diff : 0} días";
        }
        
        update();
      }
    });
    changeDashboardLoading(false);
  }

  // Refresh AI suggestion - pick a different one
  void refreshAISuggestion() {
    // Generate suggestions if not already done
    if (_cachedSuggestions.isEmpty) {
      _cachedSuggestions = _generateAdvancedAIInsights();
    }

    // Pick a different suggestion if possible
    if (_cachedSuggestions.length > 1) {
      int newIndex;
      do {
        newIndex = DateTime.now().millisecond % _cachedSuggestions.length;
      } while (newIndex == _currentSuggestionIndex && _cachedSuggestions.length > 1);

      _currentSuggestionIndex = newIndex;
    } else {
      // If only one suggestion, keep the same
      _currentSuggestionIndex = 0;
    }

    // Save the current suggestion index
    _saveSuggestionIndex();

    // Update UI
    update();
  }

  String getAISuggestion() {
    // If no cached suggestions, generate them
    if (_cachedSuggestions.isEmpty) {
      _cachedSuggestions = _generateAdvancedAIInsights();

      // If we have a saved index and it's valid, use it
      if (_currentSuggestionIndex >= 0 && _currentSuggestionIndex < _cachedSuggestions.length) {
        // Use the saved index
      } else {
        // Otherwise generate a new index
        _currentSuggestionIndex = DateTime.now().millisecond % _cachedSuggestions.length;
        _saveSuggestionIndex();
      }
    }

    return _cachedSuggestions[_currentSuggestionIndex];
  }

  // Generate advanced AI insights based on all available data
  List<String> _generateAdvancedAIInsights() {
    final List<String> insights = [];

    // Safety check for null data
    if (dashboardData == null) {
      return ["Por favor espera mientras analizo tus datos..."];
    }

    final data = dashboardData!.data;
    final totals = data.userTotals;
    final marketTools = data.marketTools;
    final referTotal = data.referTotal;

    // Extract key metrics from UserTotals
    // Currency and balance information
    final userBalance = totals.userBalance;
    final currencyMatch = RegExp(r'^\D+').firstMatch(userBalance);
    final currency = currencyMatch != null ? currencyMatch.group(0)! : "";
    final balanceAmount = double.tryParse(userBalance.replaceAll(RegExp(r'[^\d.]'), "")) ?? 0;

    // Earnings data
    final weekEarnings = data.userTotalsWeek;
    final monthEarnings = data.userTotalsMonth;
    final yearEarnings = data.userTotalsYear;
    final weekAmount = double.tryParse(weekEarnings.replaceAll(RegExp(r'[^\d.]'), "")) ?? 0;
    final monthAmount = double.tryParse(monthEarnings.replaceAll(RegExp(r'[^\d.]'), "")) ?? 0;
    final yearAmount = double.tryParse(yearEarnings.replaceAll(RegExp(r'[^\d.]'), "")) ?? 0;

    // Wallet and commission data
    final walletUnpaidAmount = totals.walletUnpaidAmount is num ? totals.walletUnpaidAmount : 0.0;
    final walletUnpaidCount = totals.walletUnpaidCount is num ? totals.walletUnpaidCount : 0;

    // Click and sale data
    final totalClicksCount = totals.totalClicksCount is num ? totals.totalClicksCount : 0;
    final totalClicksCommission = totals.totalClicksCommission is num ? totals.totalClicksCommission : 0.0;
    final saleLocalstoreCount = totals.saleLocalstoreCount is num ? totals.saleLocalstoreCount : 0;
    final saleLocalstoreTotal = totals.saleLocalstoreTotal is num ? totals.saleLocalstoreTotal : 0.0;
    final saleLocalstoreCommission = totals.saleLocalstoreCommission is num ? totals.saleLocalstoreCommission : 0.0;

    // External and local store data
    final clickLocalstoreTotal = totals.clickLocalstoreTotal;
    final clickExternalTotal = totals.clickExternalTotal is num ? totals.clickExternalTotal : 0;
    final orderExternalCount = int.tryParse(totals.orderExternalCount) ?? 0;

    // Action and form data
    final clickActionTotal = totals.clickActionTotal is num ? totals.clickActionTotal : 0;
    final clickFormTotal = totals.clickFormTotal is num ? totals.clickFormTotal : 0;

    // Vendor data
    final vendorClickLocalstoreTotal = totals.vendorClickLocalstoreTotal is num ? totals.vendorClickLocalstoreTotal : 0;
    final vendorSaleLocalstoreCount = totals.vendorSaleLocalstoreCount is num ? totals.vendorSaleLocalstoreCount : 0;

    // Refer data
    final referStatus = data.referStatus;
    final uniqueResellerLink = data.uniqueResellerLink;
    final totalProductClicks = int.tryParse(referTotal.totalProductClick.clicks) ?? 0;
    final totalGeneralClicks = int.tryParse(referTotal.totalGaneralClick.totalClicks) ?? 0;
    final totalActionClicks = int.tryParse(referTotal.totalAction.clickCount) ?? 0;
    final totalProductSalesCounts = int.tryParse(referTotal.totalProductSale.counts) ?? 0;

    // Membership data
    final isMembershipAccess = data.isMembershipAccess;
    final userPlan = data.userPlan;
    
    // REQUERIMIENTO V15.1: Cálculo de días considerando solo la fecha para precisión (2026-04-15 vs 2026-03-19 = 27)
    final now = DateTime.now();
    final date1 = DateTime(now.year, now.month, now.day);
    final date2 = DateTime(userPlan.expireAt.year, userPlan.expireAt.month, userPlan.expireAt.day);
    final daysLeft = date2.difference(date1).inDays;
    
    final isLifetime = userPlan.isLifetime == "1";

    // Store URL
    final storeUrl = data.affiliateStoreUrl;

    // === ADVANCED AI INSIGHTS ===

    // 1. WALLET AND EARNINGS INSIGHTS
    if (walletUnpaidAmount > 0 && walletUnpaidCount > 0) {
      if (balanceAmount > 0) {
        final totalAvailable = balanceAmount + walletUnpaidAmount;
        insights.add("He analizado tu cuenta: tienes $currency$balanceAmount disponibles más $currency$walletUnpaidAmount en comisiones pendientes de $walletUnpaidCount transacciones sin pagar. Tu potencial total es $currency$totalAvailable. Considera retirar algunos fondos mientras continúas aumentando tus ganancias.");
      } else {
        insights.add("Tienes $walletUnpaidCount comisiones sin pagar esperándote, por un total de $currency$walletUnpaidAmount. Solicitar un retiro convertiría estas comisiones pendientes en fondos disponibles.");
      }
    }

    // 2. PERFORMANCE TREND INSIGHT
    if (weekAmount > 0 && monthAmount > 0 && yearAmount > 0) {
      final weekPercentageOfMonth = (weekAmount / monthAmount * 100).toStringAsFixed(1);
      final monthPercentageOfYear = (monthAmount / yearAmount * 100).toStringAsFixed(1);

      if (double.parse(weekPercentageOfMonth) > 25) {
        insights.add("¡Estás superando tu promedio! Las ganancias de esta semana ($currency$weekAmount) representan el $weekPercentageOfMonth% de tu total mensual ($currency$monthAmount), lo cual está por encima de la tasa semanal esperada del 25%. Mantén este impulso para aumentar significativamente tus ganancias mensuales.");
      } else {
        insights.add("Las ganancias de esta semana ($currency$weekAmount) representan el $weekPercentageOfMonth% de tus ganancias mensuales ($currency$monthAmount), lo cual está ${double.parse(weekPercentageOfMonth) < 25 ? "por debajo" : "en"} el ritmo semanal esperado. Tu mes está actualmente en el $monthPercentageOfYear% de tus ganancias anuales.");
      }
    }

    // 3. MARKET TOOLS PERFORMANCE INSIGHT
    if (marketTools.isNotEmpty) {
      // Find best performing tool by click count
      final bestClickTool = marketTools.reduce((a, b) => a.clickCount > b.clickCount ? a : b);
      // Find best performing tool by sale count
      final bestSaleTool = marketTools.reduce((a, b) => a.saleCount > b.saleCount ? a : b);

      if (bestClickTool.clickCount > 0) {
        insights.add("Tu herramienta con mejor rendimiento por tráfico es \"${bestClickTool.title}\" con ${bestClickTool.clickCount} clics. ${bestClickTool.saleCount > 0 ? "Ha generado ${bestClickTool.saleCount} ventas hasta ahora." : "Considera optimizar tu embudo para convertir más de este tráfico en ventas."}");
      }

      if (bestSaleTool.saleCount > 0 && bestSaleTool.title != bestClickTool.title) {
        insights.add("\"${bestSaleTool.title}\" es tu mejor conversor con ${bestSaleTool.saleCount} ventas. Su tasa de conversión del ${(bestSaleTool.saleCount / (bestSaleTool.clickCount > 0 ? bestSaleTool.clickCount : 1) * 100).toStringAsFixed(1)}% es impresionante. Considera dirigir más tráfico a esta herramienta de alto rendimiento.");
      }

      // Find tools with zero clicks but good commission potential
      final unusedTools = marketTools.where((tool) =>
      tool.clickCount == 0 &&
          (double.tryParse(tool.saleCommisionYouWillGet.replaceAll(RegExp(r'[^\d.]'), "")) ?? 0) > 0
      ).toList();

      if (unusedTools.isNotEmpty && unusedTools.length <= 3) {
        final toolNames = unusedTools.map((t) => "\"${t.title}\"").join(", ");
        insights.add("He identificado un potencial sin explotar: $toolNames ${unusedTools.length == 1 ? "no está" : "no están"} generando tráfico aún, pero ofrece${unusedTools.length == 1 ? "" : "n"} buenas tasas de comisión. Intenta promocionar ${unusedTools.length == 1 ? "esta herramienta" : "estas herramientas"} para diversificar tus fuentes de ingresos.");
      }
    }

    // 4. CONVERSION RATE ANALYSIS
    if (totalClicksCount > 0) {
      if (saleLocalstoreCount > 0) {
        final conversionRate = (saleLocalstoreCount / totalClicksCount * 100).toStringAsFixed(2);
        insights.add("Tu tasa de conversión general es del $conversionRate% ($saleLocalstoreCount ventas de $totalClicksCount clics). ${double.parse(conversionRate) > 2 ? "Esto está por encima del promedio de la industria del 1-2%, lo que indica una segmentación efectiva o contenido persuasivo." : "El promedio de la industria es del 1-2%, por lo que optimizar tus páginas de destino y contenido promocional podría aumentar las conversiones."}");
      } else if (totalClicksCount >= 20) {
        insights.add("Has generado $totalClicksCount clics pero aún no has convertido ninguna venta. Con este volumen de tráfico, enfócate en optimizar tu embudo: verifica que las páginas de destino sean atractivas y que los productos coincidan con los intereses de tu audiencia.");
      } else {
        insights.add("Has comenzado a generar clics ($totalClicksCount hasta ahora) pero necesitas más tráfico antes de enfocarte en la optimización de la conversión. Continúa construyendo tu audiencia para alcanzar al menos 100 clics para obtener datos de conversión significativos.");
      }
    }

    // 5. COMMISSION EFFICIENCY ANALYSIS
    if (totalClicksCount > 0 && totalClicksCommission > 0) {
      final earningsPerClick = (totalClicksCommission / totalClicksCount).toStringAsFixed(2);
      insights.add("Tu comisión promedio por clic es $currency$earningsPerClick. ${double.parse(earningsPerClick) > 0.15 ? "Esta es una relación de ganancias sólida, lo que indica que estás promocionando productos de alto valor o tienes términos de comisión favorables." : "Considera promocionar productos con tasas de comisión más altas para maximizar tu retorno sobre el tráfico."}");
    }

    // 6. TRAFFIC SOURCE ANALYSIS
    if (clickLocalstoreTotal > 0 || clickExternalTotal > 0 || clickActionTotal > 0 || clickFormTotal > 0) {
      final totalTraffic = clickLocalstoreTotal + (clickExternalTotal as num) + (clickActionTotal as num) + (clickFormTotal as num);

      if (totalTraffic > 0) {
        final localPercent = (clickLocalstoreTotal / totalTraffic * 100).toStringAsFixed(1);
        final externalPercent = (clickExternalTotal / totalTraffic * 100).toStringAsFixed(1);
        final actionPercent = (clickActionTotal / totalTraffic * 100).toStringAsFixed(1);
        final formPercent = (clickFormTotal / totalTraffic * 100).toStringAsFixed(1);

        // Find highest traffic source
        String highestSource = "tienda local";
        double highestPercent = double.parse(localPercent);

        if (double.parse(externalPercent) > highestPercent) {
          highestSource = "enlaces externos";
          highestPercent = double.parse(externalPercent);
        }
        if (double.parse(actionPercent) > highestPercent) {
          highestSource = "enlaces de acción";
          highestPercent = double.parse(actionPercent);
        }
        if (double.parse(formPercent) > highestPercent) {
          highestSource = "envíos de formularios";
          highestPercent = double.parse(formPercent);
        }

        insights.add("Tu análisis de tráfico muestra que el $highestPercent% de tus clics provienen de $highestSource. ${highestPercent > 75 ? "Considera diversificar tus fuentes de tráfico para reducir la dependencia de un solo canal." : "Tu diversificación de tráfico es saludable, pero aún podrías optimizar más tu canal de $highestSource para obtener mejores resultados."}");
      }
    }

    // 7. REFERRAL PROGRAM INSIGHT
    if (!referStatus && totalProductClicks == 0 && totalGeneralClicks == 0) {
      insights.add("Tu programa de referidos está actualmente deshabilitado. Habilitar esta función podría crear un flujo de ingresos pasivos a través de tu red. Considera activarlo en la configuración de tu cuenta para expandir tu potencial de ganancias.");
    } else if (referStatus && (totalProductClicks > 0 || totalGeneralClicks > 0)) {
      if (totalProductSalesCounts > 0) {
        insights.add("Tu programa de referidos está generando resultados con $totalGeneralClicks clics generales, $totalProductClicks clics de productos y $totalProductSalesCounts ventas. Continúa compartiendo tu enlace único de revendedor para aumentar estos números.");
      } else {
        insights.add("Tu programa de referidos ha generado tráfico ($totalGeneralClicks clics generales y $totalProductClicks clics de productos) pero aún no se ha convertido en ventas. Considera entrenar a tus referidos sobre estrategias de promoción efectivas para mejorar las conversiones.");
      }
    } else if (referStatus && uniqueResellerLink.isNotEmpty && totalProductClicks == 0 && totalGeneralClicks == 0) {
      insights.add("Tu programa de referidos está activo pero aún no ha generado tráfico. Comparte tu enlace único de revendedor con socios potenciales o en tus redes sociales para comenzar a construir tu red de referidos.");
    }

    // 8. MEMBERSHIP STATUS INSIGHT
    if (isMembershipAccess && !isLifetime && daysLeft > 0) {
      if (daysLeft <= 7) {
        insights.add("⚠️ ¡Tu membresía expira en solo $daysLeft día${daysLeft == 1 ? '' : 's'}! Para mantener el acceso a todas las herramientas y funciones de afiliados, renueva tu suscripción pronto para evitar cualquier interrupción en tus ganancias.");
      } else if (daysLeft <= 30) {
        insights.add("Tu membresía expirará en $daysLeft días. Si estás viendo resultados positivos, considera renovar para mantener tu impulso. Tu plan actual dura hasta el ${Jiffy.parseFromDateTime(userPlan.expireAt).yMMMMd}.");
      }
    } else if (!isMembershipAccess) {
      insights.add("Actualmente no tienes acceso activo a la membresía. Actualizar a un plan pago desbloquearía herramientas de afiliados adicionales, tasas de comisión más altas y más oportunidades de promoción.");
    }

    // 9. STORE INSIGHT
    if (storeUrl.isEmpty) {
      insights.add("Noto que la URL de tu tienda de afiliados no está configurada. Configurar esto crearía una tienda dedicada para tus productos, aumentando potencialmente tus tasas de conversión y brindando una experiencia más profesional a tus clientes.");
    } else if (storeUrl.isNotEmpty && saleLocalstoreCount == 0 && clickLocalstoreTotal > 20) {
      insights.add("Tu tienda de afiliados está recibiendo tráfico ($clickLocalstoreTotal clics) pero aún no ha generado ventas. Considera revisar el diseño de tu tienda, la selección de productos y los elementos de llamada a la acción para mejorar la experiencia del cliente.");
    } else if (storeUrl.isNotEmpty && saleLocalstoreCount > 0) {
      final storeConversionRate = (saleLocalstoreCount / clickLocalstoreTotal * 100).toStringAsFixed(2);
      insights.add("Tu tienda de afiliados tiene una tasa de conversión del $storeConversionRate% ($saleLocalstoreCount ventas de $clickLocalstoreTotal clics). ${double.parse(storeConversionRate) > 2.5 ? "Esto está por encima del promedio para el comercio electrónico, lo que indica un diseño de tienda efectivo." : "La tasa de conversión promedio del comercio electrónico es del 2-3%, por lo que puede haber espacio para optimizar el diseño de tu tienda o la presentación del producto."}");
    }

    // 10. VENDOR PERFORMANCE INSIGHT
    if (vendorClickLocalstoreTotal > 0 || vendorSaleLocalstoreCount > 0) {
      if (vendorSaleLocalstoreCount > 0) {
        final vendorConversionRate = (vendorSaleLocalstoreCount / (vendorClickLocalstoreTotal > 0 ? vendorClickLocalstoreTotal : 1) * 100).toStringAsFixed(2);
        insights.add("Como vendedor, tus productos han logrado una tasa de conversión del $vendorConversionRate% ($vendorSaleLocalstoreCount ventas de $vendorClickLocalstoreTotal clics). ${double.parse(vendorConversionRate) > 3 ? "Este es un rendimiento sólido, lo que sugiere que tus productos resuenan bien con los compradores." : "Considera optimizar tus listados de productos o estrategia de precios para mejorar las conversiones."}");
      } else if (vendorClickLocalstoreTotal > 0) {
        insights.add("Tus productos de vendedor están recibiendo atención ($vendorClickLocalstoreTotal clics) pero aún no se han convertido en ventas. Revisa las descripciones, precios e imágenes de tus productos para hacer que tus ofertas sean más atractivas para los compradores potenciales.");
      }
    }

    // 11. EXTERNAL ORDER INSIGHT
    if (orderExternalCount > 0) {
      insights.add("Has generado $orderExternalCount pedidos externos. Esto muestra tu capacidad para impulsar conversiones a través de plataformas externas. Continúa aprovechando estos canales mientras expandes tu alcance promocional para maximizar las ventas multiplataforma.");
    }

    // If we somehow still have very few insights (unlikely with this comprehensive analysis)
    if (insights.length < 3) {
      if (totalClicksCount > 0 || saleLocalstoreCount > 0 || balanceAmount > 0) {
        insights.add("Estoy monitoreando activamente tu rendimiento de marketing de afiliados. A medida que generes más datos a través de promociones continuas, proporcionaré información cada vez más detallada y procesable para ayudar a optimizar tu estrategia.");
      } else {
        insights.add("Tu cuenta está configurada y lista para actividades de marketing de afiliados. Comienza promocionando tus enlaces a través de marketing de contenido, redes sociales o campañas de correo electrónico para generar tus primeros clics y datos de ventas.");
      }
    }

    return insights;
  }

  String daysBetween(DateTime time) {
    // REQUERIMIENTO V15.1: Cálculo de días considerando solo la fecha
    final now = DateTime.now();
    final date1 = DateTime(now.year, now.month, now.day);
    final date2 = DateTime(time.year, time.month, time.day);
    final days = date2.difference(date1).inDays;
    return days.toString();
  }

  String convertDate(DateTime time) {
    try {
      return Jiffy.parseFromDateTime(time).yMMMMdjm;
    } catch (e) {
      // Fallback to a basic format if Jiffy fails
      return '${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}';
    }
  }
}