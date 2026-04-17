import 'package:flutter/material.dart';
import '../../../../../model/Orders_model.dart';
import '../../../../../utils/colors.dart';
import 'card_detail.dart';

class OrdersCard extends StatelessWidget {
  final Order data;
  const OrdersCard({super.key, required this.data});

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
                const Text(
                  "Detalles del Pedido",
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
                  child: CardDetail(data: data),
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
                            Icons.shopping_cart_outlined,
                            color: AppColor.appPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '\$${data.total!}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
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
                
                // --- SECCIÓN DERECHA FIJA (ICONOS DE ACCIÓN) ---
                SizedBox(
                  width: 100, // Ancho fijo para botones de acción
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tipo de Pedido (Badge)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.appPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data.type.toString().toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: AppColor.appPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // --- SECCIÓN IZQUIERDA BLINDADA ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront,
                          color: Colors.white.withOpacity(0.4),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Tienda',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // --- SECCIÓN DERECHA FIJA ---
                SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '#${data.id}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
