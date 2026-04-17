import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../model/vendor_category_model.dart';
import '../model/vendor_product_model.dart';
import '../view/screens/login/login.dart';
import '../utils/preference.dart';
import '../utils/session_manager.dart';
import 'dart:convert';
import 'dart:typed_data';

class VendorAddProductController extends GetxController {
  final SharedPreferences preferences;
  VendorAddProductController({required this.preferences});

  var isLoadingCategories = false.obs;
  var isLoadingCommissions = false.obs;
  var isSaving = false.obs;
  var categories = <VendorCategory>[].obs;
  var commissionTypes = <Map<String, String>>[].obs;
  var selectedCategory = Rxn<VendorCategory>();
  var currentToken = RxnString(); // Token rastreado en tiempo real

  // Form Controllers
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final msrpPriceController = TextEditingController(); // TAREA 1: Precio de venta del producto (JSON: price)
  final priceController = TextEditingController(); // TAREA 1: Precio de lista / Oferta (JSON: sale_price)
  final quantityController = TextEditingController(text: "1");
  final categoryController = TextEditingController();
  final shortDescController = TextEditingController();
  final longDescController = TextEditingController();
  final tagsController = TextEditingController();
  var productTags = <String>[].obs;
  final videoUrlController = TextEditingController();

  // Commissions - Affiliate
  var affiliateClickCommissionType = 'default'.obs; // default, fixed, percentage
  final affiliateClickAmount = TextEditingController();
  final affiliateClickCount = TextEditingController(); // NUEVO: Para lógica de clics fijos
  var affiliateSaleCommissionType = 'default'.obs;
  final affiliateCommissionValue = TextEditingController();

  // Commissions - Admin
  var adminClickCommissionType = 'default'.obs;
  final adminClickAmount = TextEditingController();
  final adminClickCount = TextEditingController(); // NUEVO: Para lógica de clics fijos admin
  var adminSaleCommissionType = 'default'.obs;
  final adminCommissionValue = TextEditingController();

  // Admin Comments
  var previousAdminNote = "".obs; // TAREA 1: Guardar nota previa para el historial
  final adminCommentController = TextEditingController();

  void addTag(String tag) {
    if (tag.trim().isNotEmpty && !productTags.contains(tag.trim())) {
      productTags.add(tag.trim());
      tagsController.clear();
    }
  }

  void removeTag(String tag) {
    productTags.remove(tag);
  }
  
  // Image (Web Compatible using bytes)
  var featuredImageBytes = Rxn<Uint8List>();
  var featuredImageName = Rxn<String>();
  final _picker = ImagePicker();

  // Settings
  var onStore = true.obs;
  var allowShipping = false.obs;
  var allowUploadFile = false.obs; // TAREA 2: Nueva opción API
  var productIsComingSoon = false.obs; // TAREA 2: Nueva opción API

  // Product Type: virtual, downloadable, video
  var productType = 'virtual'.obs; 

  // Downloadable Files
  var downloadableFiles = <Map<String, dynamic>>[].obs; // {name, bytes}

  // Variants
  var variants = <Map<String, dynamic>>[].obs; // {type, name, price}

  Future<void> _checkAuth() async {
    try {
      // TAREA 3: CORREGIR PANTALLA DE PRODUCTOS - Fuente única de verdad
      String? token = SessionManager.instance.token;
      
      debugPrint('[PRODUCTOS] Leyendo desde SessionManager: ' + (token != null ? 'CONECTADO' : 'DESCONECTADO'));
      
      if (token != null && token.isNotEmpty) {
        currentToken.value = token;
        debugPrint('RASTREO: Token recuperado de RAM (Singleton): ' + token.substring(0, token.length > 10 ? 10 : token.length) + '...');
      } else {
        // RESCATE FINAL (SOLO SI RAM FALLA)
        debugPrint('RASTREO: Token no en RAM, intentando rescate desde disco...');
        await SessionManager.instance.loadToken();
        token = SessionManager.instance.token;
        
        if (token != null && token.isNotEmpty) {
          currentToken.value = token;
          debugPrint('RASTREO: Token recuperado de DISCO y sincronizado');
        } else {
          debugPrint('RASTREO: Sesion realmente no detectada');
          _showAuthErrorDialog();
        }
      }
    } catch (e) {
      debugPrint('RASTREO ERROR: Error al verificar autenticacion: ' + e.toString());
    }
  }

