import 'dart:convert';

PaymentsListModel PaymentsListFromJson(String str) =>
    PaymentsListModel.fromJson(json.decode(str));

class PaymentsListModel {
  bool status;
  String message;
  List<PaymentsData> data;

  PaymentsListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PaymentsListModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = (raw is List) ? raw : const [];
    return PaymentsListModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: List<PaymentsData>.from(
        list.map((x) => PaymentsData.fromJson((x as Map<String, dynamic>))),
      ),
    );
  }
}

class PaymentsData {
  String module;
  String id;
  String userId;
  String username;
  String price;
  String paymentGateway;
  String paymentDetail;
  String statusId;
  String datetime;

  PaymentsData({
    required this.module,
    required this.id,
    required this.userId,
    required this.username,
    required this.price,
    required this.paymentGateway,
    required this.paymentDetail,
    required this.statusId,
    required this.datetime,
  });

  factory PaymentsData.fromJson(Map<String, dynamic> json) =>
      PaymentsData(
        module: json['module']?.toString() ?? '',
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        price: json['price']?.toString() ?? '',
        paymentGateway: json['payment_gateway']?.toString() ?? '',
        paymentDetail: json['payment_detail']?.toString() ?? '',
        statusId: json['status_id']?.toString() ?? '',
        datetime: json['datetime']?.toString() ?? '',
      );
}
