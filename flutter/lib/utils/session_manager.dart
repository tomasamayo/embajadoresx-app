import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'preference.dart';
import '../service/notification_service.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static SessionManager get instance => _instance;

  String? _token;
  String? get token => _token;

  String? _userId;
  String? get userId => _userId;

  // REQUERIMIENTO: Unificador de ID de usuario (v4.0.0)
  static int? extractUserId(Map<String, dynamic> json) {
    for (final key in ['id', 'user_id', 'userId', 'ID']) {
      final raw = json[key];
      if (raw == null || raw == 'null' || raw == '') continue;
      final parsed = int.tryParse(raw.toString());
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(SharedPreference.TOKEN_KEY);
    
    // Carga simple y directa
    _userId = prefs.getString('user_id');
    
    debugPrint('[SessionManager] CARGA COMPLETA -> Token: ' + (_token != null ? 'OK' : 'NULL') + ' | ID: ' + (_userId ?? 'NULL'));
  }

  Future<bool> setToken(String newToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool success = await prefs.setString(SharedPreference.TOKEN_KEY, newToken);
      if (success) {
        _token = newToken;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setUserId(String newId) async {
    // GUARD: Evitar redundancia (v4.1.0)
    if (_userId == newId && newId.isNotEmpty) {
      debugPrint('[SessionManager] ID ya persistido ($newId). Omitiendo escritura.');
      return true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', newId);
      await prefs.setString('id', newId); // Por compatibilidad
      _userId = newId;
      debugPrint('✅ [SESSION] userId=$newId guardado en disco y RAM');
      return true;
    } catch (e) {
      debugPrint('[SessionManager] Error al persistir ID: $e');
      return false;
    }
  }

  Future<void> clearSession() async {
    // 1. Desvincular FCM en el servidor (REQUERIMIENTO v4.2.0)
    // Se hace antes de borrar el userId de la RAM/Disco para que el request sea válido
    await NotificationService().unregisterFCMFromServer();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreference.TOKEN_KEY);
    await prefs.remove('user_id');
    await prefs.remove('id');
    await prefs.remove('user_id_int');
    _token = null;
    _userId = null;
    
    // Resetear guards de FCM
    NotificationService().resetRegistrationGuard();
    
    debugPrint('[SessionManager] Sesion limpiada');
  }
}

