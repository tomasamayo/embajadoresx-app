import 'dart:convert';

VendorStoreSettingsModel vendorStoreSettingsModelFromJson(String str) => VendorStoreSettingsModel.fromJson(json.decode(str));

class VendorStoreSettingsModel {
  final bool status;
  final String message;
  final VendorStoreSettings? data;

  VendorStoreSettingsModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory VendorStoreSettingsModel.fromJson(Map<String, dynamic> json) => VendorStoreSettingsModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null ? null : VendorStoreSettings.fromJson(json["data"]),
      );
}

class VendorStoreSettings {
  final String shopName;
  final String storeEmail;
  final String storeContact;
  final String storeAddress;
  final String storeCity;
  final String storeCountry;
  final String clickCommission;
  final String saleCommission;
  final String affiliateClickAmount;
  final String affiliateSaleCommissionType;
  final String affiliateCommissionValue;
  final String vendorStatus; // 0: Todos, 1: Ninguno, 2: Solo mis afiliados
  final String storeSlug; // TAREA 2: Agregar slug
  
  // Diseño e Identidad Visual (Llaves Oficiales)
  final String shopLogo;
  final String shopBanner;
  final String shopColor;
  final String shopAbout; // Nuestra Historia
  final String shopMap;
  final String shopTerms;
  final String showNameOnCover; // 0: No, 1: Sí

  VendorStoreSettings({
    required this.shopName,
    required this.storeEmail,
    required this.storeContact,
    required this.storeAddress,
    required this.storeCity,
    required this.storeCountry,
    required this.clickCommission,
    required this.saleCommission,
    required this.affiliateClickAmount,
    required this.affiliateSaleCommissionType,
    required this.affiliateCommissionValue,
    required this.vendorStatus,
    required this.storeSlug,
    required this.shopLogo,
    required this.shopBanner,
    required this.shopColor,
    required this.shopAbout,
    required this.shopMap,
    required this.shopTerms,
    required this.showNameOnCover,
  });

  factory VendorStoreSettings.fromJson(Map<String, dynamic> json) {
    // TAREA 1: SINCRONIZAR NOMBRES DE LECTURA (shop_name)
    return VendorStoreSettings(
      shopName: json["shop_name"]?.toString() ?? json["store_name"]?.toString() ?? "",
      storeEmail: json["store_email"]?.toString() ?? "",
      storeContact: json["store_contact"]?.toString() ?? "",
      storeAddress: json["store_address"]?.toString() ?? "",
      storeCity: json["store_city"]?.toString() ?? "",
      storeCountry: json["store_country"]?.toString() ?? "",
      clickCommission: json["affiliate_click_count"]?.toString() ?? json["global_click_commission"]?.toString() ?? "0",
      saleCommission: json["global_sale_commission"]?.toString() ?? "0",
      affiliateClickAmount: json["affiliate_click_amount"]?.toString() ?? "0",
      affiliateSaleCommissionType: json["affiliate_sale_commission_type"]?.toString() ?? "percentage",
      affiliateCommissionValue: json["affiliate_commission_value"]?.toString() ?? "0",
      vendorStatus: json["vendor_status"]?.toString() ?? "0",
      storeSlug: json["store_slug"]?.toString() ?? "",
      shopLogo: json["shop_logo"]?.toString() ?? "",
      shopBanner: json["shop_banner"]?.toString() ?? "",
      shopColor: json["shop_color"]?.toString() ?? "#00FF88",
      shopAbout: json["shop_about"]?.toString() ?? "",
      shopMap: json["shop_map"]?.toString() ?? "",
      shopTerms: json["shop_terms"]?.toString() ?? "",
      showNameOnCover: json["show_name_on_cover"]?.toString() ?? "0",
    );
  }
}
