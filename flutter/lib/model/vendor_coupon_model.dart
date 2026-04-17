import 'dart:convert';

VendorCouponModel vendorCouponModelFromJson(String str) => VendorCouponModel.fromJson(json.decode(str));

class VendorCouponModel {
  bool status;
  String message;
  List<VendorCoupon> data;

  VendorCouponModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VendorCouponModel.fromJson(Map<String, dynamic> json) => VendorCouponModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null ? [] : List<VendorCoupon>.from(json["data"].map((x) => VendorCoupon.fromJson(x))),
      );
}

class VendorCoupon {
  String id;
  String name;
  String code;
  String type;
  String discount;
  String dateStart;
  String dateEnd;
  String usesTotal;
  String status;
  String createdAt;
  String allowFor;

  VendorCoupon({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.discount,
    required this.dateStart,
    required this.dateEnd,
    required this.usesTotal,
    required this.status,
    required this.createdAt,
    required this.allowFor,
  });

  factory VendorCoupon.fromJson(Map<String, dynamic> json) {
    // TAREA 3: LOG DE CONFIRMACIÓN DE LLAVE
    print('🎯 [LLAVE ENCONTRADA] Asignando coupon_id: ${json['coupon_id']} al campo id del modelo');
    
    return VendorCoupon(
      id: json["coupon_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      code: json["code"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      discount: json["discount"]?.toString() ?? "",
      dateStart: json["date_start"]?.toString() ?? "",
      dateEnd: json["date_end"]?.toString() ?? "",
      usesTotal: json["uses_total"]?.toString() ?? "0",
      status: json["status"]?.toString() ?? "0",
      createdAt: json["created_at"]?.toString() ?? "",
      allowFor: json["allow_for"]?.toString() ?? "s",
    );
  }
}
