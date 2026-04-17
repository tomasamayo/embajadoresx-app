import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/controller/coinx/coinx_controller.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:typed_data';

class SlotSymbol {
  final int id;
  final String image;
  final double multiplier;
  Uint8List? imageBytes;

  SlotSymbol({required this.id, required this.image, required this.multiplier, this.imageBytes});

  factory SlotSymbol.fromJson(Map<String, dynamic> json) {
    return SlotSymbol(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      multiplier: double.tryParse(json['multiplier']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SlotWinner {
  final String name;
  final String formattedPrize;
  final String avatar;
  final String date;

  SlotWinner({required this.name, required this.formattedPrize, required this.avatar, required this.date});

  factory SlotWinner.fromJson(Map<String, dynamic> json) {
    return SlotWinner(
      name: json['name'] ?? 'Usuario',
      formattedPrize: json['formatted_prize'] ?? '0 ExCoin',
      avatar: json['avatar'] ?? 'https://embajadoresx.com/assets/images/user-default.png',
      date: json['date'] ?? '',
    );
  }
}

class SlotsController extends GetxController {
  // State
  var isLoadingConfig = true.obs;
  var isSpinning = false.obs;
  var symbols = <SlotSymbol>[].obs;
  var currentReels = <int>[0, 0, 0].obs; // IDs de los símbolos actuales
  var selectedBet = 10.obs;
  var lastWinAmount = 0.0.obs;
  var spinSoundUrl = "".obs;
  
  // Estados indidivuales de carretes para parada secuencial (Premium)
  var reelIsSpinning = [false, false, false].obs;
  
  // Estado para animación visual de descuento de saldo
  var showDiscountAnim = false.obs;
  var lastBetValue = 0.obs;

  // Lista de Ganadores (Social Proof)
  var winnersList = <SlotWinner>[].obs;
  var isLoadingWinners = false.obs;

  // Controlador de Apuesta Personalizada
  final TextEditingController betController = TextEditingController(text: "10");

  // Controllers externos
  late ExCoinController coinxController;

  // Animación local
  Timer? _animationTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    // 🛡️ [GETX FIX] Aseguramos que el controlador de saldo esté disponible
    if (Get.isRegistered<ExCoinController>()) {
      coinxController = Get.find<ExCoinController>();
    } else {
      final dash = Get.find<DashboardController>();
      coinxController = Get.put(ExCoinController(preferences: dash.preferences));
    }
    
    // TAREA 1: Sincronización del controlador de texto con el estado reactivo
    betController.addListener(() {
      if (betController.text.isNotEmpty) {
        final amount = int.tryParse(betController.text) ?? 0;
        selectedBet.value = amount;
      }
    });
    
    fetchSlotsConfig();
    fetchWinners();
  }

  @override
  void onClose() {
    _animationTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchSlotsConfig() async {
    isLoadingConfig.value = true;
    try {
      final response = await ApiService.instance.getData('api/get_slots_config');
      if (response != null && response['status'] == true) {
        final List<dynamic> symbolsData = response['symbols'] ?? [];
        var mappedSymbols = symbolsData.map((s) {
          var symbol = SlotSymbol.fromJson(s);
          
          // TAREA: Pre-decodificación para rendimiento Web (v3.2.1)
          if (symbol.image.isNotEmpty && !symbol.image.startsWith('http')) {
            try {
              String cleaned = symbol.image.trim().replaceAll('\n', '').replaceAll('\r', '');
              String base64Content = cleaned.contains(',') ? cleaned.split(',').last : cleaned;
              int paddingNeeded = (4 - (base64Content.length % 4)) % 4;
              if (paddingNeeded > 0) base64Content += '=' * paddingNeeded;
              symbol.imageBytes = base64Decode(base64Content);
            } catch (e) {
              print("❌ [PRE-DECODE ERROR]: $e");
            }
          }
          return symbol;
        }).toList();
        
        // TAREA 2: Ordenar por multiplicador descendente (de mayor a menor)
        mappedSymbols.sort((a, b) => b.multiplier.compareTo(a.multiplier));
        symbols.assignAll(mappedSymbols);
        
        // TAREA 2: Mapeo de sonido robusto (v3.0.0)
        spinSoundUrl.value = response['sounds']?['spin']?.toString() ?? response['spin_sound']?.toString() ?? "";
        
        // Log solicitado
        print("🎰 [UI SLOTS] Tabla de premios dinámica renderizada. Total símbolos: ${symbols.length}");
        
        // Inicializar reels con símbolos aleatorios
        if (symbols.isNotEmpty) {
          currentReels.value = [
            symbols[Random().nextInt(symbols.length)].id,
            symbols[Random().nextInt(symbols.length)].id,
            symbols[Random().nextInt(symbols.length)].id,
          ];
        }
        print("🎰 [NATIVE SLOTS] Configuración cargada. Listo para apostar.");
      }
    } catch (e) {
      print("❌ [SLOTS] Error cargando config: $e");
    } finally {
      isLoadingConfig.value = false;
    }
  }

  void selectBet(int amount) {
    if (isSpinning.value) return;
    selectedBet.value = amount;
    // Sincronizamos el input visual
    betController.text = amount.toString();
  }

  Future<void> spin() async {
    if (isSpinning.value) return;

    // TAREA 3: Validación Crítica de Apuesta Personalizada
    final betText = betController.text;
    if (betText.isEmpty || (int.tryParse(betText) ?? 0) <= 0) {
      Get.snackbar("Apuesta Inválida", "Ingresa un monto válido para jugar.",
        backgroundColor: Colors.orangeAccent, colorText: Colors.black);
      return;
    }

    final int finalBetAmount = int.parse(betText);
    final currentBalance = coinxController.excoinBalance.value;
    
    if (currentBalance < finalBetAmount) {
      Get.snackbar(
        "Saldo Insuficiente", 
        "Necesitas más ExCoin para esta apuesta.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSpinning.value = true;
    reelIsSpinning.value = [true, true, true];
    lastWinAmount.value = 0.0;
    
    // TAREA 1: DESCUENTO OPTIMISTA (Mejora UX v3.0.0)
    coinxController.excoinBalance.value -= finalBetAmount;

    // TAREA 2: Disparar animación visual de descuento
    lastBetValue.value = finalBetAmount;
    showDiscountAnim.value = true;
    Future.delayed(const Duration(milliseconds: 1200), () => showDiscountAnim.value = false);

    // TAREA 2: Integración de Audio (Spin Sound)
    if (spinSoundUrl.value.isNotEmpty) {
      _audioPlayer.play(UrlSource(spinSoundUrl.value));
    }
    
    // Iniciar animación visual aleatoria
    _startSpinAnimation();

    try {
      final userId = Get.find<DashboardController>().userId.value;
      
      final response = await ApiService.instance.postData('api/play_slots', {
        'user_id': userId,
        'bet': finalBetAmount,
      });

      if (response != null && response['status'] == true) {
        final List<dynamic> resultReels = response['reels'] ?? [0, 0, 0];
        final bool win = response['win'] ?? false;
        final double newBalance = double.tryParse(response['new_balance']?.toString() ?? '0') ?? 0.0;
        final String message = response['message'] ?? "";

        // Detener animación y mostrar resultados con delay
        await _stopSpinAnimationAndShowResults(resultReels.cast<int>());

        // Actualizar balance en el controlador global
        coinxController.excoinBalance.value = newBalance;

        if (win) {
          lastWinAmount.value = double.tryParse(response['win_amount']?.toString() ?? '0') ?? 0.0;
          _showWinEffect(message);
          
          // TAREA 1: Actualizar lista de ganadores en tiempo real
          fetchWinners();
        }
      } else {
        _stopSpinAnimationInstantly();
        Get.snackbar("Error", response?['message'] ?? "Error al procesar el giro", 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      _stopSpinAnimationInstantly();
      print("❌ [SLOTS] Error en el giro: $e");
      Get.snackbar("Error de Red", "No se pudo conectar con el casino. Intenta de nuevo.", 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSpinning.value = false;
    }
  }

  Future<void> fetchWinners() async {
    isLoadingWinners.value = true;
    try {
      final response = await ApiService.instance.getData('api/get_slots_winners');
      if (response != null && response['status'] == true) {
        // TAREA 1: Corregir el mapeo de la llave 'data' (v3.1.0)
        final List<dynamic> winnersData = response['data'] ?? response['winners'] ?? [];
        winnersList.assignAll(winnersData.map((w) => SlotWinner.fromJson(w)).toList());
        print("🎰 [WINNERS FIX] Parseo de 'data' corregido. Total mapeados: ${winnersList.length}");
      }
    } catch (e) {
      // TAREA 2: Destapar Errores Silenciosos
      print("❌ [WINNERS API ERROR]: $e");
    } finally {
      isLoadingWinners.value = false;
    }
  }

  void _startSpinAnimation() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (symbols.isEmpty) return;
      
      var newList = List<int>.from(currentReels);
      for (int i = 0; i < 3; i++) {
        if (reelIsSpinning[i]) {
          newList[i] = symbols[Random().nextInt(symbols.length)].id;
        }
      }
      currentReels.value = newList;
    });
  }

  Future<void> _stopSpinAnimationAndShowResults(List<int> results) async {
    // TAREA 1: PARADA SECUENCIAL (Staggered Reel Stop)
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 600)); // Retraso entre carretes
      
      var newList = List<int>.from(currentReels);
      newList[i] = results[i];
      currentReels.value = newList;
      
      // Detener el giro visual solo para este carrete
      var spinningStates = List<bool>.from(reelIsSpinning);
      spinningStates[i] = false;
      reelIsSpinning.value = spinningStates;
    }
    
    _animationTimer?.cancel();
    _audioPlayer.stop(); // TAREA 2: Detener audio al terminar el giro (UX v3.0.0)
    print("🎰 [UX/AUDIO] Descuento optimista en tiempo real. Audio reproduciéndose desde URL limpia.");
  }

  void _stopSpinAnimationInstantly() {
    _animationTimer?.cancel();
    reelIsSpinning.value = [false, false, false];
  }

  void _showWinEffect(String message) {
    Get.snackbar(
      "¡GANASTE!", 
      message,
      backgroundColor: const Color(0xFF00FF88),
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.stars, color: Colors.black),
    );
  }
}
