import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/helper/get_di.dart' as di;
import 'package:affiliatepro_mobile/view/screens/login/login.dart';
import 'package:affiliatepro_mobile/config/app_config.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:affiliatepro_mobile/utils/session_manager.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/vendor_dashboard/vendor_add_product_screen.dart';
import 'package:affiliatepro_mobile/view/screens/offline/offline_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:affiliatepro_mobile/service/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TAREA: Inicialización de Firebase (v2.0.0)
  if (!(kDebugMode && kIsWeb)) {
    try {
      await Firebase.initializeApp();

      // Registrar manejador de segundo plano
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Inicializar servicio de notificaciones
      final notificationService = NotificationService();
      await notificationService.initialize();

      // REQUERIMIENTO ESPECIAL: TOKEN VISIBLE PARA TESTING
      String? token = await FirebaseMessaging.instance.getToken();
      print('-----------------------------------------');
      print('🚀 TOKEN PARA MI AMIGO: $token');
      print('-----------------------------------------');

      debugPrint('🔥 [FIREBASE] Inicializado con éxito');
    } catch (e) {
      debugPrint('❌ [FIREBASE] Error de inicialización: $e');
    }
  } else {
    debugPrint(
        '🧪 [FIREBASE] Bypass local activado para Flutter web en modo debug.');
  }

  // TAREA 3: LOG DE INICIO
  print('🚀 [SISTEMA] App iniciada con éxito - Versión 1.2.9');

  await di.init();
  await AppConfig.load();

  // TAREA 1: SessionManager (SINGLETON) - Inicialización única al arrancar
  await SessionManager.instance.loadToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColor.appBlack,
          colorScheme: ColorScheme.dark(
            primary: AppColor.appPrimary,
            surface: AppColor.appBlack,
            onSurface: AppColor.appWhite,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColor.appPrimary,
            foregroundColor: AppColor.appWhite,
          )),
      home: const LoginPage(),
      // Obligatorio cuando Get no encuentra la ruta (restauración del Navigator, web, sesión / hot restart).
      // Sin esto, PageRedirect.page() lanza "Unexpected null value" en route_middleware.dart:200.
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const LoginPage(),
      ),
      getPages: [
        GetPage(name: '/offline', page: () => const OfflineScreen()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(
            name: '/VendorAddProductScreen',
            page: () => const VendorAddProductScreen()),
      ],
      routes: {
        '/login': (context) => const LoginPage(),
        '/VendorAddProductScreen': (context) => const VendorAddProductScreen(),
      },
    );
  }
}
