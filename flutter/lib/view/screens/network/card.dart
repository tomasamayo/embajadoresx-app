import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../model/network_model.dart';

class NetworkCard extends StatelessWidget {
  final Userslist data;
  const NetworkCard({super.key, required this.data});


  @override
  Widget build(BuildContext context) {
    final usuario = data;
    String cleanName = usuario.name;
    String? fotoUrl = usuario.photoUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AVATAR CON GLOW Y BADGE
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A0A0A), // Fondo base oscuro
                border: Border.all(color: const Color(0xFF00FF88), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withOpacity(0.4),
                    blurRadius: 15,
                  )
                ], // Glow verde
              ),
              child: ClipOval(
                child: (fotoUrl != null &&
                        fotoUrl.isNotEmpty &&
                        fotoUrl != "null")
                    ? CachedNetworkImage(
                        imageUrl: fotoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(color: Color(0xFF00FF88), strokeWidth: 1.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          padding: const EdgeInsets.all(12),
                          color: const Color(0xFF161B22),
                          child: Image.asset(
                            'assets/images/ex_logo.png',
                            fit: BoxFit.contain,
                            color: Colors.white24, // Sutil para fallback
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        color: const Color(0xFF161B22),
                        child: Image.asset(
                          'assets/images/ex_logo.png',
                          fit: BoxFit.contain,
                          color: Colors.white24,
                        ),
                      ),
              ),
            ),
            // BADGE FLOTANTE (+50)
            Positioned(
              right: -10,
              top: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF151520),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00FF88)),
                ),
                child: Text(
                  "+${usuario.afiliadosNuevosMes ?? 0}",
                  style: const TextStyle(
                    color: Color(0xFF00FF88),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // NOMBRE Y DATOS DEBAJO (Envueltos para evitar que las líneas los crucen)
        Container(
          color: Colors.transparent, // ELIMINADO color anterior para transparencia
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cleanName, // USA EL NOMBRE LIMPIO
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // REQUERIMIENTO V11.0: Rango motivador para perfiles nuevos
              Text(
                (usuario.rank == null || usuario.rank!.isEmpty || usuario.rank == "Socio") 
                   ? "Usuario" 
                   : usuario.rank!,
                style: TextStyle(
                  color: const Color(0xFF00FF88).withOpacity(0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                usuario.gananciaMesFormat ?? "\$0",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF00FF88), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    "+${usuario.clics ?? 0}",
                    style: const TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
