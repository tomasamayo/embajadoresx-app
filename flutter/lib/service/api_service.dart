import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' as getx;
import '../utils/preference.dart';
import '../utils/reachability.dart';
import '../view/screens/login/login.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  ApiService._internal() {
    _dio.options.connectTimeout = const Duration(seconds: 120);
    _dio.options.receiveTimeout = const Duration(seconds: 120);
    _initializeInterceptors();
  }

  factory ApiService() {
    return _instance;
  }

  // Mantenemos 'instance' para compatibilidad con el código antiguo
  static final ApiService instance = _instance;

  final Dio _dio = Dio();
  Dio get dio => _dio;

  void _initializeInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // TAREA 3: PREVENCION DE EXPIRACION (SOFT)
          // NO borramos el token de inmediato para permitir reintentos o verificaciones de sesion manuales.
          debugPrint('ERROR 401 DETECTADO (Dio): La sesion podria haber expirado.');
          
          // Solo redirigimos si realmente no podemos recuperar la sesion o el usuario lo decide.
          // Por ahora, mantenemos la redireccion pero sin el logOut agresivo inmediato si es posible.
          // await SharedPreference.logOut(); // COMENTADO para evitar borrado accidental
          
          getx.Get.offAll(() => const LoginPage()); 
          
          getx.Get.snackbar(
            "Sesion Expirada",
            "Tu sesion ha caducado. Por favor, ingresa de nuevo.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: getx.SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
        }

        // REDIRECCIÓN GLOBAL A MANTENIMIENTO PARA ERRORES CRÍTICOS DEL SERVIDOR (v1.2.9)
        if (e.response?.statusCode == 500 || e.response?.statusCode == 503 || e.response?.statusCode == 504) {
          debugPrint('🚨 [CRITICAL ERROR] Server ${e.response?.statusCode} detectado. Redirigiendo a mantenimiento.');
          getx.Get.toNamed('/offline');
        }

        return handler.next(e);
      },
    ));
  }

  String get baseUrl => _baseUrl;

  final String _baseUrl = AppConfig.baseUrl;
  final String _licenseKey = AppConfig.licenseKey;

  // TAREA 2: URL CENTRALIZADA PARA ACTUALIZACIÓN DE ENLACES (v1.7.7)
  static const String updateAffiliateLinkUrl = 'https://embajadoresx.com/api/update_affiliate_link';

  Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  // --- MÉTODOS ORIGINALES (DIO) ---

  Future<bool> validateLicense() async {
    final response = await postData('user/license_validate', {
      'license_key': _licenseKey,
    });

    if (response != null && response['status'] == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> getData(String endPoint,
      {String? token}) async {
    try {
      String url = _baseUrl + endPoint;
      Response response;
      // TAREA 1: ASEGURAR TOKEN CON PREFIJO BEARER (v30.0.0)
      final String authHeader = (token != null && !token.startsWith('Bearer ')) 
          ? 'Bearer $token' 
          : (token ?? '');

      if (token == null) {
        response = await _dio.get(url, options: Options(headers: headers));
      } else {
        headers['Authorization'] = authHeader;
        response = await _dio.get(url, options: Options(headers: headers));
      }

      final data = response.data;

      // PROTECCIÓN HTML: Si el servidor devuelve una página de error en vez de JSON
      if (data is String && (
          data.trimLeft().startsWith('<!DOCTYPE') ||
          data.trimLeft().startsWith('<html') ||
          data.trimLeft().startsWith('<!doctype'))) {
        debugPrint('❌ [API ERROR] HTML detectado en getData($endPoint) — posible 404/500');
        return {'status': false, 'message': 'Error 404: Endpoint no encontrado en el servidor ($endPoint)'};
      }

      return data;
    } on DioException catch (e) {
      // TAREA 1 (v9.0.0): BYPASS TOTAL 403. Ya no mostramos el mensaje de error "Acceso denegado".
      // El controlador manejará la respuesta (sea 403 o no) cargando productos de fallback si es necesario.
      if (e.response?.statusCode == 403) {
        print('🛡️ [BYPASS v9.0.0] 403 Detectado. Silenciando error para permitir carga de productos de fallback.');
        return e.response?.data; // Retornamos la data del error para que el controlador pueda decidir
      }
      
      // TAREA 1: Solo redirigir a Offline si es un error de red real (Socket o Timeout)
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.sendTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.error is SocketException) {
        debugPrint("Network Error (Dio): ${e.type} | ${e.message}");
        getx.Get.toNamed('/offline');
      }
      return null;
    } catch (error) {
      debugPrint("Unexpected Error in getData: $error");
      return null;
    }
  }

  Future<dynamic> getData2(
      String endPoint, num pageId, num perPage,
      {String? token}) async {
    try {
      String url = _baseUrl + endPoint;
      Response response;
      if (token == null) {
        response = await _dio.get('$url?page_id=$pageId&per_page=$perPage',
            options: Options(headers: headers));
      } else {
        headers['Authorization'] = token;
        headers['Access-Control-Allow-Origin'] = '*';
        response = await _dio.get(url, options: Options(headers: headers));
      }
      return response.data;
    } catch (error) {
      return null;
    }
  }

  Future<dynamic> postData(String endPoint, dynamic body) async {
    try {
      String url = _baseUrl + endPoint;
      debugPrint('[POST] 🔗 URL: $url');

      // REQUERIMIENTO v4.5.0: Depuración de Headers y Content-Type
      debugPrint('📤 [DIO GLOBAL HEADERS]: ${_dio.options.headers}');
      debugPrint('📤 [DIO GLOBAL CONTENT-TYPE]: ${_dio.options.contentType}');
      debugPrint('📤 [LOCAL HEADERS]: $headers');

      dynamic dataToSend = body;
      Options options = Options(headers: Map.from(headers));

      // REQUERIMIENTO v4.5.1: Forzar FormData y multipart/form-data en Login para evitar 422 (vía Turn 422 Fix)
      if (endPoint.contains('User/login') && body is Map) {
        dataToSend = FormData.fromMap(body as Map<String, dynamic>);
        options.contentType = 'multipart/form-data';
        debugPrint('🛠️ [FIX 422] Convirtiendo body a FormData y forzando multipart/form-data');
      }

      // REQUERIMIENTO v5.0.1: Forzar JSON para Google Login
      if (endPoint.contains('google_login')) {
        options.contentType = 'application/json';
        debugPrint('🛠️ [GOOGLE] Forzando application/json para endpoint Google');
      }

      Response response = await _dio.post(url, data: dataToSend, options: options);

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return jsonDecode(response.data);
      } else {
        return response.data; // Devolver lo que sea que haya llegado
      }
    } catch (error) {
      if (error is DioException) {
        // TAREA 1 (v47.0.0): CAPTURAR EL MENSAJE DEL ERROR 422
        if (error.response?.statusCode == 422) {
          print('DEBUG 422 LOG LIST: ${error.response?.data}');
        }
        print('[DIO POST ERROR]: ${error.type} | ${error.message}');
        if (error.response != null) {
          return error.response?.data;
        }
      }
      return null;
    }
  }

  Future<dynamic> postData2(String endPoint, dynamic body,
      {String? token}) async {
    try {
      String url = _baseUrl + endPoint;

      // Si el cuerpo es FormData, dejamos que Dio maneje el Content-Type automáticamente
      if (body is FormData) {
        headers.remove('Content-Type');
      } else {
        // Forzar cabeceras para JSON y CORS según requerimiento v1.3.0
        headers['Content-Type'] = 'application/json';
      }
      headers['Accept'] = 'application/json';

      Response response;
      // TAREA 1: ASEGURAR TOKEN CON PREFIJO BEARER (v30.0.0)
      final String authHeader = (token != null && !token.startsWith('Bearer ')) 
          ? 'Bearer $token' 
          : (token ?? '');

      if (token == null) {
        response = await _dio.post(url,
            data: body, options: Options(headers: headers));
      } else {
        headers['Authorization'] = authHeader;
        response = await _dio.post(url,
            data: body, options: Options(headers: headers));
      }
      return response.data;
    } catch (error) {
      if (error is DioException) {
        print('[DIO ERROR]: ${error.type} | ${error.message}');
        if (error.response != null) {
          print('[SERVER ERROR DATA]: ${error.response?.data}');
          return error.response?.data;
        }
      }
      return null;
    }
  }

  Future<dynamic> deleteData(String endPoint,
      {String? token}) async {
    try {
      String url = _baseUrl + endPoint;
      
      // TAREA 2: LOG DE URL COMPLETA (Requerimiento Haniel)
      print('🔗 https://www.clozemaster.com/translate/spa-eng/intentado: $url');

      Response response;
      // TAREA 1: ASEGURAR TOKEN CON PREFIJO BEARER (v30.0.0)
      final String authHeader = (token != null && !token.startsWith('Bearer ')) 
          ? 'Bearer $token' 
          : (token ?? '');

      if (token == null) {
        // TAREA 3: REINTENTO CON 'POST' (Comentario de seguridad)
        // Si el servidor rechaza DELETE, cambiar _dio.delete por _dio.post
        response = await _dio.delete(url, options: Options(headers: headers));
      } else {
        headers['Authorization'] = authHeader;
        // TAREA 3: REINTENTO CON 'POST' (Comentario de seguridad)
        // Si el servidor rechaza DELETE, cambiar _dio.delete por _dio.post
        response = await _dio.delete(url, options: Options(headers: headers));
      }
      
      // TAREA 1: FILTRO DE RESPUESTA HTML (Protección contra 404/500)
      if (response.data.toString().contains('<!doctype html>') || 
          response.data.toString().contains('<!DOCTYPE html>')) {
        print('❌ [API ERROR] Respuesta HTML detectada en lugar de JSON (404/500)');
        return {
          'status': false, 
          'message': 'Error del servidor: Ruta no encontrada (404). Contacta al administrador.'
        };
      }

      return response.data;
    } catch (error) {
      if (error is DioException) {
        print('[DIO DELETE ERROR]: ${error.type} | ${error.message}');
        
        // TAREA 1: Manejo de error 404 en catch
        if (error.response?.statusCode == 404 || 
            (error.response?.data?.toString().contains('<!doctype html>') ?? false)) {
          return {
            'status': false, 
            'message': 'Error del servidor: Ruta no encontrada (404). Contacta al administrador.'
          };
        }

        if (error.response != null) {
          print('[SERVER ERROR DATA]: ${error.response?.data}');
          return error.response?.data;
        }
      }
      return null;
    }
  }

  // --- NUEVOS MÉTODOS (HTTP) PARA INTEGRACIÓN FLASH ---

  /// Obtiene los datos del Dashboard (Endpoint temporal)
  Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('https://api-temporal.com/get-dashboard-data'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en ApiService.fetchDashboardData: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMyRedeemablePrizes(
    String userId, {
    String? token,
  }) async {
    final cleanedUserId = userId.trim().replaceAll(RegExp(r'[.\s]+$'), '');
    if (cleanedUserId.isEmpty) return <Map<String, dynamic>>[];

    final res = await getData(
      'Api/get_my_redeemable_prizes/$cleanedUserId',
      token: token,
    );
    final data = res?['data'];
    if (data is! List) return <Map<String, dynamic>>[];

    return data.whereType<Map>().map((raw) {
      final prize = Map<String, dynamic>.from(raw);

      final dynamic rawName = prize['name'] ?? prize['title'] ?? prize['prize_title'];
      final dynamic rawDescription = prize['description'] ?? prize['short_description'] ?? prize['subtitle'];
      final dynamic rawImageUrl = prize['image_url'] ?? prize['image'] ?? prize['icon'];

      final String name = rawName?.toString().trim() ?? '';
      final String description = rawDescription?.toString().trim() ?? '';
      final String imageUrl = rawImageUrl?.toString().trim() ?? '';

      if (name.isNotEmpty) {
        prize['title'] = name;
        prize['name'] = name;
      }
      if (description.isNotEmpty) {
        prize['subtitle'] = description;
        prize['description'] = description;
      }
      if (imageUrl.isNotEmpty) {
        prize['image_url'] = imageUrl;
      }

      return prize;
    }).toList();
  }

  Future<dynamic> getGlobalRanking({String? token, String? userId}) async {
    try {
      // MODO PRODUCCIÓN V9.0
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String url = 'https://embajadoresx.com/Api/get_global_ranking?t=$timestamp';
      
      if (userId != null) {
        url += '&user_id=$userId';
      }
      
      if (token != null) {
        headers['Authorization'] = token;
      }

      print('🏆 [RANKING API] Solicitando Ranking Global...');
      print('🔗 [RANKING URL]: $url');
      if (token != null) print('🔑 [RANKING TOKEN]: ${token.substring(0, 15)}...');

      Response response = await _dio.get(url, options: Options(headers: headers));

      print('📊 [RANKING STATUS]: ${response.statusCode}');
      // print('📦 [RANKING DATA]: ${response.data}'); // Opcional: muy pesado para logs de producción

      // Validación de seguridad contra HTML
      if (response.data.toString().startsWith('<!DOCTYPE html>')) {
        print('❌ [RANKING ERROR]: Respuesta HTML detectada (Posible 404/500)');
        return null;
      }

      return response.data;
    } catch (error) {
      debugPrint('Error cargando ranking: $error');
      return null;
    }
  }

  Future<dynamic> redeemPrize({
    required String userId,
    required String prizeId,
    String? token,
  }) async {
    return postData2(
      'api/redeem_prize',
      {
        'user_id': userId,
        'prize_id': prizeId,
      },
      token: token,
    );
  }

  // REQUERIMIENTO V1.2.5: Multipart POST mejorado para compatibilidad WEB y múltiples archivos
  Future<dynamic> postMultipart({
    required String endPoint,
    required Map<String, String> fields,
    required String fileField,
    List<int>? fileBytes,
    String? fileName,
    List<Map<String, dynamic>>? additionalFiles, // Para downloadable_file[]
    String? token,
  }) async {
    try {
      final url = Uri.parse(_baseUrl + endPoint);
      final request = http.MultipartRequest('POST', url);

      if (token != null) {
        final cleanToken = token.trim();
        request.headers['Authorization'] = 'Bearer $cleanToken';
        debugPrint('ENVIANDO CON HEADER: Bearer ' + cleanToken.substring(0, cleanToken.length > 10 ? 10 : cleanToken.length) + '...');
      }
      
      request.fields.addAll(fields);

      // 1. Imagen Destacada (Compatibilidad Web usando bytes) - TAREA 2: Manejo de nulos
      if (fileField.isNotEmpty && fileBytes != null && fileBytes.isNotEmpty) {
        final multipartFile = http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName ?? 'upload.jpg',
        );
        request.files.add(multipartFile);
      } else {
        debugPrint('INFO: No se adjunto imagen destacada (omitida)');
      }

      // 2. Archivos adicionales (Descargables)
      if (additionalFiles != null && additionalFiles.isNotEmpty) {
        for (var fileData in additionalFiles) {
          final String field = fileData['field'] ?? 'downloadable_file[]';
          final List<int>? bytes = fileData['bytes'];
          final String name = fileData['name'] ?? 'file';
          
          if (bytes != null && bytes.isNotEmpty) {
            request.files.add(http.MultipartFile.fromBytes(
              field,
              bytes,
              filename: name,
            ));
          }
        }
      }

      // TAREA 1: Refactorización a fromStream + TAREA 4: Timeout
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('TIMEOUT_ERROR');
      });
      
      final response = await http.Response.fromStream(streamedResponse);

      // TAREA 1: DECODIFICACIÓN SEGURA DE CARACTERES (UTF-8)
      final String responseBody = utf8.decode(response.bodyBytes);

      // TAREA 1: REVELACIÓN DEL ERROR (Captura del Body completo si no es JSON)
      if (responseBody.trim().startsWith('<!DOCTYPE') || responseBody.trim().startsWith('<html')) {
        print('🔍 [REVELACIÓN DEL ERROR]: $responseBody');
        return {
          'status': false,
          'message': 'Error del servidor (HTML detectado). Consulta la consola para ver el reporte PHP.',
          'body': responseBody
        };
      }

      // TAREA 2: LIMPIEZA DE LOGS (EVITAR EL CRASH)
      debugPrint('[SERVER RESPONSE STATUS]: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return jsonDecode(responseBody);
        } catch (e) {
          print('🔍 [REVELACIÓN DEL ERROR - JSON PARSE FAILED]: $responseBody');
          return {'status': false, 'message': 'Error al procesar respuesta del servidor (No es JSON válido).', 'body': responseBody};
        }
      } else if (response.statusCode == 401) {
        debugPrint('[MULTIPART ERROR 401]: Unauthorized');
        return {'status': false, 'code': 401, 'message': 'Unauthorized'};
      } else if (response.statusCode == 422) {
        debugPrint('[MULTIPART ERROR 422]: Validation Error');
        return {'status': false, 'code': 422, 'message': responseBody};
      } else {
        debugPrint('[MULTIPART ERROR]: ${response.statusCode} - $responseBody');
        return {'status': false, 'code': response.statusCode, 'message': responseBody};
      }
    } on SocketException catch (e) {
      debugPrint("SocketException (Multipart): $e");
      getx.Get.toNamed('/offline');
      return null;
    } on http.ClientException catch (e) {
      debugPrint("ClientException (Multipart): $e");
      getx.Get.toNamed('/offline');
      return null;
    } catch (e) {
      if (e.toString().contains('TIMEOUT_ERROR')) {
        debugPrint('[ERROR]: Server timeout');
        getx.Get.toNamed('/offline');
        return {'status': false, 'code': 408, 'message': 'Server timeout, please retry'};
      }
      debugPrint('[MULTIPART EXCEPTION]: $e');
      return null;
    }
  }
}
