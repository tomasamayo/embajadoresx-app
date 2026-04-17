import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventModel {
  final int id;
  final String title;
  final String description;
  final String remainingTime;
  final double progressPercentage;
  final bool userWon;
  final String? eventImageUrl;
  final bool status;
  final DateTime? endedAt;
  final int winnersLimit;
  final int winnersCount;
  final double userSales;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.remainingTime,
    required this.progressPercentage,
    required this.userWon,
    this.eventImageUrl,
    this.status = true,
    this.endedAt,
    required this.winnersLimit,
    required this.winnersCount,
    required this.userSales,
  });

  bool get isExpired {
    if (remainingTime == "00:00:00") return true;
    if (endedAt != null && DateTime.now().isAfter(endedAt!)) return true;
    return false;
  }

  factory EventModel.fromJson(Map<String, dynamic> jsonMap) {
    // TAREA 2: PARSEO SEGURO (Prevenir TypeErrors) - v1.2.9
    final Map<String, dynamic> eventObj = jsonMap['event'] is Map ? jsonMap['event'] : jsonMap;
    
    // Extracción de imagen con la ruta oficial assets/images/events/ (v1.3.2)
    String? imageUrl = eventObj['event_image_url']?.toString()
        ?? jsonMap['event_image_url']?.toString()
        ?? eventObj['event_image']?.toString()
        ?? eventObj['image']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      final baseUrl = ApiService.instance.baseUrl;
      final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      imageUrl = '$cleanBaseUrl/assets/images/events/$imageUrl';
    }

    // Cálculo inteligente de tiempo restante si el servidor solo envía ended_at
    String remaining = jsonMap['remaining_time']?.toString() ?? '00:00:00';
    final String endedStr = eventObj['ended_at']?.toString() ?? '';
    DateTime? ended;
    
    if (endedStr.isNotEmpty) {
      ended = DateTime.tryParse(endedStr);
      if (ended != null && (remaining == '00:00:00' || remaining.isEmpty)) {
        final diff = ended.difference(DateTime.now());
        if (!diff.isNegative) {
          String twoDigits(int n) => n.toString().padLeft(2, '0');
          remaining = "${twoDigits(diff.inHours)}:${twoDigits(diff.inMinutes.remainder(60))}:${twoDigits(diff.inSeconds.remainder(60))}";
        }
      }
    }

    bool isActive = false;
    try {
      final parts = remaining.split(':');
      if (parts.length == 3) {
        final duration = Duration(
          hours: int.parse(parts[0]), 
          minutes: int.parse(parts[1]), 
          seconds: int.parse(parts[2])
        );
        final bool timeExpired = duration.inSeconds <= 0;
        final bool dateExpired = ended != null && DateTime.now().isAfter(ended);
        isActive = !timeExpired && !dateExpired;
      }
    } catch (_) {
      isActive = false;
    }

    return EventModel(
      id: int.tryParse(eventObj['id']?.toString() ?? '0') ?? 0,
      title: eventObj['title']?.toString() ?? 'Evento Flash',
      description: eventObj['description']?.toString() ?? '',
      remainingTime: remaining,
      progressPercentage: double.tryParse(jsonMap['progress_percentage']?.toString() ?? '0.0') ?? 0.0,
      userWon: jsonMap['user_won'] == 1 || jsonMap['user_won'] == true,
      eventImageUrl: imageUrl,
      status: isActive, 
      endedAt: ended,
      winnersLimit: int.tryParse(eventObj['winners_limit']?.toString() ?? '0') ?? 0,
      winnersCount: int.tryParse(jsonMap['winners_count']?.toString() ?? '0') ?? 0,
      userSales: double.tryParse(jsonMap['user_sales']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class EventService extends GetxController {
  static final EventService instance = Get.isRegistered<EventService>() 
      ? Get.find<EventService>() 
      : Get.put(EventService._());
      
  EventService._();

  static String? globalToken;
  final Rxn<EventModel> currentEvent = Rxn<EventModel>();
  bool get currentEventStatus => currentEvent.value != null && currentEvent.value!.status;

  static void setToken(String token) {
    globalToken = token;
  }

  Future<String?> _getToken() async {
    try {
      // 1. Prioridad: RAM (Inyección directa)
      if (globalToken != null && globalToken!.isNotEmpty) {
        return globalToken;
      }

      // 2. DashboardController (GetX)
      if (Get.isRegistered<DashboardController>()) {
        final dashboard = Get.find<DashboardController>();
        final token = dashboard.loginModel?.data?.token;
        if (token != null && token.isNotEmpty) {
          globalToken = token; // Sincronizar RAM
          return token;
        }
      }
      
      // 3. SharedPreferences (Disco) - Último recurso
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        globalToken = token; // Sincronizar RAM
        return token;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    print("🚀 [EVENTOS] onInit ejecutado. Llamando a la API...");
    fetchActiveEvent();
  }

  Future<void> fetchActiveEvent() async {
    try {
      print("📡 [EVENTOS] Preparando petición..."); // Log de seguridad 1
      
      // OBTENER CREDENCIALES DE LA SESIÓN REAL
      final user = await SharedPreference.getUserData();
      final String token = user?.data?.token ?? ''; 
      
      // ORDEN: LOCALIZAR EL ID REAL del DashboardController (fuente de verdad confirmada por el log)
      String userId = '';
      if (Get.isRegistered<DashboardController>()) {
        userId = Get.find<DashboardController>().userId.value;
      }
      // Fallback a SharedPreferences si el controlador no estaba listo
      if (userId.isEmpty || userId == 'null') {
        userId = user?.data?.userId?.toString() ?? '';
      }
      
      // LOG DE SEGURIDAD REAL (No booleano)
      print("🔑 [EVENTOS] Forzando Auth -> ID: $userId, Token: ${token.length > 20 ? token.substring(0, 20) + "..." : token}");

      // FILTRO DE SEGURIDAD (Asegurar que el token es un string real y el ID no está vacío)
      if (token == 'true' || token.length < 15) {
        print("❌ [EVENTOS FATAL] El token es inválido o es un booleano: $token");
        currentEvent.value = null;
        return;
      }

      if (userId.isEmpty || userId == 'null') {
        print("❌ [EVENTOS ERROR] El User ID está vacío. Abortando petición al servidor.");
        currentEvent.value = null;
        return;
      }

      // NUEVA ESTRATEGIA: Endpoint nativo JWT (v1.3.0)
      const String finalUrl = 'https://embajadoresx.com/api/event_api/current_event';
      print("🌐 [EVENTOS DEBUG] URL Final: $finalUrl");

      final response = await ApiService.instance.dio.get(
        finalUrl,
        options: dio_pkg.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final rawResponse = response.data;

      // LOG DE RESPUESTA CRUDA OBLIGATORIO
      print("📦 [EVENTOS RAW JSON]: $rawResponse");
      
      // PARSEO BLINDADO (v1.2.9)
      dynamic rawData = rawResponse;

      // Si el backend lo devuelve como String, lo decodificamos a Map
      if (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch(e) {
          print("⚠️ [EVENTOS] Error al decodificar JSON: $e");
          currentEvent.value = null;
          return;
        }
      }

      // Reiniciar estado si no recibimos nada útil
      if (rawData == null || rawData is! Map) {
        print("⚠️ [EVENTOS] Datos inválidos o vacíos.");
        currentEvent.value = null;
        return;
      }

      final String rawStatus = rawData['status']?.toString() ?? 'false';
      final bool isSuccess = (rawStatus == 'true' || rawStatus == '1' || rawStatus == '200');

      if (!isSuccess || rawData['event'] == null) {
        print("⚠️ [EVENTOS] Servidor devolvió falso o sin eventos. Abortando.");
        currentEvent.value = null; // Muestra "¡Estén atentos!" en la UI
        return;
      }

      // --- CONTINÚA EL MAPEO DEL EVENTO SI ES SUCCESS ---
      final Map<String, dynamic> normalizedData = Map<String, dynamic>.from(rawData);
      final newEvent = EventModel.fromJson(normalizedData);
      print("🖼️ [EVENTOS IMAGE URL]: ${newEvent.eventImageUrl}"); 
      currentEvent.value = newEvent;
      
    } catch (e, stacktrace) {
      print("❌ [EVENTOS ERROR FATAL]: $e");
      print("💥 [EVENTOS STACKTRACE]: $stacktrace");
      currentEvent.value = null;
    }
  }

  String getRewardDownloadUrl(int eventId, String userId) {
    final baseUrl = ApiService.instance.baseUrl;
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$cleanBaseUrl/api/Event_api/reward_download?event_id=$eventId&user_id=$userId';
  }
}
