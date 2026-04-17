import 'package:flutter/material.dart';

import '../../../../../model/loglist_model.dart';
import '../../../../../utils/colors.dart';
import 'card_detail.dart';

class LoglistCard extends StatelessWidget {
  final Click data;
  final String? titleOverride;
  const LoglistCard({super.key, required this.data, this.titleOverride});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    
    void showbottomSheet() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1D1A), // Un poco más claro que el fondo
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Detalles del Registro",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: LogsCardDetail(data: data),
                ),
              ],
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => showbottomSheet(),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // REQUERIMIENTO V1.2.3: Padding de seguridad
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // --- SECCIÓN IZQUIERDA BLINDADA (FLEXIBLE) ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.appPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.mouse_outlined,
                            color: AppColor.appPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            titleOverride ?? _mapClickType(data.clickType),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // --- SECCIÓN DERECHA FIJA (ICONOS) ---
                const SizedBox(
                  width: 40, // Ancho fijo para la flecha
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white24,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link,
                    color: AppColor.appPrimary,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.baseUrl,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapClickType(String raw) {
    final value = raw.trim();
    final lower = value.toLowerCase();

    if (lower == 'store sale' || lower == 'store_sale') {
      return 'Venta en tienda';
    }
    if (lower == 'store order' || lower == 'store_order') {
      return 'Referido';
    }
    if (lower == 'registration' || lower == 'register') {
      return 'Registro';
    }
    if (lower == 'store') {
      return 'Tienda';
    }

    // Fallback: usa conversión genérica para otros tipos
    return convertSnakeCaseToTitleCase(
      value.replaceAll(' ', '_').toLowerCase(),
    );
  }

  String convertSnakeCaseToTitleCase(String input) {
    List<String> words = input.split('_');
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isEmpty) continue;
      String capitalizedWord = word[0].toUpperCase() + word.substring(1);
      capitalizedWords.add(capitalizedWord);
    }

    return capitalizedWords.join(' ');
  }
}
