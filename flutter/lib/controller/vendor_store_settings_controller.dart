import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../model/vendor_store_settings_model.dart';
import '../service/api_service.dart';
import '../utils/session_manager.dart';

class VendorStoreSettingsController extends GetxController {
  final SharedPreferences preferences;
  VendorStoreSettingsController({required this.preferences});

  var isLoading = false.obs;
  var isSaving = false.obs;
  var settings = Rxn<VendorStoreSettings>();

  // Controllers Pestaña [TIENDA]
  final shopNameController = TextEditingController();
  final shopAboutController = TextEditingController(); // Nuestra Historia
  final shopColorController = TextEditingController();
  final shopMapController = TextEditingController();
  final shopTermsController = TextEditingController();
  var showNameOnCover = "0".obs; // 0: No, 1: Sí

  // Controllers Pestaña [PROVEEDOR]
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final clickCommController = TextEditingController();
  final saleCommController = TextEditingController();
  final affiliateClickAmountController = TextEditingController();
  final affiliateCommissionValueController = TextEditingController();
  var affiliateSaleCommissionType = 'percentage'.obs;
  var vendorStatus = "0".obs; // 0: Todos, 1: Ninguno, 2: Solo mis afiliados

  // TAREA 4: LÓGICA DE IMÁGENES (MULTIPART)
  final ImagePicker _picker = ImagePicker();
  var shopLogoBytes = Rxn<Uint8List>();
  var shopBannerBytes = Rxn<Uint8List>();
  var shopLogoName = "".obs;
  var shopBannerName = "".obs;

  @override
  void onInit() {
    super.onInit();
    getSettings();
  }

  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      shopLogoBytes.value = await image.readAsBytes();
      shopLogoName.value = image.name;
    }
  }

  Future<void> pickBanner() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      shopBannerBytes.value = await image.readAsBytes();
      shopBannerName.value = image.name;
    }
  }

  Future<void> getSettings() async {
    try {
      isLoading(true);
      final token = SessionManager.instance.token;
      final response = await ApiService.instance.getData('Subscription_Plan/get_vendor_store_settings', token: token);

      if (response != null) {
        // TAREA 4: ACTIVACIÓN DE LOGS TOTALES
        print('📡 [API GET SETTINGS] Respuesta: $response');

        final model = VendorStoreSettingsModel.fromJson(response);
        if (model.data != null) {
          settings.value = model.data;
          
          // TAREA 2: LOG DE ÉXITO FINAL
          print('🏆 [AJUSTES SINCRONIZADOS] Tienda: ${model.data!.shopName} | Slug: ${model.data!.storeSlug}');

          // Pestaña [TIENDA]
          shopNameController.text = model.data!.shopName;
          shopAboutController.text = model.data!.shopAbout;
          shopColorController.text = model.data!.shopColor;
          shopMapController.text = model.data!.shopMap;
          shopTermsController.text = model.data!.shopTerms;
          showNameOnCover.value = model.data!.showNameOnCover;

          // Pestaña [PROVEEDOR]
          emailController.text = model.data!.storeEmail;
          contactController.text = model.data!.storeContact;
          addressController.text = model.data!.storeAddress;
          clickCommController.text = model.data!.clickCommission;
          saleCommController.text = model.data!.saleCommission;
          affiliateClickAmountController.text = model.data!.affiliateClickAmount;
          affiliateSaleCommissionType.value = model.data!.affiliateSaleCommissionType;
          affiliateCommissionValueController.text = model.data!.affiliateCommissionValue;
          vendorStatus.value = model.data!.vendorStatus;
        }
      }
    } catch (e) {
      debugPrint("Error fetching store settings: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateSettings() async {
    try {
      isSaving(true);
      final token = SessionManager.instance.token;
      
      // TAREA 1: VINCULACIÓN TOTAL DE AJUSTES (Diccionario Exacto para tabla Users)
      Map<String, String> fields = {
        // TIENDA
        'shop_name': shopNameController.text,
        'shop_about': shopAboutController.text.trim(),
        'shop_color': shopColorController.text,
        'show_name_on_cover': showNameOnCover.value,
        'shop_terms': shopTermsController.text,
        'shop_map': shopMapController.text,

        // COMISIONES
        'affiliate_click_count': clickCommController.text.trim().isEmpty ? "0" : clickCommController.text.trim(),
        'affiliate_click_amount': affiliateClickAmountController.text.trim().isEmpty ? "0" : affiliateClickAmountController.text.trim(),
        'affiliate_commission_value': affiliateCommissionValueController.text.trim().isEmpty ? "0" : affiliateCommissionValueController.text.trim(),
        'affiliate_sale_commission_type': affiliateSaleCommissionType.value,

        // ESTADO
        'vendor_status': vendorStatus.value,
      };

      // REGLA DE ENVÍO: Garantizar Strings vacíos, nunca nulos
      fields.forEach((key, value) {
        if (value == null) fields[key] = "";
      });

      List<Map<String, dynamic>> additionalFiles = [];
      
      if (shopBannerBytes.value != null) {
        additionalFiles.add({
          'field': 'shop_banner',
          'bytes': shopBannerBytes.value,
          'name': shopBannerName.value,
        });
      }

      final response = await ApiService.instance.postMultipart(
        endPoint: 'Subscription_Plan/update_store_settings', // URL CORTA
        fields: fields,
        fileField: shopLogoBytes.value != null ? 'shop_logo' : '',
        fileBytes: shopLogoBytes.value,
        fileName: shopLogoName.value,
        additionalFiles: additionalFiles,
        token: token,
      );

      // TAREA 3: MANEJO DE ÉXITO O ERROR
      if (response == null) {
        print('❌ [SERVER ERROR] La respuesta fue NULL.');
        Get.snackbar("Error", "El servidor no respondió. Intenta de nuevo.", backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      if (response['status'] == true || response['status'] == 'success') {
        Get.snackbar(
          "Éxito", 
          "✅ ¡Configuración de tienda sincronizada al 100%!", 
          backgroundColor: Colors.green, 
          colorText: Colors.white
        );
        shopLogoBytes.value = null;
        shopBannerBytes.value = null;
        getSettings();
      } else {
        Get.snackbar(
          "Atención", 
          response['message'] ?? "No se pudieron aplicar los cambios.", 
          backgroundColor: Colors.orangeAccent, 
          colorText: Colors.white
        );
      }
    } catch (e) {
      debugPrint("Error updating store settings: $e");
    } finally {
      isSaving(false);
    }
  }

  @override
  void onClose() {
    shopNameController.dispose();
    shopAboutController.dispose();
    shopColorController.dispose();
    shopMapController.dispose();
    shopTermsController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    clickCommController.dispose();
    saleCommController.dispose();
    affiliateClickAmountController.dispose();
    affiliateCommissionValueController.dispose();
    super.onClose();
  }
}
