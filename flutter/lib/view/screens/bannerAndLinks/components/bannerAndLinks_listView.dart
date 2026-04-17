import 'package:flutter/material.dart';

import '../../../../controller/bannerAndLinks_controller.dart';
import 'card.dart';

class BannerAndLinksListView extends StatelessWidget {
  const BannerAndLinksListView({super.key, required this.controller});

  final BannerAndLinksController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var bannModel = controller.bannerAndLinksData!.data;

    if (bannModel.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border_rounded, color: Colors.white.withOpacity(0.1), size: 100),
              const SizedBox(height: 24),
              const Text(
                "AÚN NO TIENES ENLACES FAVORITOS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Dales corazón en nuestra plataforma web o crea tus propios productos para verlos aquí.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => controller.getBannerAndLinksData(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text("ACTUALIZAR LISTA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF88).withOpacity(0.1),
                  foregroundColor: const Color(0xFF00FF88),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFF00FF88), width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: controller.isGridView
          ? GridView.builder(
              key: const ValueKey('grid_view'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 120),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62, // Aumentado el espacio vertical para evitar overflow
              ),
              itemCount: bannModel.length,
              itemBuilder: (context, index) {
                final data = bannModel[index];
                
                return BannerAndLinksCard(
                  data: data,
                  isGrid: true,
                );
              },
            )
          : ListView.builder(
              key: const ValueKey('list_view'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 120),
              itemCount: bannModel.length,
              itemBuilder: (context, index) {
                final data = bannModel[index];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: BannerAndLinksCard(
                    data: data,
                    isGrid: false,
                  ),
                );
              },
            ),
    );
  }
}
