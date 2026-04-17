
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controller/bannerAndLinks_controller.dart';
import '../../../../model/marketing_material_model.dart';
import '../../../../utils/colors.dart';

class MarketingMaterialsModal extends StatefulWidget {
  final String productId;
  final String productTitle;

  const MarketingMaterialsModal({
    super.key,
    required this.productId,
    required this.productTitle,
  });

  @override
  State<MarketingMaterialsModal> createState() => _MarketingMaterialsModalState();
}

class _MarketingMaterialsModalState extends State<MarketingMaterialsModal> {
  final BannerAndLinksController controller = Get.find<BannerAndLinksController>();
  bool isLoading = true;
  MarketingMaterialModel? materials;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    debugPrint('Modal: Cargando materiales para ID: ${widget.productId}');
    setState(() {
      isLoading = true;
    });
    final result = await controller.getMarketingMaterials(widget.productId);
    debugPrint('Modal: Resultado API: ${result?.status} - Cantidad: ${result?.data.length}');
    if (mounted) {
      setState(() {
        materials = result;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints(
        minHeight: size.height * 0.4,
        maxHeight: size.height * 0.85,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Materiales de Marketing",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.productTitle,
              style: TextStyle(
                color: AppColor.appPrimary,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : (materials == null || materials!.data.isEmpty)
                    ? _buildEmptyState()
                    : _buildCategorizedList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategorizedList() {
    final all = materials!.data;
    final images = all.where((m) => _isImageMaterial(m)).toList();
    final videos = all.where((m) => _isVideoMaterial(m)).toList();
    final pdfs = all.where((m) => _isPdfMaterial(m)).toList();

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        if (images.isNotEmpty) ...[
          _buildCategoryHeader("IMÁGENES"),
          ...images.map((m) => _buildMaterialItem(m)),
        ],
        if (videos.isNotEmpty) ...[
          _buildCategoryHeader("VIDEOS"),
          ...videos.map((m) => _buildMaterialItem(m)),
        ],
        if (pdfs.isNotEmpty) ...[
          _buildCategoryHeader("DOCUMENTOS PDF"),
          ...pdfs.map((m) => _buildMaterialItem(m)),
        ],
        _buildCategoryHeader("URL EXTERNA"),
        _buildCustomUrlItem(),
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildCustomUrlItem() {
    const url = "https://landing.grupoamayo.com";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.appPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.appPrimary.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _buildIconThumb(Icons.language_rounded, AppColor.appPrimary),
        title: const Text(
          "Landing Page Grupo Amayo",
          style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
        ),
        subtitle: const Text(
          "Abrir en el navegador",
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
              onPressed: () => _copyToClipboard(url, "URL copiada"),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
              onPressed: () => _openExternalUrl(url),
            ),
          ],
        ),
      ),
    );
  }

  bool _isVideoMaterial(MarketingMaterial material) {
    final t = material.type.toLowerCase().trim();
    if (['video', 'mp4', 'mov', 'mkv'].contains(t)) return true;
    final u = material.url.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.mkv');
  }

  bool _isPdfMaterial(MarketingMaterial material) {
    final t = material.type.toLowerCase().trim();
    if (t == 'pdf') return true;
    return material.url.toLowerCase().endsWith('.pdf');
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              materials?.message ?? "No hay materiales disponibles",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              "ID: ${widget.productId}",
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _loadMaterials(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appPrimary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Reintentar"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(MarketingMaterial material) {
    final typeLower = material.type.toLowerCase().trim();
    final isImage = _isImageMaterial(material);
    IconData icon;
    Color iconColor;

    switch (typeLower) {
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        icon = Icons.image_outlined;
        iconColor = Colors.blue;
        break;
      case 'video':
      case 'mp4':
      case 'mov':
      case 'mkv':
        icon = Icons.play_circle_outline;
        iconColor = Colors.red;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf_outlined;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file_outlined;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () {
          if (isImage) {
            _showImagePreview(context, material.url, material.name);
          } else {
            _openExternalUrl(material.url); // Vista previa en navegador/visor del sistema
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: isImage ? _buildImageThumb(material.url) : _buildIconThumb(icon, iconColor),
        title: Text(
          material.name.isNotEmpty ? material.name : "Archivo ${material.id}",
          style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          material.type.toUpperCase(),
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
              onPressed: () => _copyToClipboard(material.name, "Nombre copiado"),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
              onPressed: () => _downloadFile(material.url, material.name),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black54,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins')),
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: Colors.white),
                      onPressed: () => _downloadFile(url, title),
                    ),
                  ],
                ),
                Expanded(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      "Copiado",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white.withOpacity(0.1),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(15),
    );
  }

  bool _isImageMaterial(MarketingMaterial material) {
    final t = material.type.toLowerCase().trim();
    if (['image', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'jpeg'].contains(t)) return true;
    final u = material.url.toLowerCase();
    return u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.png') ||
        u.endsWith('.gif') ||
        u.endsWith('.webp') ||
        u.endsWith('.bmp');
  }

  Widget _buildImageThumb(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 62,
        height: 44,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => Container(
            color: Colors.white.withOpacity(0.06),
            alignment: Alignment.center,
            child: Icon(Icons.image_outlined, color: Colors.white.withOpacity(0.35), size: 22),
          ),
          errorWidget: (context, _, __) => Container(
            color: Colors.white.withOpacity(0.06),
            alignment: Alignment.center,
            child: Icon(Icons.broken_image_outlined, color: Colors.white.withOpacity(0.35), size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildIconThumb(IconData icon, Color iconColor) {
    return Container(
      width: 62,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  Future<void> _downloadFile(String url, String title) async {
    final extension = url.split('.').last.split('?').first;
    String cleanName = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    cleanName = cleanName.replaceAll(RegExp(r'\s+'), '_');
    if (cleanName.isEmpty || cleanName.length < 3) {
      cleanName = "archivo_${DateTime.now().millisecondsSinceEpoch}";
    }
    if (RegExp(r'^[A-Za-z0-9]{20,}$').hasMatch(cleanName)) {
      cleanName = "archivo_${DateTime.now().millisecondsSinceEpoch}";
    }
    final safeExtension = extension.isEmpty || extension.length > 8 ? "bin" : extension;
    final fileName = "$cleanName.$safeExtension";
    
    Get.snackbar(
      "Descargando",
      "Guardando como $fileName...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.appPrimary.withOpacity(0.7),
      colorText: Colors.black,
      showProgressIndicator: true,
    );

    try {
      final dio = Dio();

      String savePath;
      String savedToLabel;

      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        final appDir = await getExternalStorageDirectory();

        if (await downloadsDir.exists()) {
          savePath = "${downloadsDir.path}/$fileName";
          savedToLabel = "Descargas";
          try {
            await dio.download(
              url.trim(),
              savePath,
              onReceiveProgress: (received, total) {
                if (total != -1) {
                  debugPrint("Progreso: ${(received / total * 100).toStringAsFixed(0)}%");
                }
              },
            );
          } catch (_) {
            final fallbackDir = Directory("${appDir!.path}/marketing_materials");
            if (!await fallbackDir.exists()) {
              await fallbackDir.create(recursive: true);
            }
            savePath = "${fallbackDir.path}/$fileName";
            savedToLabel = "Archivos de la app";
            await dio.download(
              url.trim(),
              savePath,
              onReceiveProgress: (received, total) {
                if (total != -1) {
                  debugPrint("Progreso: ${(received / total * 100).toStringAsFixed(0)}%");
                }
              },
            );
          }
        } else {
          final fallbackDir = Directory("${appDir!.path}/marketing_materials");
          if (!await fallbackDir.exists()) {
            await fallbackDir.create(recursive: true);
          }
          savePath = "${fallbackDir.path}/$fileName";
          savedToLabel = "Archivos de la app";
          await dio.download(
            url.trim(),
            savePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                debugPrint("Progreso: ${(received / total * 100).toStringAsFixed(0)}%");
              }
            },
          );
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fallbackDir = Directory("${directory.path}/marketing_materials");
        if (!await fallbackDir.exists()) {
          await fallbackDir.create(recursive: true);
        }
        savePath = "${fallbackDir.path}/$fileName";
        savedToLabel = "Documentos";
        await dio.download(
          url.trim(),
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              debugPrint("Progreso: ${(received / total * 100).toStringAsFixed(0)}%");
            }
          },
        );
      }

      Get.closeAllSnackbars();
      Get.snackbar(
        "Éxito",
        "Archivo guardado en $savedToLabel",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () async {
            final result = await OpenFilex.open(savePath);
            if (result.type != ResultType.done) {
              Get.snackbar(
                "Error",
                result.message,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          child: const Text(
            "ABRIR",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        messageText: Text(
          "Se guardó como: $fileName",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    } catch (e) {
      debugPrint('Error en descarga directa: $e');
      Get.closeAllSnackbars();
      Get.snackbar(
        "Error",
        "No se pudo descargar el archivo",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () => _openExternalUrl(url),
          child: const Text(
            "ABRIR EN NAVEGADOR",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "No se pudo abrir el enlace",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
