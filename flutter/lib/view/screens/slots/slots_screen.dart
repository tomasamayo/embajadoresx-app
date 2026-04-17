import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:affiliatepro_mobile/controller/slots_controller.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';

class SlotsScreen extends StatelessWidget {
  const SlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador
    final SlotsController controller = Get.put(SlotsController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo con degradado sutil
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF0A1F14), // Verde oscuro profundo
                  Colors.black,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isLoadingConfig.value) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF00FF88)),
                      SizedBox(height: 20),
                      Text("CARGANDO CASINO...", 
                        style: TextStyle(color: Color(0xFF00FF88), letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildBalanceCard(controller),
                          const SizedBox(height: 40),
                          _buildSlotMachine(controller),
                          const SizedBox(height: 40),
                          _buildBetPanel(controller),
                          const SizedBox(height: 40),
                          _buildSpinButton(controller),
                          const SizedBox(height: 50),
                          _buildPayTable(controller),
                          const SizedBox(height: 50),
                          _buildWinnersSection(controller),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          const Text(
            "SLOTS CASINO",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 40), // Balanceo
        ],
      ),
    );
  }

  Widget _buildBalanceCard(SlotsController controller) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            decoration: BoxDecoration(
              color: const Color(0xFF151916),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF88).withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TU SALDO",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      "${controller.coinxController.excoinBalance.value.toInt()} ExCoin",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    )),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.toll, color: Color(0xFFFFD700), size: 28),
                ),
              ],
            ),
          ),
          
          // TAREA 2: ANIMACIÓN DE DESCUENTO (Floating -BET)
          Obx(() => controller.showDiscountAnim.value 
            ? Positioned(
                top: -10,
                right: 50,
                child: FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  from: 20,
                  child: Text(
                    "-${controller.lastBetValue.value}",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink()
          ),
        ],
      ),
    );
  }

  Widget _buildSlotMachine(SlotsController controller) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D1B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildReelItem(controller, 0),
          _buildReelItem(controller, 1),
          _buildReelItem(controller, 2),
        ],
      ),
    );
  }

  Widget _buildReelItem(SlotsController controller, int index) {
    return Obx(() {
      final symbolId = controller.currentReels[index];
      final symbol = controller.symbols.firstWhere((s) => s.id == symbolId, 
        orElse: () => controller.symbols.first);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: controller.reelIsSpinning[index] 
              ? const Color(0xFF00FF88).withOpacity(0.6) 
              : Colors.white.withOpacity(0.1),
          ),
          boxShadow: controller.reelIsSpinning[index] ? [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: symbol.image.isNotEmpty 
            ? _buildSymbolImage(symbol)
            : const Icon(Icons.help_outline, color: Colors.white24),
        ),
      );
    });
  }

  Widget _buildBetPanel(SlotsController controller) {
    final bets = [1, 5, 10, 50, 100];
    return Column(
      children: [
        Text(
          "¿CUÁNTO QUIERES APOSTAR?",
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        
        // TAREA 2: Input de Apuesta Personalizada (Premium)
        _buildBetInput(controller),
        
        const SizedBox(height: 25),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bets.map((amount) => _buildBetButton(controller, amount)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBetButton(SlotsController controller, int amount) {
    return Obx(() {
      final isSelected = controller.selectedBet.value == amount;
      return GestureDetector(
        onTap: () => controller.selectBet(amount),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 55,
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00FF88) : const Color(0xFF1A1D1B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00FF88) : Colors.white.withOpacity(0.1),
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: -2,
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              "$amount",
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBetInput(SlotsController controller) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D1B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller.betController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF00FF88),
          fontSize: 26,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
          ),
          hintText: "1",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildSpinButton(SlotsController controller) {
    return Obx(() => Bounce(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => controller.spin(),
        child: Container(
          width: 200,
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: controller.isSpinning.value 
                ? [Colors.grey.shade800, Colors.grey.shade900]
                : [const Color(0xFF00FF88), const Color(0xFF00CC6A)],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: controller.isSpinning.value ? [] : [
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              controller.isSpinning.value ? "GIRANDO..." : "GIRAR",
              style: TextStyle(
                color: controller.isSpinning.value ? Colors.white24 : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  /// TAREA 3: SECCIÓN DE TABLA DE PREMIOS DINÁMICA
  Widget _buildPayTable(SlotsController controller) {
    return Column(
      children: [
        Text(
          "TABLA DE PREMIOS",
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            itemCount: controller.symbols.length,
            itemBuilder: (context, index) {
              final symbol = controller.symbols[index];
              return _buildPayTableCard(symbol);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPayTableCard(SlotSymbol symbol) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF151916).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          symbol.image.isNotEmpty 
            ? SizedBox(height: 45, child: _buildSymbolImage(symbol))
            : const Icon(Icons.help_outline, color: Colors.white24, size: 30),
          const SizedBox(height: 10),
          Text(
            "${symbol.multiplier.toInt()}x",
            style: const TextStyle(
              color: Color(0xFF00FF88),
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// TAREA 2 & 3: SECCIÓN DE ÚLTIMOS GANADORES (Social Proof)
  Widget _buildWinnersSection(SlotsController controller) {
    return Column(
      children: [
        Text(
          "ÚLTIMOS GANADORES",
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 25),
        
        Obx(() {
          if (controller.isLoadingWinners.value && controller.winnersList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
          }

          if (controller.winnersList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Aún no hay ganadores.\n¡Sé el primero en hacer historia!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13, height: 1.5),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // CRÍTICO para scroll interno
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.winnersList.length,
            itemBuilder: (context, index) {
              final winner = controller.winnersList[index];
              return FadeInRight(
                delay: Duration(milliseconds: 100 * index),
                child: _buildWinnerTile(winner),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildWinnerTile(SlotWinner winner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151916).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3), width: 1),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.black,
            backgroundImage: NetworkImage(winner.avatar),
            onBackgroundImageError: (_, __) => const Icon(Icons.person, color: Colors.white24),
          ),
        ),
        title: Text(
          winner.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          winner.date,
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "+ ${winner.formattedPrize}",
              style: const TextStyle(
                color: Color(0xFF00FF88),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const Text(
              "WINNER",
              style: TextStyle(color: Color(0xFF00FF88), fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// TAREA 2: LÓGICA DE DECODIFICACIÓN SEGURA BASE64 (v3.2.1 - Pre-decoded)
  Widget _buildSymbolImage(SlotSymbol symbol) {
    try {
      // 1. Prioridad: Si ya está pre-decodificado (Rendimiento v3.2.1)
      if (symbol.imageBytes != null) {
        return Image.memory(
          symbol.imageBytes!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline, color: Colors.redAccent),
        );
      }

      final String rawImage = symbol.image;
      if (rawImage.isEmpty) return const Icon(Icons.image_not_supported, color: Colors.grey);

      // 2. Detección Inteligente: ¿Es una URL?
      if (rawImage.startsWith('http')) {
        return Image.network(
          rawImage, 
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.redAccent),
        );
      }

      // 3. Decodificación al vuelo (Fallback si no se pre-decodificó)
      String cleaned = rawImage.trim().replaceAll('\n', '').replaceAll('\r', '');
      String base64Content = cleaned.contains(',') ? cleaned.split(',').last : cleaned;
      
      int paddingNeeded = (4 - (base64Content.length % 4)) % 4;
      if (paddingNeeded > 0) base64Content += '=' * paddingNeeded;
      
      return Image.memory(
        base64Decode(base64Content),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline, color: Colors.redAccent),
      );
    } catch (e) {
      print("❌ [IMAGE RENDER ERROR]: $e");
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }
  }
}
