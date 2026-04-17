import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import '../../../../model/bannerAndLinks_model.dart';
import '../../../../utils/colors.dart';
import 'marketing_materials_modal.dart';

class BannerAndLinksCard extends StatelessWidget {
  final BannerData data;
  final bool isGrid;
  const BannerAndLinksCard({super.key, required this.data, this.isGrid = false});

  double calcularGanancia(dynamic precioRaw, dynamic comisionRaw) {
    try {
      // 1. Convertir a double asegurando que no haya errores de casteo
      double p = double.tryParse(precioRaw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      double c = double.tryParse(comisionRaw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

      if (p == 0.0 || c == 0.0) return 0.0;

      // 2. Si el porcentaje viene como 30, lo dividimos entre 100.0 (asegurando decimales)
      double factor = c > 1.0 ? (c / 100.0) : c;

      // 3. Multiplicar
      return p * factor;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> share() async {
    if (data.share_url != null && data.share_url.isNotEmpty) {
      await Share.share(
        data.share_url,
        subject: data.title,
      );
    }
  }

  void _copyToClipboard(BuildContext context) {
    if (data.share_url != null && data.share_url.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: data.share_url));
      HapticFeedback.lightImpact();
      
      // SnackBar moderno estilo flotante
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88), size: 20),
              SizedBox(width: 12),
              Text(
                "Enlace copiado correctamente",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showQRModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF151515),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Código QR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Escanea este código para acceder al enlace directamente",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 32),
                
                // QR Code Container with corners
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: (data.share_url != null && data.share_url.isNotEmpty)
                      ? QrImageView(
                          data: data.share_url,
                          version: QrVersions.auto,
                          size: 200.0,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        )
                      : const SizedBox(
                          height: 200,
                          width: 200,
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                ),
                
                const SizedBox(height: 40),
                
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Cerrar Panel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDescriptionModal(BuildContext context) {
    // REQUERIMIENTO V1.2.3: Sanitizar HTML de la descripción
    String cleanDescription = data.product_description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), "").trim();
    
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF151515),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Descripción del Producto",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      cleanDescription.isNotEmpty
                          ? cleanDescription
                          : "No hay una descripción detallada disponible en este momento.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.appPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMarketingMaterials(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return MarketingMaterialsModal(
          productId: data.id,
          productTitle: data.title,
        );
      },
    );
  }

  Widget _buildRatingStars(String rating, {double size = 12}) {
    final double val = double.tryParse(rating) ?? 0.0;
    // Usamos round() para que 4.5+ sea 5 y <4.5 sea 4, o toInt() si quieres el valor exacto de la base
    final int fullStars = val.round().clamp(0, 5); 
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < fullStars ? Icons.star_rounded : Icons.star_border_rounded,
          color: index < fullStars ? const Color(0xFF00E676) : Colors.grey[700],
          size: size,
        );
      }),
    );
  }

  Widget _buildHotBadge() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F).withOpacity(0.9), // Fondo oscuro premium
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF4500).withOpacity(0.6), width: 1), // Borde rojizo
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4500).withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("🔥", style: TextStyle(fontSize: 12)),
            SizedBox(width: 4),
            Text(
              "TOP VENTAS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacepile({bool isGrid = false}) {
    if (data.totalAffiliates <= 0) return const SizedBox.shrink();

    final int avataresMostrados = data.affiliatesAvatars.length.clamp(0, 3);
    final int resto = data.totalAffiliates - avataresMostrados;

    return Padding(
      padding: EdgeInsets.only(top: isGrid ? 4.0 : 8.0, bottom: isGrid ? 6.0 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avataresMostrados > 0)
            SizedBox(
              height: 24,
              width: (avataresMostrados * 14.0) + (resto > 0 ? 22.0 : 10.0),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  ...List.generate(
                    avataresMostrados,
                    (index) => Positioned(
                      left: index * 12.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5), // Borde blanco premium
                        ),
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: CachedNetworkImageProvider(data.affiliatesAvatars[index]),
                        ),
                      ),
                    ),
                  ),
                  if (resto > 0)
                    Positioned(
                      left: avataresMostrados * 12.0,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF88), // Verde Neón
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: const Color(0xFF00FF88),
                          child: Text(
                            "+$resto",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          if (data.totalAffiliates > 0)
            Expanded(
              child: Text(
                "+${data.totalAffiliates} vendiendo",
                style: TextStyle(
                  color: isGrid ? const Color(0xFF00FF88).withOpacity(0.8) : Colors.grey[400],
                  fontSize: isGrid ? 7.5 : 10,
                  fontWeight: isGrid ? FontWeight.w900 : FontWeight.normal,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 DEBUG PRECIO Y COMISION
    // print('🔥 DEBUG PRECIO: ${data.price} | COMISION: ${data.sale_commision_you_will_get}');
    print("🎨 [UI FIX] Filtro 'Mis Favoritos' oculto para admin. Botón de descarga reubicado a bottom-left.");

    if (isGrid) {
      return _buildGridCard(context);
    }
    
    // Glassmorphism Card Style
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515).withOpacity(0.8), // Dark base
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)), // Subtle border
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Glassmorphism
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section (REQUERIMIENTO V2.0: AspectRatio 16/9 y Compactación)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: data.fevi_icon.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: data.fevi_icon,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.2),
                              colorBlendMode: BlendMode.darken,
                              placeholder: (context, url) => Container(color: const Color(0xFF1E1E1E)),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF1E1E1E),
                                child: const Center(
                                  child: Icon(Icons.image, color: Colors.grey, size: 40),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF1E1E1E),
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.grey, size: 40),
                              ),
                            ),
                    ),
                    // Info Button
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => _showDescriptionModal(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    // Tag
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Text(
                                data.aff_tool_type.isNotEmpty 
                                  ? (data.aff_tool_type.toUpperCase() == "STORE_PRODUCT" ? "PRODUCTO" : data.aff_tool_type.toUpperCase())
                                  : "RECURSO",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Botón de Descarga (Marketing Materials) - Rescatado y reubicado a bottom-left
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => _showMarketingMaterials(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.file_download_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    // QR Button (v1.2.9)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _showQRModal(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.qr_code_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    // Badge de Fuego (TOP VENTAS)
                    if (data.isTopHot) _buildHotBadge(),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRatingStars(data.product_avg_rating, size: 12),
                        if (data.is_favorite)
                          const Icon(Icons.favorite_rounded, color: Color(0xFF00FF88), size: 14),
                      ],
                    ),
                    
                    // Facepile de Afiliados (List View)
                    _buildFacepile(),

                    const SizedBox(height: 6),
                    
                    // Titulo (Compactado v2.0)
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Commission Highlight Row (Compactado v2.0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF88).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "COMISIÓN",
                                style: TextStyle(
                                  color: const Color(0xFF00FF88).withOpacity(0.8),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  String commStr = data.sale_commision_you_will_get.toString();
                                  if (commStr == "Variable" || commStr.isEmpty) {
                                    return const Text("VARIABLE", style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Poppins'));
                                  }
                                  double p = double.tryParse(data.price.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                                  double c = double.tryParse(commStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                                  double ganancia = p * (c > 1.0 ? c / 100.0 : c);
                                  return Text(
                                    ganancia > 0 ? '\$${ganancia.toStringAsFixed(2)}' : "0.00",
                                    style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
                                  );
                                }
                              ),
                            ],
                          ),
                          Container(width: 1, height: 20, color: Colors.white.withOpacity(0.05)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "PRECIO",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                data.price.isNotEmpty ? data.price : "-",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action Buttons Row (REQUERIMIENTO V2.0: Copy & Ver Banners in Row)
                    Row(
                      children: [
                        // Main Action Button (Copy Enlace)
                        Expanded(
                          child: Material(
                            color: const Color(0xFF00FF88),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () => _copyToClipboard(context),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.copy_rounded, color: Colors.black, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      "COPIAR ENLACE",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Share Mini Button (Alineado tras eliminar Ver Banners)
                        GestureDetector(
                          onTap: share,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.share_outlined, color: Colors.white70, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : "-",
            style: const TextStyle(
              color: AppColor.appPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white10,
    );
  }

  Widget _buildGridCard(BuildContext context) {
    const Color neonGreen = Color(0xFF00FF88);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section (Grid)
              Expanded(
                flex: 10,
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: data.fevi_icon.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: data.fevi_icon,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.2),
                              colorBlendMode: BlendMode.darken,
                              placeholder: (context, url) => Container(color: const Color(0xFF1E1E1E)),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF1E1E1E),
                                child: const Center(
                                  child: Icon(Icons.image, color: Colors.grey, size: 24),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF1E1E1E),
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.grey, size: 24),
                              ),
                            ),
                    ),
                    // Info Button (Grid)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: GestureDetector(
                        onTap: () => _showDescriptionModal(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    // Download Button (Grid)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _showMarketingMaterials(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.file_download_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    // Tag (Grid)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            data.aff_tool_type.isNotEmpty 
                              ? (data.aff_tool_type.toUpperCase() == "STORE_PRODUCT" ? "PRODUCTO" : data.aff_tool_type.toUpperCase())
                              : "RECURSO",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Favorite Indicator (Grid Heart) - v1.2.9
                    if (data.is_favorite)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFF00FF88),
                            size: 12,
                          ),
                        ),
                      ),
                    // Badge de Fuego (TOP VENTAS - Grid)
                    if (data.isTopHot) _buildHotBadge(),
                  ],
                ),
              ),
              // Info Section (Grid)
              Expanded(
                flex: 15,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. Rating Stars (V5.0)
                      _buildRatingStars(data.product_avg_rating, size: 12),
                      
                      // Facepile de Afiliados (Grid View)
                      _buildFacepile(isGrid: true),
                      
                      // 2. Title
                      SizedBox(
                        height: 28,
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 3. Price & Profit Block (V5.0 - Doble Columna)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Precio Columna
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Precio",
                                  style: TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'Poppins'),
                                ),
                                Text(
                                  data.price.isNotEmpty ? data.price : "-",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Ganancia Columna
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Ganancia",
                                  style: TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'Poppins'),
                                ),
                                Builder(
                                  builder: (context) {
                                    String commStr = data.sale_commision_you_will_get.toString();
                                    if (commStr == "Variable" || commStr.isEmpty) {
                                      return const Text("VAR", style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Poppins'));
                                    }
                                    double p = double.tryParse(data.price.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                                    double c = double.tryParse(commStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                                    double ganancia = p * (c > 1.0 ? c / 100.0 : c);
                                    return Text(
                                      ganancia > 0 ? '\$${ganancia.toStringAsFixed(2)}' : "0.00",
                                      style: const TextStyle(
                                        color: Color(0xFF00FF88),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 4. Action Buttons (Grid V5.0)
                      Row(
                        children: [
                          // Share
                          GestureDetector(
                            onTap: share,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Icon(Icons.share_outlined, color: Colors.white70, size: 14),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Copy Link
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _copyToClipboard(context),
                              child: Container(
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: neonGreen,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: neonGreen.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "COPIAR",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
