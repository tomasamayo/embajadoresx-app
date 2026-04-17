import 'dart:convert';
import '../service/api_service.dart';

LogListModel logListFromJson(String str) =>
    LogListModel.fromJson(json.decode(str));

class LogListModel {
  bool status;
  String message;
  LogListData data;

  LogListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LogListModel.fromJson(Map<String, dynamic> json) => LogListModel(
    status: json['status'] ?? false,
    message: json['message'] ?? '',
    data: LogListData.fromJson(json['data'] ?? {}),
  );
}

class LogListData {
  List<Click> clicks;
  int startFrom;
  String affiliateStoreUrl;
  String uniqueResellerLink;
  // TAREA 1: LAS 4 VARIABLES DEL JSON (v1.9.0)
  String urlTienda;
  String compartirTienda;
  String invitarProveedores;
  String invitarAfiliados;

  LogListData({
    required this.clicks,
    required this.startFrom,
    required this.affiliateStoreUrl,
    required this.uniqueResellerLink,
    required this.urlTienda,
    required this.compartirTienda,
    required this.invitarProveedores,
    required this.invitarAfiliados,
  });

  factory LogListData.fromJson(Map<String, dynamic> json) => LogListData(
    clicks: List<Click>.from(
        json['clicks']?.map((x) => Click.fromJson(x)) ?? []),
    startFrom: json['start_from'] ?? 0,
    affiliateStoreUrl: json['affiliate_store_url'] ?? '',
    uniqueResellerLink: json['unique_reseller_link'] ?? '',
    // Mapeo dinámico desde el JSON (v1.9.0)
    urlTienda: json['url_tienda'] ?? json['affiliate_store_url'] ?? '',
    compartirTienda: json['compartir_tienda'] ?? '',
    invitarProveedores: json['invitar_proveedores'] ?? '',
    invitarAfiliados: json['invitar_afiliados'] ?? json['unique_reseller_link'] ?? '',
  );
}

class Click {
  String type;
  String id;
  String baseUrl;
  String link;
  String agent;
  String browserName;
  String browserVersion;
  String systemString;
  String osPlatform;
  String osVersion;
  String osShortVersion;
  String isMobile;
  String mobileName;
  String osArch;
  String isIntel;
  String isAMD;
  String isPPC;
  String ip;
  String countryCode;
  String createdAt;
  String clickId;
  String username;
  String clickType;
  String flag;
  List<CustomData> customData;

  Click({
    required this.type,
    required this.id,
    required this.baseUrl,
    required this.link,
    required this.agent,
    required this.browserName,
    required this.browserVersion,
    required this.systemString,
    required this.osPlatform,
    required this.osVersion,
    required this.osShortVersion,
    required this.isMobile,
    required this.mobileName,
    required this.osArch,
    required this.isIntel,
    required this.isAMD,
    required this.isPPC,
    required this.ip,
    required this.countryCode,
    required this.createdAt,
    required this.clickId,
    required this.username,
    required this.clickType,
    required this.flag,
    required this.customData,
  });

  factory Click.fromJson(Map<String, dynamic> json) => Click(
    type: json['type'] ?? '',
    id: json['id'] ?? '',
    baseUrl: json['base_url'] ?? ('${ApiService.instance.baseUrl}register/Mg=='),
    link: json['link'] ?? '',
    agent: json['agent'] ?? '',
    browserName: json['browserName'] ?? '',
    browserVersion: json['browserVersion'] ?? '',
    systemString: json['systemString'] ?? '',
    osPlatform: json['osPlatform'] ?? '',
    osVersion: json['osVersion'] ?? '',
    osShortVersion: json['osShortVersion'] ?? '',
    isMobile: json['isMobile'] ?? '',
    mobileName: json['mobileName'] ?? '',
    osArch: json['osArch'] ?? '',
    isIntel: json['isIntel'] ?? '',
    isAMD: json['isAMD'] ?? '',
    isPPC: json['isPPC'] ?? '',
    ip: json['ip'] ?? '',
    countryCode: json['country_code'] ?? '',
    createdAt: json['created_at'] ?? '',
    clickId: json['click_id'] ?? '',
    username: json['username'] ?? '',
    clickType: json['click_type'] ?? 'Store Order',
    flag: json['flag'] ?? '',
    customData: List<CustomData>.from(
        json['custom_data']?.map((x) => CustomData.fromJson(x)) ?? []),
  );
}

class CustomData {
  String key;
  String value;

  CustomData({
    required this.key,
    required this.value,
  });

  factory CustomData.fromJson(Map<String, dynamic> json) => CustomData(
    key: json['key'] ?? '',
    value: json['value'] ?? '',
  );
}