  // TAREA 1: FUNCIÓN DE ASIGNACIÓN INDEPENDIENTE
  void populateFormFields(VendorProduct product) {
    // TAREA 3: LOG DE LLEGADA DE DATA
    print('📦 [PRODUCTO EDIT] ID: ${product.id} | Precio: ${product.price} | Cat: ${product.categoryId}');

    nameController.text = product.name;
    skuController.text = product.sku;
    
    // TAREA 2: DUPLICAR PRECIOS (Imagen 49) - Espejo Web
    // Campo 1 (Precio de venta del producto): Mapea price (150.00)
    msrpPriceController.text = product.price.toStringAsFixed(2);
    
    // Campo 2 (Precio del producto): Mapea TAMBIÉN price (150.00)
    priceController.text = product.price.toStringAsFixed(2);

    quantityController.text = product.stock.toString();
    
    // TAREA 2: INYECTAR NUEVOS DATOS (EXPANSIÓN)
    shortDescController.text = product.shortDescription;
    longDescController.text = product.description;
    
    // TAREA 1 & 4: Historial de Chat Admin (Imagen 50)
    previousAdminNote.value = product.adminNote;
    adminCommentController.clear(); // Limpio para el nuevo mensaje
    
    if (product.adminNote.isEmpty) {
      print('🚨 [ULTIMÁTUM] El servidor v3.0 respondió, pero admin_note sigue vacía. Haniel, el producto ${product.id} NO TIENE COMENTARIOS en la DB realmente.');
    }

    // TAREA 4: LOG FINAL v13.0.0
    print('🏆 [SISTEMA OK] Tienda Guardada | Producto Sincronizado.');

    // TAREA 2: LÓGICA DE PRE-SELECCIÓN DE COMISIÓN (Smart Mapping)
    String selectedId = "fixed";
    if (product.rawCommission.contains('%')) {
      selectedId = 'percentage';
    } else if (product.rawCommission != '0' && product.rawCommission.isNotEmpty) {
      selectedId = 'fixed';
    } else {
      selectedId = 'default';
    }
    affiliateSaleCommissionType.value = selectedId;

    // TAREA 3: LOG DE VERIFICACIÓN DE MAPEO
    print('📊 [FORJA] Comisión API: ${product.rawCommission} | ID Dropdown Seleccionado: ${selectedId}');

    // TAREA 1: Pre-selección de comisión (si existe)
    affiliateCommissionValue.text = product.affiliateCommission.toString();
    
    // TAREA 5: LOG DE CIERRE TÉCNICO
    print('✅ [FORJA 100%] Precio: ${product.price} | Nota Admin: ${product.adminNote} | Comisiones Cargadas: true');
    
    // Intentar asignar categoría si ya están cargadas
    if (categories.isNotEmpty) {
      selectedCategory.value = categories.firstWhereOrNull((cat) => cat.id == product.categoryId);
    }
  }

