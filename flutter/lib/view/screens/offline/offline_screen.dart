import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../utils/reachability.dart';
import '../../../utils/colors.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);
    
    // Simular un loading breve
    await Future.delayed(const Duration(seconds: 1));
    
    bool hasInternet = await Reachability.instance.recheckConnection();
    
    setState(() => _isChecking = false);

    if (hasInternet) {
      Get.back(); // Volver a la pantalla anterior
    } else {
      Get.snackbar(
        "Sin Conexión",
        "⚠️ Sigue sin detectarse conexión.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🛡️ [UI/UX] Pantalla de error genérica transformada en pantalla de mantenimiento premium.");
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con animación de pulso (Toque Premium)
            Pulse(
              infinite: true,
              duration: const Duration(seconds: 3),
              child: Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.handyman_rounded, // Icono elegante de mantenimiento
                  size: 90,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(height: 50),
            
            // Título Impactante
            FadeInDown(
              child: const Text(
                "¡Vaya! Parece que estamos haciendo mejoras.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            
            // Subtítulo Humanizado
            FadeInUp(
              child: Text(
                "Nuestro servidor se está tomando un descanso. No te preocupes, esto suele ser temporal y estamos trabajando para que todo vuelva a funcionar.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 70),
            
            // Botón de Reintento (Diseño de Alto Contraste / Neon Green)
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _handleRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF88), // Verde Neón Embajadores X
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 15,
                    shadowColor: const Color(0xFF00FF88).withOpacity(0.5),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "REINTENTAR",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
