import 'dart:convert';

PaymentResponseModel PaymentsListFromJson(String str) =>
    PaymentResponseModel.fromJson(json.decode(str));

class PaymentResponseModel {
  bool status;
  PaymentData data;

  PaymentResponseModel({
    required this.status,
    required this.data,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) =>
      PaymentResponseModel(
        status: json['status'],
        data: PaymentData.fromJson(json['data']),
      );
}

class PaymentData {
  String primaryPaymentMethod;
  Notification? notification;
  PaymentList paymentList;
  PaypalAccount paypalAccounts;
  List<String> availableCountries;

  PaymentData({
    required this.primaryPaymentMethod,
    required this.notification,
    required this.paymentList,
    required this.paypalAccounts,
    required this.availableCountries,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
    primaryPaymentMethod: json['primary_payment_method'] ?? '',
    notification: json.containsKey('notification')
        ? Notification.fromJson(json['notification'])
        : Notification(
      primaryPaymentMethod: '',
      paymentList: '',
      paypalAccounts: '',
    ),
    paymentList: PaymentList.fromJson(json['paymentlist']),
    paypalAccounts: PaypalAccount.fromJson(json['paypalaccounts']),
    availableCountries: List<String>.from(json['available_countries'] ?? []),
  );
}

class Notification {
  String? primaryPaymentMethod;
  String? paymentList;
  String? paypalAccounts;

  Notification({
    this.primaryPaymentMethod,
    this.paymentList,
    this.paypalAccounts,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    primaryPaymentMethod: json['primary_payment_method'] ?? '',
    paymentList: json['paymentlist'] ?? '',
    paypalAccounts: json['paypalaccounts'] ?? '',
  );
}

class PaymentList {
  dynamic paymentId;
  String paymentBankName;
  String paymentAccountNumber;
  String paymentAccountName;
  String paymentCountry;
  // Country-specific fields
  String? paymentRoutingNumber;     // For US
  String? paymentIfscCode;          // For IN
  String? paymentSortCode;          // For GB
  String? paymentBsbNumber;         // For AU
  String? paymentTransitInstitutionNumber; // For CA
  String? paymentIbanBic;           // For DE
  String? paymentCnapsCode;         // For CN
  String? paymentSwiftCode;         // For SG
  String? paymentClearingCode;      // For HK
  String? paymentBankBranchNumber;  // For NZ
  PaypalAccount paypalAccounts;

  PaymentList({
    required this.paymentId,
    required this.paymentBankName,
    required this.paymentAccountNumber,
    required this.paymentAccountName,
    required this.paymentCountry,
    this.paymentRoutingNumber,
    this.paymentIfscCode,
    this.paymentSortCode,
    this.paymentBsbNumber,
    this.paymentTransitInstitutionNumber,
    this.paymentIbanBic,
    this.paymentCnapsCode,
    this.paymentSwiftCode,
    this.paymentClearingCode,
    this.paymentBankBranchNumber,
    required this.paypalAccounts,
  });

  factory PaymentList.fromJson(Map<String, dynamic> json) => PaymentList(
    paymentId: json['payment_id'],
    paymentBankName: json['payment_bank_name'] ?? '',
    paymentAccountNumber: json['payment_account_number'] ?? '',
    paymentAccountName: json['payment_account_name'] ?? '',
    paymentCountry: json['payment_country'] ?? '',
    // Parse country-specific fields if they exist
    paymentRoutingNumber: json['payment_routing_number'],
    paymentIfscCode: json['payment_ifsc_code'],
    paymentSortCode: json['payment_sort_code'],
    paymentBsbNumber: json['payment_bsb_number'],
    paymentTransitInstitutionNumber: json['payment_transit_institution_number'],
    paymentIbanBic: json['payment_iban_bic'],
    paymentCnapsCode: json['payment_cnaps_code'],
    paymentSwiftCode: json['payment_swift_code'],
    paymentClearingCode: json['payment_clearing_code'],
    paymentBankBranchNumber: json['payment_bank_branch_number'],
    paypalAccounts: PaypalAccount.fromJson(json['paypalaccounts']),
  );
}

class PaypalAccount {
  String paypalEmail;
  dynamic id;

  PaypalAccount({
    required this.paypalEmail,
    required this.id,
  });

  factory PaypalAccount.fromJson(Map<String, dynamic> json) => PaypalAccount(
    paypalEmail: json['paypal_email'] ?? '',
    id: json['id'],
  );
}