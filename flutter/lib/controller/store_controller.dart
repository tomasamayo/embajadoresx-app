import 'package:get/get.dart';
import '../../service/api_service.dart';
import '../../utils/preference.dart';

class StoreController extends GetxController {
  final String _defaultStoreUrl = 'https://embajadoresx.com/store';
  
  /// TAREA 1 & 2: Gestión de Magic Link Dinámico (Slots / Store) con Timeout
  Future<String?> fetchAutoLoginUrl({String redirectPath = 'store'}) async {
    try {
      final userModel = await SharedPreference.getUserData();
      final token = userModel?.data?.token;

      if (token == null || token.isEmpty) {
        print("⚠️ [AUTO-LOGIN] Fallback: No se encontró sesión activa.");
        return _defaultStoreUrl;
      }

      // Log específico para Slots si aplica (REQUERIMIENTO OBLIGATORIO)
      if (redirectPath.contains('slots')) {
        print("🎰 [SLOTS] Petición de Auto-Login generada para redirección: $redirectPath.");
      } else {
        print("🔑 [AUTO-LOGIN] Petición enviada. Procesando llave de paso para: $redirectPath...");
      }
      
      // REQUERIMIENTO: Inyectamos el Bearer Token, el redirectPath dinámico y aplicamos Timeout de 5s
      final response = await ApiService.instance.getData(
        'index.php/user/generate_autologin_token?redirect=$redirectPath',
        token: token,
      ).timeout(const Duration(seconds: 5));

      if (response != null && response['status'] == true && response['autologin_url'] != null) {
        final magicLinkUrl = response['autologin_url'].toString();
        print("🔑 [AUTO-LOGIN] Token recibido exitosamente para $redirectPath. Cargando WebView...");
        return magicLinkUrl;
      } else {
        print("⚠️ [AUTO-LOGIN] Fallback: El servidor no devolvió una URL válida.");
        return _defaultStoreUrl;
      }
    } catch (e) {
      // Captura silenciosa de Timeout o error de red para no bloquear la experiencia del usuario
      print("❌ [AUTO-LOGIN] Fallback activado por Timeout o Error de red: $e");
      return _defaultStoreUrl;
    }
  }
}
