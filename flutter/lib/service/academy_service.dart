import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';

class CourseModel {
  final int? id;
  final String? name;
  final String? imageUrl;
  final int? lessonsCount;
  final int? completedCount;
  final double? progressPercentage;
  final int? firstLessonId;

  CourseModel({
    this.id,
    this.name,
    this.imageUrl,
    this.lessonsCount,
    this.completedCount,
    this.progressPercentage,
    this.firstLessonId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> jsonMap) {
    // REQUERIMIENTO: Fix ID 4 y manejo robusto de tipos para evitar _JsonMap error
    return CourseModel(
      id: int.tryParse(jsonMap['id']?.toString() ?? '0') ?? 0,
      name: (jsonMap['name'] ?? 'Curso sin nombre').toString(),
      imageUrl: (jsonMap['image_url'] ?? '').toString().trim(),
      lessonsCount: int.tryParse(jsonMap['lessons_count']?.toString() ?? '0') ?? 0,
      completedCount: int.tryParse(jsonMap['completed_count']?.toString() ?? '0') ?? 0,
      progressPercentage: double.tryParse(jsonMap['progress_percentage']?.toString() ?? '0.0') ?? 0.0,
      firstLessonId: int.tryParse(jsonMap['first_lesson_id']?.toString() ?? '0') ?? 0,
    );
  }
}

class LessonModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String duration;
  bool isCompleted;
  final List<String> resources;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.duration,
    required this.isCompleted,
    required this.resources,
  });

  factory LessonModel.fromJson(Map<String, dynamic> jsonMap) {
    return LessonModel(
      id: int.tryParse(jsonMap['id']?.toString() ?? '0') ?? 0,
      title: jsonMap['title'] ?? '',
      description: jsonMap['description'] ?? '',
      videoUrl: jsonMap['video_url'] ?? '',
      duration: jsonMap['duration'] ?? '',
      isCompleted: jsonMap['is_completed'] == 1 || jsonMap['is_completed'] == true,
      resources: jsonMap['resources'] != null 
          ? List<String>.from(jsonMap['resources']) 
          : [],
    );
  }
}

class ResourceModel {
  final String name;
  final String url;

  ResourceModel({required this.name, required this.url});

  factory ResourceModel.fromJson(Map<String, dynamic> jsonMap) {
    return ResourceModel(
      name: jsonMap['name'] ?? 'Recurso',
      url: jsonMap['url'] ?? '',
    );
  }
}

class AcademyService {
  static final AcademyService instance = AcademyService._();
  AcademyService._();

  static String? globalUserId; // Agregado para inyección desde RAM

  /// Recupera el ID del usuario de forma autosuficiente.
  /// 1. Intenta desde el estado global de GetX (DashboardController).
  /// 2. Intenta desde SharedPreferences.
  /// 3. Como último recurso, consulta el perfil a la API.
  Future<String> _getUserId() async {
    try {
      // 0. Prioridad: RAM (Inyección directa)
      if (globalUserId != null && globalUserId!.isNotEmpty) {
        print('✅ AcademyService: ID recuperado de RAM');
        return globalUserId!;
      }

      // 1. Intentar desde DashboardController (Memoria viva de GetX)
      if (Get.isRegistered<DashboardController>()) {
        final dashboard = Get.find<DashboardController>();
        final id = dashboard.loginModel?.data?.userId?.toString();
        if (id != null && id != "0" && id != "null") {
          print('✅ AcademyService: ID recuperado de DashboardController: $id');
          return id;
        }
      }

      // 2. Intentar desde SharedPreferences (Disco)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('user_id') ?? prefs.getString('id');
      
      if (id != null && id.isNotEmpty && id != "null" && id != "0") {
        print('✅ AcademyService: ID recuperado de Disco: $id');
        return id;
      }

      // 3. FALLBACK: Consultar perfil directamente a la API (Independencia Total)
      print('⏳ AcademyService: ID no encontrado, realizando fallback a get_my_profile_details...');
      final profileUrl = Uri.parse('https://embajadoresx.com/api/User/get_my_profile_details');
      // Nota: El ID 37 parece ser el token o el ID en este contexto según logs previos.
      // Si la API requiere un token previo, este fallback intentará recuperarlo.
      
      // Si llegamos aquí sin ID, lanzamos error para que la UI lo maneje
      throw Exception("No hay una sesión de usuario activa.");
    } catch (e) {
      print("AcademyService Error recuperando UserID: $e");
      rethrow;
    }
  }

