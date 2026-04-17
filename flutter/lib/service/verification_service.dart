import 'dart:convert';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';

import 'package:image_picker/image_picker.dart';

class VerificationService {
  static final VerificationService instance = VerificationService._();
  VerificationService._();

  Future<bool> submitVerification({
    required String address,
    required String phone,
    required XFile dniFile,
    required XFile dniBackFile,
    required XFile faceFile,
  }) async {
    print("📡 [VERIFICATION] Iniciando envío Multipart con Reverso (Web-Safe)...");
    try {
      final user = await SharedPreference.getUserData();
      final String token = user?.data?.token ?? '';

      if (token.isEmpty) return false;

      // Construcción del FormData con soporte para Reverso (Web compatible)
      final formData = dio_pkg.FormData.fromMap({
        'address': address,
        'phone': phone,
        'dni': await dio_pkg.MultipartFile.fromBytes(
          await dniFile.readAsBytes(),
          filename: dniFile.name,
        ),
        'dni_back': await dio_pkg.MultipartFile.fromBytes(
          await dniBackFile.readAsBytes(),
          filename: dniBackFile.name,
        ),
        'face_photo': await dio_pkg.MultipartFile.fromBytes(
          await faceFile.readAsBytes(),
          filename: faceFile.name,
        ),
      });

      final response = await ApiService.instance.dio.post(
        'https://embajadoresx.com/api/submit_verification',
        data: formData,
        options: dio_pkg.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print("📦 [VERIFICATION RESPONSE]: ${response.data}");

      final rawData = response.data is String ? jsonDecode(response.data) : response.data;
      if (rawData != null && rawData['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print("🔥 [VERIFICATION ERROR]: $e");
      return false;
    }
  }
}
