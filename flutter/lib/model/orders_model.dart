import 'dart:convert';

OrderListModel orderListFromJson(String str) =>
    OrderListModel.fromJson(json.decode(str));
class OrderListModel {
  bool status;
  String message;
  OrderListData data;

  OrderListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderListModel.fromJson(Map<String, dynamic> json) => OrderListModel(
        status: json['status'],
        message: json['message'],
        data: OrderListData.fromJson(json['data']),
      );
}

class OrderListData {
  List<Order> orders;
  int startFrom;
  List<String> walletStatus;

  OrderListData({
    required this.orders,
    required this.startFrom,
    required this.walletStatus,
  });

  factory OrderListData.fromJson(Map<String, dynamic> json) => OrderListData(
        orders: List<Order>.from(json['orders'].map((x) => Order.fromJson(x))),
        startFrom: json['start_from'],
        walletStatus: List<String>.from(json['wallet_status'] ?? []),
      );
}

class Order {
  String id;
  String? walletStatus;
  String? walletCommissionStatus;
  String type;
  String? orderId;
  String? productIds;
  String? total;
  String? currency;
  String? userId;
  String? commissionType;
  String? commission;
  String? ip;
  String? countryCode;
  String? baseUrl;
  String? adsId;
  String? scriptName;
  String? customData;
  String? createdAt;
  String? userName;
  String? orderCountryFlag;

  Order({
    required this.id,
    this.walletStatus,
    this.walletCommissionStatus,
    required this.type,
    this.orderId,
    this.productIds,
    this.total,
    this.currency,
    this.userId,
    this.commissionType,
    this.commission,
    this.ip,
    this.countryCode,
    this.baseUrl,
    this.adsId,
    this.scriptName,
    this.customData,
    this.createdAt,
    this.userName,
    this.orderCountryFlag,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id']??'N/A',
        walletStatus: json['wallet_status']??'N/A',
        walletCommissionStatus: json['wallet_commission_status'],
        type: json['type']??'N/A',
        orderId: json['order_id']??'N/A',
        productIds: json['product_ids']??'N/A',
        total: json['total']??'N/A',
        currency: json['currency']??'N/A',
        userId: json['user_id']??'N/A',
        commissionType: json['commission_type']??'Cash On Delivery',
        commission: json['commission']??'N/A',
        ip: json['ip']??'N/A',
        countryCode: json['country_code']??'N/A',
        baseUrl: json['base_url']??'N/A',
        adsId: json['ads_id']??'N/A',
        scriptName: json['script_name']??'N/A',
        customData: json['custom_data']??'N/A',
        createdAt: json['created_at']??'N/A',
        userName: json['user_name']??'N/A',
        orderCountryFlag: json['order_country_flag']??'N/A',
      );
}
