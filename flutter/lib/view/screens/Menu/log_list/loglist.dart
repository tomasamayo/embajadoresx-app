import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/log_list/reportListView.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/log_list/shimmer_widget.dart';
import '../../../../controller/dashboard_controller.dart';
import '../../../../controller/loglist_controller.dart';
import 'package:flutter/services.dart';

class LoglistPage extends StatefulWidget {
  const LoglistPage({super.key});

  @override
  State<LoglistPage> createState() => _LoglistPageState();
}

class _LoglistPageState extends State<LoglistPage> {
  @override
  void initState() {
    if (!Get.isRegistered<LoglistController>()) {
      Get.put(LoglistController(preferences: Get.find<DashboardController>().preferences));
    }
    Get.find<LoglistController>().getLoglistData(1, 100);
    super.initState();
  }

  void _showEditDialog(String title, String currentUrl, String linkType) {
    // TAREA 2: EXTRAER SOLO EL SLUG PARA EL INPUT (v1.8.4)
    String initialSlug = currentUrl.split('/').last;
    final TextEditingController editController = TextEditingController(text: initialSlug);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Personalizar Alias",
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Escribe tu alias personalizado (slug):",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editController,
                    enabled: !isSaving,
                    // TAREA 2: VALIDACIÓN DE UI (TEXTFIELD) (v1.8.4)
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')),
                    ],
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      hintText: "ej: mi-tienda-pro",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Solo minúsculas, números y guiones.",
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontFamily: 'Poppins'),
                  ),
                ],
              ),
              actions: [
                if (!isSaving)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Poppins'),
                    ),
                  ),
                TextButton(
                  onPressed: isSaving ? null : () async {
                    final newSlug = editController.text.trim();
                    if (newSlug.isEmpty) return;

                    setDialogState(() => isSaving = true);
                    
                    // TAREA 1 & 3: DISPARO Y MANEJO DINÁMICO (v1.8.8)
                    final result = await Get.find<LoglistController>().updateAffiliateLinks(
                      newSlug, 
                      linkType // Se pasa el tipo dinámico
                    );

                    if (context.mounted) {
                      setDialogState(() => isSaving = false);
                      
                      if (result is Map && result["success"] == true) {
                        Navigator.pop(context);
                        // TAREA 3: ÉXITO (v1.8.4)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF00FF88),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(20),
                            content: const Text(
                              "¡Alias guardado con éxito! 🚀",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                            ),
                          ),
                        );
                      } else {
                        // TAREA 4: MANEJO DE ERROR (ALIAS REPETIDO) (v1.8.4)
                        String errorMsg = "Error al actualizar el enlace.";
                        if (result is Map && result["message"] != null) {
                          String serverMsg = result["message"];
                          if (serverMsg.contains("already taken")) {
                            errorMsg = "Ese alias ya está en uso. Por favor, elige otro diferente.";
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(20),
                            content: Text(
                              errorMsg,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(color: Color(0xFF00FF88), strokeWidth: 2)
                      )
                    : const Text(
                        "Guardar",
                        style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildClonedItem(String title, String url, IconData icon, String linkType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColor.appPrimary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.link, color: AppColor.appPrimary, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    url.isNotEmpty ? url : "-",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: url.isNotEmpty ? () => _showEditDialog(title, url, linkType) : null,
                  icon: Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.4), size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: url.isNotEmpty
                      ? () {
                          Clipboard.setData(ClipboardData(text: url));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF00FF88),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(20),
                              content: const Text(
                                "Enlace copiado",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(Icons.copy, color: Colors.white.withOpacity(0.6), size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<LoglistController>(
      builder: (controller) {
        if (controller.isLoading || controller.isLoglistLoading) {
          return LoglistShimmerWidget(
            controller: controller,
          );
        } else {
          var LoglistModel = controller.LoglistData;
          return Scaffold(
            backgroundColor: const Color(0xFF0F1210), // Fondo oscuro
            body: Stack(
              children: [
                // Background Gradient
                Positioned(
                  top: -200,
                  right: -100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.6,
                        colors: [
                          AppColor.appPrimary.withOpacity(0.3),
                          AppColor.appPrimary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    AppBar(
                      foregroundColor: AppColor.appWhite,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: height * 0.08,
                      centerTitle: true,
                      title: Text(
                        AppText.my_log_list,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      actions: [
                        Container(
                          height: width * 0.10,
                          width: width * 0.10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(Get.find<DashboardController>()
                                      .loginModel!
                                      .data!
                                      .profileAvatar!)),
                              color: AppColor.dashboardCardColor,
                              border: Border.all(color: Colors.white.withOpacity(0.2))
                          ),
                        ),
                        SizedBox(
                          width: width * 0.04,
                        )
                      ],
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => controller.getLoglistData(1, 100),
                        color: const Color(0xFF00FF88),
                        backgroundColor: const Color(0xFF151515),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(), // REQUERIMIENTO: Forzar scroll para pull-to-refresh
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.04, vertical: height * 0.02),
                            child: Column(
                              children: <Widget>[
                              Obx(() {
                                final dash = Get.find<DashboardController>();
                                final isVendor = dash.loginModel?.data?.isVendor == "1";
                                final logController = Get.find<LoglistController>();
                                
                                // TAREA 2: RENDERIZADO CONDICIONAL (AFILIADO VS PROVEEDOR) (v1.9.0)
                                List<Widget> cards = [];

                                // Título de la sección
                                cards.add(
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                                    child: Text(
                                      isVendor ? "Enlaces de Proveedor" : "Mis Enlaces de Afiliado",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                );

                                // Tarjeta 1: URL de la tienda (Para Ambos)
                                 cards.add(_buildClonedItem(
                                   "URL de la tienda", 
                                   logController.urlTienda.value, 
                                   Icons.store, 
                                   "url_tienda"
                                 ));

                                 // Tarjetas exclusivas de PROVEEDOR
                                 if (isVendor) {
                                   cards.add(_buildClonedItem(
                                     "Compartir tu tienda", 
                                     logController.compartirTienda.value, 
                                     Icons.shopping_cart_outlined, 
                                     "compartir_tienda"
                                   ));
                                  cards.add(_buildClonedItem(
                                    "Invitar a proveedores", 
                                    logController.invitarProveedores.value, 
                                    Icons.person_add_alt_1, 
                                    "register_vendor"
                                  ));
                                }

                                // Tarjeta: Invitar a afiliados (Para Ambos)
                                cards.add(_buildClonedItem(
                                  "Invitar a afiliados", 
                                  logController.invitarAfiliados.value, 
                                  Icons.group_add_outlined, 
                                  "register_affiliate"
                                ));

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: cards,
                                );
                              }),
                              Builder(builder: (context) {
                                final dash = Get.find<DashboardController>();
                                final isVendor = dash.loginModel?.data?.isVendor == "1";
                                if (isVendor) {
                                  return const SizedBox.shrink();
                                }
                                return LoglistListView(controller: controller);
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    },
  );
}
}
