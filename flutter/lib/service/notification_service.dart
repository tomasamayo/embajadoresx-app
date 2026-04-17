import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/preference.dart';
import '../utils/session_manager.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// REQUERIMIENTO v2.0.0: Manejador de mensajes en segundo plano (DEBE SER GLOBAL)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🌙 [FCM BACKGROUND] Mensaje recibido: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // GUARD: Evitar registros redundantes (v4.1.0)
  String? _lastRegisteredUserId;
  String? _lastRegisteredToken;

  Future<void> initialize() async {
    // 1. Configurar Local Notifications (Para banners en Foreground)
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(initializationSettings);

    // Canal de alta importancia para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'Notificaciones de Embajadores EX', 
      description: 'Este canal se usa para notificaciones importantes.',
      importance: Importance.max,
    );

    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 2. Solicitar permisos
    NotificationSettings settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ [FCM] Permisos concedidos');
    }

    // 3. Listener de refresco de Token (v2.1.0)
    // No registramos aquí al inicio porque main() corre antes del Login.
    // El registro inicial se delega al LoginController.
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 [FCM] Token refrescado detectado.');
      registerTokenWithServer(newToken);
    });

    // 4. Configurar Manejadores de Mensajes (v2.1.2)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // REQUERIMIENTO: Log específico para el usuario
      debugPrint('🔔 ¡MENSAJE RECIBIDO EN VIVO!: ${message.notification?.title}');
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Mostrar Banner Local (IMPORTANCIA MAX / PRIORIDAD HIGH)
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'ic_notification', // REQUERIMIENTO: Icono dedicado en drawable
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              playSound: true,
              enableVibration: true,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🚀 [FCM OPENED] La app se abrió desde una notificación!');
    });
  }

  Future<void> registerTokenWithServer(String fcmToken, {String? explicitUserId}) async {
    try {
      final String? userIdStr = explicitUserId ?? SessionManager.instance.userId;
      final int userId = int.tryParse(userIdStr ?? '0') ?? 0;
      final String? authToken = SessionManager.instance.token;

      if (userId <= 0) {
        debugPrint('⚠️ [FCM] Abortando registro: ID de usuario inválido o nulo ($userId).');
        return;
      }

      final body = {
        'user_id': userId.toString(),
        'fcm_token': fcmToken,
        'device_type': 'android',
      };

      debugPrint('📡 [FCM] Intentando envío al servidor para usuario ID: $userId');
      
      final res = await ApiService.instance.postData2('api/register_fcm_token', body, token: authToken);

      if (res != null && (res['status'] == true || res['status'] == 'success' || res['status'] == 'ok')) {
        print('✅ [SERVIDOR] Registro de token exitoso');
      } else {
        print('❌ [SERVIDOR] Error: ${res?['message'] ?? 'Respuesta inválida del servidor'}');
      }
    } catch (e) {
      print('❌ [SERVIDOR] Error: $e');
    }
  }

  // REQUERIMIENTO v4.2.0: Desvincular token al cerrar sesión
  Future<void> unregisterFCMFromServer() async {
    try {
      final String? userIdStr = SessionManager.instance.userId;
      final String? fcmToken = await getToken();
      final String? authToken = SessionManager.instance.token;

      if (userIdStr == null || fcmToken == null) return;

      final body = {
        'user_id': userIdStr,
        'fcm_token': fcmToken,
        'action': 'unregister' // Flag preventivo por si el endpoint es el mismo
      };

      debugPrint('📡 [FCM] Desvinculando token para usuario: $userIdStr');
      
      // Intentamos con un endpoint dedicado o el mismo con flag
      await ApiService.instance.postData2('api/unregister_fcm_token', body, token: authToken);
      
      print('✅ [FCM] Token desvinculado exitosamente del servidor');
    } catch (e) {
      debugPrint('⚠️ [FCM] Error al desvincular token (posiblemente endpoint inexistente): $e');
    }
  }

  Future<String?> getToken() async => await _messaging.getToken();

  // REQUERIMIENTO: Registro robusto v4.0.0
  Future<void> registerFCMTokenIfReady() async {
    try {
      final String? userIdStr = SessionManager.instance.userId;
      final int userId = int.tryParse(userIdStr ?? '0') ?? 0;

      if (userId <= 0) {
        debugPrint('⚠️ [FCM] Esperando userId válido...');
        return;
      }

      final String? fcmToken = await getToken();
      if (fcmToken == null) {
        debugPrint('⚠️ [FCM] No se pudo obtener el token de Firebase.');
        return;
      }

      // GUARD: Evitar registros redundantes si nada ha cambiado
      if (_lastRegisteredUserId == userIdStr && _lastRegisteredToken == fcmToken) {
        debugPrint('🛡️ [FCM] Registro omitido: Token ya sincronizado para userId=$userId');
        return;
      }

      // Llamada directa al servidor
      await registerTokenWithServer(fcmToken, explicitUserId: userIdStr);
      
      // Actualizar estado del guard
      _lastRegisteredUserId = userIdStr;
      _lastRegisteredToken = fcmToken;
      
      print('✅ [FCM] Token registrado para userId=$userId');
    } catch (e) {
      debugPrint('❌ [FCM] Error en registerFCMTokenIfReady: $e');
    }
  }

  // Alias para compatibilidad con código existente
  Future<void> syncDeviceToken() async => await registerFCMTokenIfReady();

  void resetRegistrationGuard() {
    _lastRegisteredUserId = null;
    _lastRegisteredToken = null;
    debugPrint('🛡️ [FCM] Guards de registro reseteados.');
  }
}