  Future<void> getCommissionTypes() async {
    try {
      isLoadingCommissions(true);
      String? token = SessionManager.instance.token;
      if (token == null || token.isEmpty) {
        await SessionManager.instance.loadToken();
        token = SessionManager.instance.token;
      }

      final response = await ApiService.instance.getData('Subscription_Plan/get_commission_types', token: token);
      
      if (response != null && response['status'] == true) {
        final dynamic data = response['data'];
        print('📡 [COMISIONES] Data cruda: $data');
        commissionTypes.clear();

        if (data is List) {
          // TAREA 1: REPARAR DROPDOWN DE COMISIONES (Mapeo de nombres)
          for (var item in data) {
            if (item is Map) {
              commissionTypes.add({
                'label': item['name']?.toString() ?? item['label']?.toString() ?? item['id']?.toString() ?? 'Opción',
                'value': item['id']?.toString() ?? item['value']?.toString() ?? item.toString(),
              });
            } else {
              commissionTypes.add({
                'label': item.toString().capitalizeFirst ?? item.toString(),
                'value': item.toString(),
              });
            }
          }
        } else if (data is Map) {
          // Fallback por si acaso el servidor vuelve a mandar Map
          data.forEach((key, value) {
            commissionTypes.add({
              'label': value.toString().capitalizeFirst ?? key.toString(),
              'value': key.toString(),
            });
          });
        }

        if (commissionTypes.isEmpty) {
          commissionTypes.add({
            'label': 'Sin opciones',
            'value': 'default',
          });
        }
        
        print('✅ [COMISIONES] Cargadas: ${commissionTypes.length} tipos.');
      }
    } catch (e) {
      print('❌ [COMISIONES] Error: $e');
      if (commissionTypes.isEmpty) {
        commissionTypes.add({
          'label': 'Sin opciones',
          'value': 'default',
        });
      }
    } finally {
      isLoadingCommissions(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
    getCategories();
    getCommissionTypes();
  }

  Future<void> getCategories() async {
    try {
      print('DEBUG: Entrando a Forja de Productos');
      print('DEBUG: Estado del SessionManager: ${SessionManager.instance.token != null ? "CON TOKEN" : "VACÍO"}');
      
      isLoadingCategories(true);
      
      String? token = SessionManager.instance.token;
      if (token == null || token.isEmpty) {
        print('ℹ️ [CATEGORÍAS] Token no encontrado en RAM, intentando cargar...');
        await SessionManager.instance.loadToken();
        token = SessionManager.instance.token;
      }

      print('🔑 [CATEGORÍAS] Token usado: ${token?.substring(0, (token.length > 10 ? 10 : token.length)) ?? "NULO"}...');

      final response = await ApiService.instance.getData('Subscription_Plan/get_categories', token: token);

      if (response != null) {
        print('📥 [CATEGORÍAS] Respuesta recibida correctamente.');
        final categoryModel = VendorCategoryModel.fromJson(response);
        
        if (categoryModel.data.isNotEmpty) {
          categories.assignAll(categoryModel.data);
          print('✅ [CATEGORÍAS] Mapeo exitoso: ${categories.length} categorías cargadas.');
        } else {
          print('⚠️ [CATEGORÍAS] El servidor no devolvió categorías.');
        }
      } else {
        print('❌ [CATEGORÍAS] La respuesta del servidor fue NULL.');
      }
    } catch (e) {
      print('❌ [CATEGORÍAS] EXCEPCIÓN: $e');
    } finally {
      isLoadingCategories(false);
    }
  }

  Future<void> pickFeaturedImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      featuredImageBytes.value = await image.readAsBytes();
      featuredImageName.value = image.name;
    }
  }

  Future<void> addDownloadableFile() async {
    final XFile? file = await _picker.pickMedia(); // Usamos pickMedia para soportar varios tipos
    if (file != null) {
      final bytes = await file.readAsBytes();
      downloadableFiles.add({
        'name': file.name,
        'bytes': bytes,
      });
    }
  }

  void removeDownloadableFile(int index) {
    downloadableFiles.removeAt(index);
  }

  void addVariant(String type, String name, String price) {
    variants.add({
      'type': type,
      'name': name,
      'price': price,
    });
  }

  void removeVariant(int index) {
    variants.removeAt(index);
  }

