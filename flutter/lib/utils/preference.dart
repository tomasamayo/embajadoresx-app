import 'dart:convert';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/utils/session_manager.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';

class SharedPreference {
  static const String TOKEN_KEY = 'user_auth_token';

  static Future<void> setUserData(UserModel userModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userMap = userModel.toJson();
    prefs.setString('UserData', jsonEncode(userMap));
  }

  static Future<void> setRememberData(
      {required String userName, required String password}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AppText.userName, userName);
    prefs.setString(AppText.password, password);
  }

  static Future<void> saveUserNameandPassword(
      {required String userName, required String password}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${AppText.userName}saved', userName);
    prefs.setString('${AppText.password}saved', password);
  }

  static Future<UserModel?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('UserData');
    if (userString == null) return null;
    Map<String, dynamic> userMap = jsonDecode(userString);
    UserModel userModel = UserModel.fromJson(userMap);
    return userModel;
  }

  static Future<bool> logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // PASO 5 — Logout limpio
    await SessionManager.instance.clearSession();
    
    // Logout de Google (v5.0.0)
    try {
      await GoogleSignIn().signOut();
      debugPrint('🔓 [GOOGLE] Sesión de Google cerrada.');
    } catch (e) {
      debugPrint('⚠️ [GOOGLE] Error al cerrar sesión de Google: $e');
    }

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().userId.value = '';
    }
    
    var d = await prefs.clear();
    debugPrint('Sesión cerrada y disco limpiado: $d');
    return true;
  }
}
