import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Reachability extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // current network status
  final Rx<ConnectivityResult> _connectStatus = ConnectivityResult.none.obs;
  ConnectivityResult get connectStatus => _connectStatus.value;

  static Reachability get instance => Get.find<Reachability>();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint("Error checking connectivity: $e");
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _connectStatus.value = ConnectivityResult.none;
    } else {
      _connectStatus.value = results.first;
    }
    debugPrint("ConnectionStatus :: = ${_connectStatus.value}");
    
    // Si no hay internet, redirigir a la pantalla offline si no estamos ya en ella
    if (!isInterNetAvailable()) {
      if (Get.currentRoute != '/offline') {
        Get.toNamed('/offline');
      }
    }
  }

  // check for network available
  bool isInterNetAvailable() {
    return _connectStatus.value != ConnectivityResult.none;
  }

  Future<bool> recheckConnection() async {
    await _initConnectivity();
    return isInterNetAvailable();
  }
}