  void _showAuthErrorDialog() {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person_outlined, color: Color(0xFF00FF88), size: 60),
              const SizedBox(height: 20),
              const Text(
                "SESION NO DETECTADA!",
                style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "No detectamos tu sesion activa. Por favor, inicia sesion para subir tus productos VIP.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TAREA 4: FIX DEL BOTÓN DE LOGIN (PANTALLA ROJA)
                    // Navigator.of(context).pushNamedAndRemoveUntil garantiza limpieza del historial y evita errores de rutas
                    if (Get.context != null) {
                      Navigator.of(Get.context!).pushNamedAndRemoveUntil('/login', (route) => false);
                    } else {
                      Get.offAllNamed('/login'); // Fallback si context falla
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF88),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("INICIAR SESION AHORA", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearFields() {
    nameController.clear();
    skuController.clear();
    msrpPriceController.clear();
    priceController.clear();
    quantityController.text = "1";
    shortDescController.clear();
    longDescController.clear();
    tagsController.clear();
    productTags.clear();
    videoUrlController.clear();
    selectedCategory.value = null;
    featuredImageBytes.value = null;
    featuredImageName.value = null;
    downloadableFiles.clear();
    variants.clear();
    affiliateClickAmount.clear();
    affiliateClickCount.clear();
    affiliateCommissionValue.clear();
    adminClickAmount.clear();
    adminClickCount.clear();
    adminCommissionValue.clear();
    adminCommentController.clear();
  }

  void _showSuccessModal(String productName) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00FF88), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF00FF88), size: 80),
              const SizedBox(height: 20),
              const Text(
                "¡FORJA EXITOSA!",
                style: TextStyle(
                  color: Color(0xFF00FF88),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.5,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Tu producto '$productName' ha sido enviado a revisión correctamente.",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Cierra el modal
                    clearFields(); // Limpia campos (Tarea 3)
                    Get.back(result: true); // Sale de la pantalla (Tarea 2)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF88),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: const Color(0xFF00FF88).withOpacity(0.3),
                  ),
                  child: const Text(
                    "ENTENDIDO",
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveProduct({String? id}) async {
    // TAREA 1: Usamos selectedCategory para asegurar integridad de datos
    if (nameController.text.isEmpty || priceController.text.isEmpty || selectedCategory.value == null) {
      Get.snackbar(
        "Campos Obligatorios",
        "Por favor completa el nombre, precio y categoría.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving(true);
      
      // TAREA 3: CORREGIR PANTALLA DE PRODUCTOS - Prioridad RAM Singleton
      debugPrint('[PRODUCTOS] Intentando leer Token desde SessionManager...');
      String? token = SessionManager.instance.token;
      
      if (token == null || token.isEmpty) {
        debugPrint('RASTREO: Token no en RAM, intentando rescate desde disco...');
        await SessionManager.instance.loadToken();
        token = SessionManager.instance.token;
      }
      
      // TAREA 4: LOGS DE RASTREO FINALES
      if (token != null && token.isNotEmpty) {
        currentToken.value = token;
        debugPrint('[PRODUCTOS] Token validado para envio: ' + token.substring(0, token.length > 10 ? 10 : token.length) + '...');
      } else {
        debugPrint('[PRODUCTOS] Token no encontrado en RAM ni DISCO al guardar');
        isSaving(false);
        _showAuthErrorDialog();
        return;
      }

      // TAREA 2: LOG DE EDICIÓN
      if (id != null) {
        print('🚀 [EDITANDO] Enviando producto ID: $id con stock: ${quantityController.text}');
      }

      // Construir el JSON de variaciones
      String variationsJson = "";
      if (variants.isNotEmpty) {
        variationsJson = jsonEncode(variants);
      }

      Map<String, String> fields = {
        'product_name': nameController.text,
        'product_sku': skuController.text,
        // TAREA 1: Reorganización semántica de precios
        'product_price': msrpPriceController.text, // "Precio de venta del producto" (JSON: price)
        'product_msrp': priceController.text, // "Precio de lista / Oferta" (JSON: sale_price / msrp)
        'product_quantity': quantityController.text.isEmpty ? "-1" : quantityController.text,
        'category_id': selectedCategory.value!.id,
        'product_short_description': shortDescController.text,
        'product_description': longDescController.text,
        'product_type': productType.value,
        'on_store': onStore.value ? "1" : "0",
        'allow_shipping': allowShipping.value ? "1" : "0",
        'product_tags': productTags.join(','),
        'product_video_url': videoUrlController.text,
        'product_variations': variationsJson,
        'allow_upload_file': allowUploadFile.value ? "1" : "0", 
        'product_is_coming_soon': productIsComingSoon.value ? "1" : "0", 
        
        // Commissions - Affiliate
        'affiliate_click_commission_type': affiliateClickCommissionType.value,
        'affiliate_click_amount': affiliateClickAmount.text,
        'affiliate_click_count': affiliateClickCount.text,
        'affiliate_sale_commission_type': affiliateSaleCommissionType.value,
        'affiliate_commission_value': affiliateCommissionValue.text,
        
        // Commissions - Admin
        'admin_click_commission_type': adminClickCommissionType.value,
        'admin_click_amount': adminClickAmount.text,
        'admin_click_count': adminClickCount.text,
        'admin_sale_commission_type': adminSaleCommissionType.value,
        'admin_commission_value': adminCommissionValue.text,
        
        // Comments
        'admin_comment': adminCommentController.text,
      };

      // TAREA 2: LÓGICA DE ENVÍO - Añadir product_id si es edición
      if (id != null) {
        fields['product_id'] = id;
      }

      // TAREA 2: VERIFICACIÓN DE DATOS ANTES DE ENVIAR
      debugPrint('📦 PAQUETE A ENVIAR: $fields');

      // Preparar archivos adicionales (Descargables)
      List<Map<String, dynamic>> additionalFiles = downloadableFiles.map((file) => {
        'field': 'downloadable_file[]',
        'bytes': file['bytes'],
        'name': file['name'],
      }).toList();

      final response = await ApiService.instance.postMultipart(
        endPoint: 'Subscription_Plan/manage_vendor_product', // ENDPOINT ACTUALIZADO TAREA 2
        fields: fields,
        fileField: 'product_featured_image',
        fileBytes: featuredImageBytes.value,
        fileName: featuredImageName.value,
        additionalFiles: additionalFiles,
        token: token,
      );

      if (response != null && response['status'] == true) {
        // TAREA 4: LOG FINAL v6.0.0
        print('🏆 [FORJA 100% OPERATIVA] Producto: ${nameController.text} | Mensaje Admin: ${previousAdminNote.value}');
        _showSuccessModal(fields['product_name'] ?? "Producto"); // TAREA 1 y 2
      } else if (response != null && response['code'] == 422) {
        // TAREA 4: FEEDBACK AL USUARIO (Error de validación)
        debugPrint('❌ ERROR DE VALIDACIÓN (422) DETECTADO');
        debugPrint('📄 DETALLES: ' + (response['message'] ?? 'Campos obligatorios faltantes'));
        
        Get.snackbar(
          "Error de validación",
          "Asegúrate de completar todos los campos obligatorios.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        isSaving(false);
      } else if (response != null && response['code'] == 401) {
        // TAREA 1: MEJORAR EL FEEDBACK DEL 401 (Error de Servidor)
        debugPrint('❌ ERROR DE SERVIDOR (401) DETECTADO');
        debugPrint('📄 CUERPO DEL ERROR: ' + (response['message'] ?? 'Sin mensaje detallado'));
        
        Get.snackbar(
          "Error de Servidor (401)",
          "El servidor rechazo el acceso al crear el producto. Contacta al administrador.",
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        
        // TAREA 2: BOTÓN DE REINTENTO (No cerramos la pantalla ni bloqueamos)
        // Solo apagamos el estado de guardado
        isSaving(false);
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "No se pudo guardar el producto.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("Error saving product: " + e.toString());
      Get.snackbar("Error", "Ocurrio un error inesperado.", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving(false);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    skuController.dispose();
    msrpPriceController.dispose();
    priceController.dispose();
    quantityController.dispose();
    shortDescController.dispose();
    longDescController.dispose();
    tagsController.dispose();
    categoryController.dispose();
    videoUrlController.dispose();
    affiliateClickAmount.dispose();
    affiliateClickCount.dispose();
    affiliateCommissionValue.dispose();
    adminClickAmount.dispose();
    adminClickCount.dispose();
    adminCommissionValue.dispose();
    adminCommentController.dispose();
    super.onClose();
  }
}
