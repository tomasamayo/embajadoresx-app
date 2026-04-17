import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/components/SnackBar.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/main_container/main_container.dart';
import 'package:affiliatepro_mobile/view/screens/reniew/renew_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/view/screens/blocked_user/blocked_user_page.dart';
import '../model/user_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';
import '../utils/session_manager.dart';
import '../utils/util.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../view/screens/login/login.dart';
import 'dashboard_controller.dart';
import 'main_controller.dart';
import 'network_controller.dart';
import 'bannerAndLinks_controller.dart';
import 'payments_detail_controller.dart';
import 'award_levels_controller.dart';
import '../service/academy_service.dart';
import '../service/event_service.dart';
import '../service/notification_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  LoginController({
    required this.preferences,
  });
  SharedPreferences preferences;

  // Google Sign In Instance
  GoogleSignIn? _googleSignIn;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ConfirmPasswordController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  bool terms = false;
  int isVendor = 0; // 0 = Affiliate, 1 = Vendor

  // TAREA: Estadísticas Públicas Dinámicas (v1.2.9)
  var totalEmbajadores = "12,540".obs;
  var totalPagados = "4.2M".obs;
  bool _isStatsLoading = false;
  bool get isStatsLoading => _isStatsLoading;

  bool _isLoading = false;
  bool _AutoisLoading = true;
  bool _rememberMe = false;
  bool _isObscure = true;

  bool get isLoading => _isLoading;
  bool get autoIsLoading => _AutoisLoading;
  bool get rememberMe => _rememberMe;
  bool get isObscure => _isObscure;

  @override
  void onInit() {
    super.onInit();
    checkRememberData();
    getPublicStats(); // TAREA: Carga inicial de estadísticas
    // REQUERIMIENTO: Limpiar errores al escribir
    userNameController.addListener(_onTyping);
    passwordController.addListener(_onTyping);
  }

  void _onTyping() {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
    }
  }

  @override
  void onClose() {
    userNameController.removeListener(_onTyping);
    passwordController.removeListener(_onTyping);
    super.onClose();
  }

  void toggleObscure() {
    _isObscure = !_isObscure;
    update();
  }

  String _resolveDeviceType() {
    if (kIsWeb) {
      // Compatibilidad con backend legado: el login espera un tipo móvil válido.
      return "1";
    }
    return Platform.isAndroid
        ? "1"
        : Platform.isIOS
            ? "2"
            : "1";
  }

  Future<String> _getSafeDeviceToken({
    required String logPrefix,
    int maxRetries = 3,
  }) async {
    try {
      String? token = await NotificationService().getToken();
      int retries = 0;

      while ((token == null || token.isEmpty) && retries < maxRetries) {
        debugPrint(
            '⏳ [$logPrefix] Token FCM nulo, reintentando ($retries/$maxRetries)...');
        await Future.delayed(const Duration(seconds: 1));
        token = await NotificationService().getToken();
        retries++;
      }

      if (token == null || token.isEmpty) {
        debugPrint(
            '⚠️ [$logPrefix] Continuando sin token FCM. No debe bloquear el login.');
        return '0';
      }

      return token;
    } catch (e) {
      debugPrint('⚠️ [$logPrefix] Error obteniendo token FCM: $e');
      return '0';
    }
  }

  Future<void> _syncNotificationsAfterLogin() async {
    try {
      await NotificationService().registerFCMTokenIfReady();
    } catch (e) {
      debugPrint(
          '⚠️ [LOGIN] No se pudo sincronizar el token FCM después del login: $e');
    }
  }

  String _normalizeUserStatus(String? status) {
    return status?.trim().toLowerCase() ?? '';
  }

  bool _isMembershipExpired(String status) {
    return status == "membership-status-expired";
  }

  bool _shouldBlockByUserStatus(String status) {
    if (status.isEmpty) return false;
    return status != "ok" && status != "active" && status != "approved";
  }

  bool _isTokenSyncMessage(String? message) {
    final lower = message?.trim().toLowerCase() ?? '';
    return lower.contains('sincronizar el token') ||
        lower.contains('token de notificaciones') ||
        lower.contains('notification token');
  }

  bool _rawResponseHasToken(Map<String, dynamic> value) {
    final dynamic data = value['data'];
    if (data is Map<String, dynamic>) {
      final token = data['token']?.toString().trim() ?? '';
      return token.isNotEmpty;
    }
    final token = value['token']?.toString().trim() ?? '';
    return token.isNotEmpty;
  }

  bool _hasSuccessfulAuth(UserModel userModel, Map<String, dynamic> rawValue) {
    final bool apiStatus = userModel.status ?? false;
    final bool hasTokenFromModel =
        (userModel.data?.token?.toString().trim().isNotEmpty ?? false);
    final bool hasTokenFromRaw = _rawResponseHasToken(rawValue);

    if (apiStatus && (hasTokenFromModel || hasTokenFromRaw)) {
      return true;
    }

    if (_isTokenSyncMessage(userModel.message) &&
        (hasTokenFromModel || hasTokenFromRaw)) {
      debugPrint(
          '⚠️ [LOGIN] Backend reportó problema de token de notificaciones, pero la sesión ya tiene token válido. Continuando login.');
      return true;
    }

    return false;
  }

  GoogleSignIn? _getGoogleSignIn() {
    if (kIsWeb && kDebugMode) {
      return null;
    }
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn;
  }

  checkRememberData() async {
    var userName = preferences.getString(AppText.userName) ?? "";
    userNameController.text = userName;
    // print('username$userName');
    var password = preferences.getString(AppText.password) ?? "";
    passwordController.text = password;
    // print('password$password');
    update();
  }

  chnageLoading(bool data) {
    _isLoading = data;
    update();
  }

  changeAutoLoading(bool data) {
    _AutoisLoading = data;
    update();
  }

  chnageRemeber() {
    _rememberMe = !_rememberMe;
    update();
  }

  void setData(fName, lName, email, phone) {
    firstNameController.text = fName;
    lastNameController.text = lName;
    emailController.text = email;
    phoneNumberController.text = phone;
    userNameController.text =
        preferences.getString('${AppText.userName}saved') ??
            preferences.getString(AppText.userName) ??
            "";
    passwordController.text =
        preferences.getString('${AppText.password}saved') ??
            preferences.getString(AppText.password) ??
            "";
  }

  Future<void> autoLogin(
      BuildContext context, String userName, String password) async {
    if (preferences.getString(AppText.userName) == null) {
      changeAutoLoading(false);
    }
    changeAutoLoading(true);

    Map<String, String> bodyParams = {
      "username": userName.trim(),
      "password": password.trim(),
      "is_vendor": isVendor.toString(),
    };

    // REQUERIMIENTO v4.4.0: Log de depuración para investigar 422 (AutoLogin)
    print(
        '📤 [AUTOLOGIN BODY]: username=${bodyParams["username"]} | password=${bodyParams["password"]} | is_vendor=${bodyParams["is_vendor"]}');

    try {
      final value =
          await ApiService.instance.postData('User/login', bodyParams);
      if (value == null) {
        changeAutoLoading(false);
        if (context.mounted) {
          _showLoginErrorSnackBar(context, "Error desconocido en el servidor");
        }
        return;
      }
      UserModel userModel = UserModel.fromJson(value);
      final String mensajeError =
          userModel.message ?? "Error desconocido en el servidor";
      final String status = _normalizeUserStatus(userModel.data?.userStatus);

      if (_isMembershipExpired(status)) {
        changeAutoLoading(false);
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ReniewPage()),
          );
        }
        return;
      }

      if (!_hasSuccessfulAuth(userModel, value)) {
        changeAutoLoading(false);
        if (context.mounted) {
          _showLoginErrorSnackBar(context, mensajeError);
        }
        return;
      }

      if (_shouldBlockByUserStatus(status)) {
        changeAutoLoading(false);
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BlockedUserPage()),
          );
        }
        return;
      }

      if (_hasSuccessfulAuth(userModel, value)) {
        // Guardar Token
        if (userModel.data?.token != null) {
          await SessionManager.instance.setToken(userModel.data!.token!);
        }

        // Unificar extracción de ID y persistencia (v4.0.0)
        final int? extractedId =
            SessionManager.extractUserId(value['data'] ?? value);
        if (extractedId != null && extractedId > 0) {
          final String idStr = extractedId.toString();
          await SessionManager.instance.setUserId(idStr);
          AcademyService.globalUserId = idStr;

          // Sincronización secundaria: nunca debe bloquear el login.
          unawaited(_syncNotificationsAfterLogin());
        }

        userNameController.text = userName;

        await SharedPreference.setUserData(userModel);

        if (rememberMe) {
          await SharedPreference.setRememberData(
            userName: userNameController.text,
            password: passwordController.text,
          );
        }

        await SharedPreference.saveUserNameandPassword(
          userName: userNameController.text,
          password: passwordController.text,
        );

        // REQUERIMIENTO V1.2.9: Inyección forzada de dependencias en AutoLogin (Garantizar estabilidad)
        try {
          final sharedPrefs = await SharedPreferences.getInstance();
          Get.put(DashboardController(preferences: sharedPrefs),
              permanent: true);
          Get.put(MainController(), permanent: true);
          Get.put(NetworkController(preferences: sharedPrefs), permanent: true);
          Get.put(BannerAndLinksController(preferences: sharedPrefs),
              permanent: true);
          Get.put(PaymentDetailController(), permanent: true);
          Get.put(AwardLevelsController(), permanent: true);

          final dashboard = Get.find<DashboardController>();
          dashboard.updateUserData(userModel);
          dashboard.getDashboardData();
        } catch (e) {
          debugPrint("Error inyectando dependencias en AutoLogin: $e");
        }

        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
            (route) => false,
          );
          Utils.showSnackBar(
              context, userModel.message ?? "Inicio de sesión exitoso");
        }
      } else {
        changeAutoLoading(false);
        if (context.mounted) {
          _showLoginErrorSnackBar(context, mensajeError);
        }
      }
    } catch (e) {
      print("User not found");
      print(e);
      changeAutoLoading(false);
      if (context.mounted) {
        _showLoginErrorSnackBar(context, "Error desconocido en el servidor");
      }
    } finally {
      changeAutoLoading(false);
    }
  }

  // REQUERIMIENTO v5.0.0: Login con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn? googleSignIn = _getGoogleSignIn();
      if (googleSignIn == null) {
        _showLoginErrorSnackBar(
          context,
          "Google Sign-In está deshabilitado en web local hasta configurar el client ID.",
        );
        return;
      }

      chnageLoading(true);

      // 1. Iniciar sesión con Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        chnageLoading(false);
        return; // Usuario canceló
      }

      // 2. Obtener idToken
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        chnageLoading(false);
        _showLoginErrorSnackBar(
            context, "No se pudo obtener el token de identidad de Google.");
        return;
      }

      // 3. POST al servidor propio
      final bodyParams = {"id_token": idToken};
      debugPrint('📤 [GOOGLE LOGIN]: Enviando idToken al servidor...');

      final value =
          await ApiService.instance.postData('api/google_login', bodyParams);

      if (value == null) {
        chnageLoading(false);
        _showLoginErrorSnackBar(
            context, "Error de conexión con el servidor de autenticación.");
        return;
      }

      UserModel userModel = UserModel.fromJson(value);
      final String mensajeError =
          userModel.message ?? "Error en autenticación Google";

      if (userModel.status != null && (userModel.status ?? false)) {
        // 4. Persistencia Idéntica al Login Normal
        if (userModel.data?.token != null) {
          await SessionManager.instance.setToken(userModel.data!.token!);
        }

        final int? extractedId =
            SessionManager.extractUserId(value['data'] ?? value);
        if (extractedId != null && extractedId > 0) {
          final String idStr = extractedId.toString();
          await SessionManager.instance.setUserId(idStr);
          AcademyService.globalUserId = idStr;

          // 5. Sincronización secundaria: nunca debe bloquear el login.
          unawaited(_syncNotificationsAfterLogin());
        }

        // GUARDAR MODELO Y NAVEGAR
        await SharedPreference.setUserData(userModel);

        // Limpieza de GetX e Inyección de dependencias (Copiado de loginUser para asegurar estabilidad)
        Get.deleteAll(force: true);
        final sharedPrefs = await SharedPreferences.getInstance();
        Get.put(DashboardController(preferences: sharedPrefs), permanent: true);
        Get.put(MainController(), permanent: true);
        Get.put(NetworkController(preferences: sharedPrefs), permanent: true);
        Get.put(BannerAndLinksController(preferences: sharedPrefs),
            permanent: true);
        Get.put(PaymentDetailController(), permanent: true);
        Get.put(AwardLevelsController(), permanent: true);

        final dashboard = Get.find<DashboardController>();
        dashboard.updateUserData(userModel);
        dashboard.getDashboardData();

        chnageLoading(false);
        Get.offAll(() => const MainPage());
      } else {
        chnageLoading(false);
        _showLoginErrorSnackBar(context, mensajeError);
      }
    } catch (e) {
      chnageLoading(false);
      debugPrint('❌ [GOOGLE LOGIN ERROR]: $e');
      _showLoginErrorSnackBar(
          context, "Error inesperado al conectar con Google.");
    }
  }

  _showLoginErrorSnackBar(BuildContext context, String message) {
    final text = _mapAuthErrorToSpanish(message);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        backgroundColor: const Color(0xFFD32F2F),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> getPublicStats() async {
    _isStatsLoading = true;
    update();
    try {
      // TAREA: Nuevo Endpoint Real (v1.2.9)
      final response = await http
          .get(Uri.parse('https://embajadoresx.com/api/get_public_stats'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['status'] == true) {
          // TAREA: Mapeo exacto de campos del JSON real
          final rawUsers = data['total_users']?.toString() ?? "0";
          final formattedPaid =
              data['formatted_paid_withdrawals']?.toString() ?? "\$0.00";

          totalEmbajadores.value =
              _formatNumberWithCommas(num.tryParse(rawUsers) ?? 0);
          totalPagados.value = formattedPaid;
        }
      }
    } catch (e) {
      debugPrint("Error fetching public stats: $e");
      // Mantenemos placeholders en caso de error
    } finally {
      _isStatsLoading = false;
      update();
    }
  }

  String _formatNumberWithCommas(num number) {
    String str = number.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  String _formatCompactNumberVisible(num number) {
    if (number >= 1000000) {
      double millions = number / 1000000;
      return "${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)}M";
    } else if (number >= 1000) {
      double thousands = number / 1000;
      return "${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}K";
    }
    return number.toString();
  }

  String _mapAuthErrorToSpanish(String message) {
    final raw = message.trim();
    if (raw.isEmpty) return "Error desconocido en el servidor";

    final lower = raw.toLowerCase();
    if (lower.contains("username and password something went wrong")) {
      return "Usuario o contraseña incorrectos. Inténtalo de nuevo.";
    }

    return raw;
  }

  void clearState() {
    userNameController.clear();
    passwordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneNumberController.clear();
    ConfirmPasswordController.clear();
    _isLoading = false;
    _rememberMe = false;
    update();
  }

  Future<void> loginUser(
      BuildContext context, GlobalKey<FormState> formKey) async {
    // debugPrint('inputText : ${userNameController.text}');

    // REGLA DE ORO: Bloqueo de múltiples clics por isLoading
    if (_isLoading) return;

    if (formKey.currentState?.validate() ?? false) {
      chnageLoading(true);
      update();

      // Limpiar cualquier SnackBar previo al iniciar un nuevo intento
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      try {
        Map<String, String> bodyParams = {
          "username": userNameController.text.trim(),
          "password": passwordController.text.trim(),
          "is_vendor": isVendor.toString(),
        };

        // REQUERIMIENTO v4.4.0: Log de depuración para investigar 422
        print(
            '📤 [LOGIN BODY]: username=${bodyParams["username"]} | password=${bodyParams["password"]} | is_vendor=${bodyParams["is_vendor"]}');

        final value =
            await ApiService.instance.postData('User/login', bodyParams);
        if (value == null) {
          _showLoginErrorSnackBar(context, "Error desconocido en el servidor");
          return;
        }
        UserModel userModel = UserModel.fromJson(value);
        final String mensajeError =
            userModel.message ?? "Error desconocido en el servidor";
        final String status = _normalizeUserStatus(userModel.data?.userStatus);

        if (_isMembershipExpired(status)) {
          chnageLoading(false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ReniewPage()),
          );
          return;
        }

        if (!_hasSuccessfulAuth(userModel, value)) {
          chnageLoading(false);
          _showLoginErrorSnackBar(context, mensajeError);
          return;
        }

        if (_shouldBlockByUserStatus(status)) {
          chnageLoading(false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BlockedUserPage()),
          );
          return;
        }

        if (_hasSuccessfulAuth(userModel, value)) {
          // Guardar Token
          if (userModel.data?.token != null) {
            await SessionManager.instance.setToken(userModel.data!.token!);
          }

          // Unificar extracción de ID y persistencia (v4.0.0)
          final int? extractedId =
              SessionManager.extractUserId(value['data'] ?? value);
          if (extractedId != null && extractedId > 0) {
            final String idStr = extractedId.toString();
            await SessionManager.instance.setUserId(idStr);
            AcademyService.globalUserId = idStr;

            // Sincronización secundaria: nunca debe bloquear el login.
            unawaited(_syncNotificationsAfterLogin());
          } else {
            debugPrint(
                '⚠️ [LOGIN] No se encontró userId válido en la respuesta inicial.');
          }

          // Esperar a que el modelo completo se guarde
          await SharedPreference.setUserData(userModel);

          if (rememberMe) {
            await SharedPreference.setRememberData(
              userName: userNameController.text,
              password: passwordController.text,
            );
          }

          await SharedPreference.saveUserNameandPassword(
            userName: userNameController.text,
            password: passwordController.text,
          );

          // REQUERIMIENTO V14.2: Limpieza agresiva de GetX antes de reconstruir
          Get.deleteAll(force: true);

          // REQUERIMIENTO V12.0: Inyección forzada de dependencias antes de navegar a MainPage
          // Esto soluciona el error "Unexpected null value" al re-ingresar tras un Logout.
          try {
            final sharedPrefs = await SharedPreferences.getInstance();
            Get.put(DashboardController(preferences: sharedPrefs),
                permanent: true);
            Get.put(MainController(), permanent: true);
            Get.put(NetworkController(preferences: sharedPrefs),
                permanent: true);
            Get.put(BannerAndLinksController(preferences: sharedPrefs),
                permanent: true);
            Get.put(PaymentDetailController(), permanent: true);
            Get.put(AwardLevelsController(), permanent: true);

            // Sincronizar el DashboardController con los nuevos datos
            final dashboard = Get.find<DashboardController>();
            dashboard.updateUserData(userModel);
            dashboard.getDashboardData();
          } catch (e) {
            // debugPrint("Error inyectando dependencias: $e");
          }

          // Navegación segura tras persistencia completa
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainPage()),
              (route) => false,
            );
            Utils.showSnackBar(
                context, userModel.message ?? "Inicio de sesión exitoso");
          }
        } else {
          Utils.showSnackBar(
              context, userModel.message ?? "Error en el inicio de sesión");
        }
      } catch (e) {
        debugPrint("Login Error: $e");
        _showLoginErrorSnackBar(context, "Error desconocido en el servidor");
      } finally {
        // REGLA DE ORO: Garantizar que el botón vuelva a ser clickable
        chnageLoading(false);
        update();
      }
    }
  }

  Future<void> registerUser(
      BuildContext context, isVendor, GlobalKey<FormState> formKey) async {
    if (formKey.currentState?.validate() ?? false) {
      chnageLoading(true);
      update();

      String deviceType;
      if (kIsWeb) {
        deviceType = "3";
      } else {
        deviceType = Platform.isAndroid
            ? "1"
            : Platform.isIOS
                ? "2"
                : "1";
      }

      Map<String, String> bodyParams = {
        "firstname": firstNameController.text.trim(),
        "lastname": lastNameController.text.trim(),
        "username": userNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "cpassword": ConfirmPasswordController.text.trim(),
        "device_type": deviceType,
        "device_token": '0',
        "phone": phoneNumberController.text.trim(),
        "terms": terms.toString(),
        "is_vendor": isVendor.toString(),
        if (isVendor == 1) "store_name": storeNameController.text.trim(),
      };

      try {
        final value =
            await ApiService.instance.postData('User/registarion', bodyParams);

        if (value != null && value is Map<String, dynamic>) {
          if (value['status'] == true) {
            snackBar(context, "Registration Successful", AppColor.appPrimary,
                AppColor.appWhite);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
          } else {
            String errorMessage = 'Registration failed';
            if (value['errors'] != null) {
              errorMessage = (value['errors'] as Map).values.join('\n');
            } else if (value['message'] != null) {
              errorMessage = value['message'];
            }

            snackBar(context, errorMessage, Colors.red, AppColor.appWhite);
          }
        } else {
          snackBar(context, "Unexpected response from server", Colors.red,
              AppColor.appWhite);
        }
      } catch (e) {
        print("Exception:");
        print(e.toString());
        snackBar(context, "Unable to register", Colors.red, AppColor.appWhite);
      }

      chnageLoading(false);
      update();
    }
  }

  Future<void> updateUser(BuildContext context) async {
    chnageLoading(true);
    update();

    // Handle device type for both web and mobile
    String deviceType;
    if (kIsWeb) {
      deviceType = "3"; // Web platform
    } else {
      deviceType = Platform.isAndroid
          ? "1"
          : Platform.isIOS
              ? "2"
              : "1";
    }

    Map<String, String> bodyParams = {
      "firstname": firstNameController.text.trim(),
      "lastname": lastNameController.text.trim(),
      "username": userNameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "cpassword": passwordController.text.trim(),
      "device_type": deviceType,
      "device_token": '0',
      "phone": phoneNumberController.text.trim(),
      "country_id": 'Fr',
      // "terms": "true",
    };

    try {
      final userModel = await SharedPreference.getUserData();
      final token = userModel?.data?.token;
      await ApiService.instance
          .postData2('User/update_my_profile', bodyParams, token: token)
          .then((value) {
        UserModel userModel = UserModel.fromJson(value);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return MainPage();
            },
          ),
          (route) => false,
        );
        snackBar(context, "Update Successful", AppColor.appPrimary,
            AppColor.appWhite);
      });
    } catch (e) {
      print("User not found");
      print(e.toString());
      snackBar(
          context, "Unable to update", AppColor.appPrimary, AppColor.appWhite);
    }

    chnageLoading(false);
    update();
  }

  Future<void> updateProfile(context, {File? imageFile}) async {
    chnageLoading(true);
    update();
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.instance.baseUrl}User/update_my_profile'),
      );
      request.fields['firstname'] = firstNameController.text.trim();
      request.fields['lastname'] = lastNameController.text.trim();
      request.fields['username'] = userNameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['password'] = passwordController.text.trim();
      request.fields['cpassword'] = passwordController.text.trim();

      // Handle device type for both web and mobile
      String deviceType;
      if (kIsWeb) {
        deviceType = "3"; // Web platform
      } else {
        deviceType = Platform.isAndroid
            ? "1"
            : Platform.isIOS
                ? "2"
                : "1";
      }
      request.fields['device_type'] = deviceType;

      request.fields['device_token'] = '0';
      request.fields['phone'] = phoneNumberController.text.trim();
      request.fields['country_id'] = 'Fr';

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'avatar',
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      } else {
        // send an empty file to the server to indicate that the user does not want to change their profile image
        var emptyFile = http.MultipartFile.fromBytes(
          'image',
          Uint8List.fromList([]),
          filename: 'empty.jpg',
        );
        request.files.add(emptyFile);
      }
      final userModel = await SharedPreference.getUserData();
      final token = userModel?.data?.token;
      request.headers['Authorization'] = token!;
      var response = await request.send();
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Profile updated successfully.');
        }
        var responseJson = await response.stream.bytesToString();
        print('API Response: $responseJson');

        // Add this to refresh dashboard data
        await Get.find<DashboardController>().getUser();

        Future.delayed(const Duration(milliseconds: 500), () {});

        snackBar(context, "Update Successful", AppColor.appPrimary,
            AppColor.appWhite);
      } else {
        print('Failed to update profile. ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating profile: $error');
      snackBar(
          context, "Unable to update", AppColor.appPrimary, AppColor.appWhite);
    }
    chnageLoading(false);
    update();
  }
}
