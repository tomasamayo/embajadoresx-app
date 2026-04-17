import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/network_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';

class NetworkController extends GetxController {
  NetworkController({required this.preferences});
  SharedPreferences preferences;

  bool _isLoading = false;
  bool _isNetworkLoading = false;
  final Rx<NetworkModel?> _networkModel = Rx<NetworkModel?>(null);
  final RxString searchQuery = "".obs; // TAREA: Búsqueda dinámica

  bool get isLoading => _isLoading;
  bool get isNetworkLoading => _isNetworkLoading;
  NetworkModel? get networkData => _networkModel.value;

  changeIsLoading(bool data) {
    _isLoading = data;
    update();
  }

  changeNetworkLoading(bool data) {
    _isNetworkLoading = data;
    update();
  }

  updateNetworkData(NetworkModel model) {
    _networkModel.value = model;
    update();
  }

  final RxInt totalUsers = 0.obs; // TAREA: Conteo manual
  int _recursiveProcess(List<Userslist> list) {
    int count = 0;
    for (var user in list) {
      count++;
      
      // 1. Limpieza de Nombre (Quitar HTML e imágenes residuales)
      String rawName = user.name;
      int idx = rawName.indexOf("<");
      if (idx != -1) {
        user.name = rawName.substring(0, idx).trim();
      }

      // 2. Extracción y Limpieza de URL de Foto
      String? extractedUrl;
      try {
        final RegExp regExp = RegExp('src=[\'"]([^\'"]*)[\'"]');
        final match = regExp.firstMatch(rawName);
        if (match != null && match.groupCount >= 1) {
          extractedUrl = match.group(1);
        }
      } catch (_) {}

      String? finalUrl = (user.photoUrl != null && user.photoUrl != "null" && user.photoUrl!.isNotEmpty)
          ? user.photoUrl
          : extractedUrl;

      // FIX: The Vertical Bug
      user.photoUrl = finalUrl?.replaceAll('/vertical/assets/', '/');

      // 3. Procesar Hijos
      if (user.children.isNotEmpty) {
        count += _recursiveProcess(user.children);
      }
    }
    return count;
  }

  getNetworkData() async {
    changeNetworkLoading(true);
    try {
      final userModel = await SharedPreference.getUserData();
      final token = userModel?.data?.token;
      
      final bool isAdmin = userModel?.data?.isAdmin ?? false;
      String endPoint = isAdmin ? 'Admin_Api/get_full_network' : 'My_Network/my_network';

      if (isAdmin) {
        print("👑 [ADMIN] Cargando Árbol Maestro Global...");
      } else {
        print("👤 [USER NETWORK] Solicitando red personal...");
      }

      var value = await ApiService.instance.getData(endPoint, token: token);
      
      if (value != null &&
          value is Map<String, dynamic> &&
          value.containsKey('status') &&
          value['status'] == true &&
          value.containsKey('data') &&
          value['data'] != null) {
        final model = NetworkModel.fromJson(value);
        
        // v1.3.5: Pre-procesamiento Maestro (Limpieza Preventiva)
        totalUsers.value = _recursiveProcess(model.data.userslist);
        
        print("🚀 [NETWORK SYNC] Datos procesados antes de renderizar. Fallback de logo EX restaurado.");
        updateNetworkData(model);
      } else {
        totalUsers.value = 0;
        updateNetworkData(NetworkModel(
          status: false,
          message: 'No data available',
          data: NetworkData.fromJson({}),
        ));
      }
    } catch (e) {
      debugPrint('Error getting network data: $e');
      totalUsers.value = 0;
      updateNetworkData(NetworkModel(
        status: false,
        message: 'Failed to load',
        data: NetworkData.fromJson({}),
      ));
    } finally {
      changeNetworkLoading(false);
      changeIsLoading(false);
    }
  }
}