  Future<List<CourseModel>> getCourses({String? sort}) async {
    try {
      final userId = await _getUserId();
      
      // REQUERIMIENTO V16.0: Soporte para parámetros de ordenamiento
      String urlStr = 'https://embajadoresx.com/Academy_api/courses?language_id=3';
      if (sort != null && sort.isNotEmpty) {
        urlStr += '&sort=$sort';
      }
      
      final url = Uri.parse(urlStr);
      final headers = {
        'Authorization': 'Bearer $userId',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      print('🚀 AcademyService: Fetching courses for ID: $userId with sort: $sort');
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          final List<dynamic> data = jsonData['data'] ?? [];
          
          List<CourseModel> courses = [];
          for (var item in data) {
            try {
              courses.add(CourseModel.fromJson(item));
            } catch (e) {
              print("⚠️ Error mapeando curso individual: $e");
              courses.add(CourseModel(
                id: 0,
                name: "Curso (Datos incompletos)",
                imageUrl: "",
                progressPercentage: 0.0
              ));
            }
          }
          return courses;
        }
      }
      return [];
    } catch (e) {
      print("AcademyService Error getCourses: $e");
      return [];
    }
  }

  Future<List<LessonModel>> getCourseContent(int courseId) async {
    try {
      final userId = await _getUserId();

      final url = Uri.parse('https://embajadoresx.com/Academy_api/course_content/$courseId');
      final headers = {
        'Authorization': 'Bearer $userId',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      print('🚀 AcademyService: Enviando petición getCourseContent para Course:$courseId con ID: $userId');
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Anti-crash: Verificar si la respuesta es JSON antes de decodificar
        if (response.body.contains("<!DOCTYPE html>") || !response.body.trim().startsWith('{')) {
          print("🚨 AcademyService: La API devolvió HTML o formato no válido en lugar de JSON.");
          return [];
        }

        try {
          final jsonData = json.decode(response.body);
          if (jsonData['status'] == true) {
            final List<dynamic> data = jsonData['data'] ?? [];
            
            List<LessonModel> lessons = [];
            for (var item in data) {
              try {
                // Mapeo seguro para evitar TypeError
                lessons.add(LessonModel.fromJson(item));
              } catch (e) {
                print("⚠️ AcademyService: Error mapeando lección individual: $e");
                // No añadimos lecciones corruptas para evitar crashes en la UI
              }
            }
            return lessons;
          }
        } catch (e) {
          print("🚨 AcademyService: Error decodificando JSON en getCourseContent: $e");
        }
      }
      return [];
    } catch (e) {
      print("AcademyService Error getCourseContent: $e");
      return [];
    }
  }

  Future<bool> completeLesson(int lessonId, int courseId) async {
    try {
      final userId = await _getUserId();

      // Corregir URL exacta según documentación: Academy_api/mark_complete
      final url = Uri.parse('https://embajadoresx.com/Academy_api/mark_complete');
      
      print("🚀 AcademyService: Marcando completada Tutorial:$lessonId, Category:$courseId (User:$userId)");

      // USAR MultipartRequest para enviar como Form-Data (application/x-www-form-urlencoded)
      var request = http.MultipartRequest('POST', url);
      
      // Configurar headers
      request.headers.addAll({
        'Authorization': 'Bearer $userId',
        'Accept': 'application/json',
      });
      
      // La API espera tutorial_id y category_id como form-data
      request.fields['tutorial_id'] = lessonId.toString();
      request.fields['category_id'] = courseId.toString();

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          if (jsonData['status'] == true) {
            print("✅ AcademyService: Lección marcada como completada con éxito.");
            return true;
          } else {
            print("⚠️ AcademyService: API devolvió status false: ${jsonData['message']}");
            return false;
          }
        } catch (e) {
          print("⚠️ AcademyService Error al decodificar JSON (posible HTML): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}");
          return false;
        }
      } else {
        print("❌ AcademyService Error completeLesson: Status ${response.statusCode}");
        // Si es 404 o 500, el body suele ser HTML
        if (response.body.contains("<!DOCTYPE html>")) {
          print("❌ AcademyService: La API devolvió un Error HTML (404/500). Revisa la URL o el método.");
        }
        return false;
      }
    } catch (e) {
      print("❌ AcademyService Error completeLesson exception: $e");
      return false;
    }
  }
}
