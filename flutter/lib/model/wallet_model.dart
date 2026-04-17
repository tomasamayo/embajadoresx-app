import 'dart:convert';

WalletModel walletFromJson(String str) =>
    WalletModel.fromJson(json.decode(str));

class WalletModel {
  WalletModel({
    required this.status,
    required this.message,
    required this.data,
  });

  bool status;
  String message;
  Data data;

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: Data.fromJson(json["data"]),
      );
}

class Data {
  Data({
    required this.userTotals,
    required this.transaction,
    required this.walletUnpaidAmount,
  });

  dynamic walletUnpaidAmount;
  UserTotals userTotals;
  List<Transaction> transaction;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        walletUnpaidAmount: json["wallet_unpaid_amount"] ?? 0,
        userTotals: UserTotals.fromJson(json["user_totals"]),
        transaction: List<Transaction>.from(
            json["transaction"].map((x) => Transaction.fromJson(x))),
      );
}

class Transaction {
  Transaction(
      {required this.id,
      required this.userId,
      required this.fromUserId,
      required this.amount,
      required this.comment,
      required this.type,
      required this.disType,
      required this.status,
      required this.commissionStatus,
      required this.referenceId,
      required this.referenceId2,
      required this.commFrom,
      required this.domainName,
      required this.pageName,
      required this.isAction,
      required this.parentId,
      required this.groupId,
      required this.isVendor,
      required this.wv,
      required this.createdAt,
      required this.username,
      required this.firstname,
      required this.lastname,
      required this.walletRecursionId,
      required this.walletRecursionStatus,
      required this.walletRecursionType,
      required this.walletRecursionCustomTime,
      required this.walletRecursionNextTransaction,
      required this.walletRecursionEndtime,
      required this.paymentMethod,
      required this.integrationOrdersTotal,
      required this.localOrdersTotal,
      required this.totalRecurring,
      required this.totalRecurringAmount});

  String id;
  String userId;
  dynamic fromUserId;
  String amount;
  String comment;
  String type;
  dynamic disType;
  String status;
  String commissionStatus;
  String referenceId;
  dynamic referenceId2;
  String commFrom;
  dynamic domainName;
  dynamic pageName;
  String isAction;
  String parentId;
  String groupId;
  String isVendor;
  dynamic wv;
  String createdAt;
  String username;
  String firstname;
  String lastname;
  dynamic walletRecursionId;
  dynamic walletRecursionStatus;
  dynamic walletRecursionType;
  dynamic walletRecursionCustomTime;
  dynamic walletRecursionNextTransaction;
  dynamic walletRecursionEndtime;
  dynamic paymentMethod;
  dynamic integrationOrdersTotal;
  dynamic localOrdersTotal;
  String totalRecurring;
  dynamic totalRecurringAmount;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        userId: json['user_id'],
        fromUserId: json['from_user_id'],
        amount: json['amount'],
        comment: json['comment'],
        type: json['type'],
        disType: json['dis_type'],
        status: json['status'],
        commissionStatus: json['commission_status'],
        referenceId: json['reference_id'],
        referenceId2: json['reference_id_2'],
        commFrom: json['comm_from'],
        domainName: json['domain_name'],
        pageName: json['page_name'],
        isAction: json['is_action'],
        parentId: json['parent_id'],
        groupId: json['group_id'],
        isVendor: json['is_vendor'],
        wv: json['wv'],
        createdAt: json['created_at'],
        username: json['username'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        walletRecursionId: json['wallet_recursion_id'],
        walletRecursionStatus: json['wallet_recursion_status'],
        walletRecursionType: json['wallet_recursion_type'],
        walletRecursionCustomTime: json['wallet_recursion_custom_time'],
        walletRecursionNextTransaction:
            json['wallet_recursion_next_transaction'],
        walletRecursionEndtime: json['wallet_recursion_endtime'],
        paymentMethod: json['payment_method'],
        integrationOrdersTotal: json['integration_orders_total'],
        localOrdersTotal: json['local_orders_total'],
        totalRecurring: json['total_recurring'],
        totalRecurringAmount: json['total_recurring_amount'],
      );

  String get displayTitle {
    String title = "";
    if (comment.isNotEmpty) {
      title = comment;
    } else {
      title = type.replaceAll('_', ' ');
      if (title.isNotEmpty) {
        title = title[0].toUpperCase() + title.substring(1);
      }
    }

    if (title.length > 35) {
      return "${title.substring(0, 32)}...";
    }
    return title;
  }

  String get displayAmount {
    double parsedAmount = double.tryParse(amount) ?? 0.0;

    if (parsedAmount == 0) {
      final regExp = RegExp(r'(\d+)');
      final match = regExp.firstMatch(comment);
      if (match != null) {
        String extracted = match.group(1)!;
        return "+$extracted ExCoins";
      }
      return "0.00";
    }

    if (comment.toLowerCase().contains("canje") ||
        type.toLowerCase().contains("canje")) {
      return "$amount ExCoins";
    }

    return "+\$$amount";
  }

  bool get isIncome {
    // If it's a negative number in amount string
    if (amount.startsWith('-')) return false;
    
    String search = (comment + type).toLowerCase();
    if (search.contains('retiro') || 
        search.contains('withdraw') || 
        search.contains('pago realizado') ||
        search.contains('debited')) {
      return false;
    }
    
    return true;
  }

  String get statusText {
    if (status == "1" || commissionStatus == "1") return "COMPLETADO";
    if (status == "2" || commissionStatus == "2") return "RECHAZADO";
    return "EN ESPERA";
  }

  bool get isStatusCompleted => status == "1" || commissionStatus == "1";
  bool get isStatusRejected => status == "2" || commissionStatus == "2";
}

class UserTotals {
  UserTotals({
    required this.clickLocalstoreTotal,
    required this.clickLocalstoreCommission,
    required this.saleLocalstoreTotal,
    required this.saleLocalstoreCommission,
    required this.saleLocalstoreCount,
    required this.clickExternalTotal,
    required this.clickExternalCommission,
    required this.orderExternalTotal,
    required this.orderExternalCount,
    required this.orderExternalCommission,
    required this.clickActionTotal,
    required this.clickActionCommission,
    required this.vendorClickLocalstoreTotal,
    required this.vendorClickLocalstoreCommissionPay,
    required this.vendorSaleLocalstoreTotal,
    required this.vendorSaleLocalstoreCommissionPay,
    required this.vendorSaleLocalstoreCount,
    required this.vendorClickExternalTotal,
    required this.vendorClickExternalCommissionPay,
    required this.vendorActionExternalTotal,
    required this.vendorActionExternalCommissionPay,
    required this.vendorOrderExternalCommissionPay,
    required this.vendorOrderExternalCount,
    required this.vendorOrderExternalTotal,
    required this.clickFormTotal,
    required this.clickFormCommission,
    required this.walletUnpaidAmount,
    required this.walletUnpaidCount,
    required this.userBalance,
    required this.totalClicksCount,
    required this.totalClicksCommission,
  });

  dynamic clickLocalstoreTotal;
  dynamic clickLocalstoreCommission;
  dynamic saleLocalstoreTotal;
  dynamic saleLocalstoreCommission;
  dynamic saleLocalstoreCount;
  dynamic clickExternalTotal;
  dynamic clickExternalCommission;
  dynamic orderExternalTotal;
  String orderExternalCount;
  dynamic orderExternalCommission;
  dynamic clickActionTotal;
  dynamic clickActionCommission;
  dynamic vendorClickLocalstoreTotal;
  dynamic vendorClickLocalstoreCommissionPay;
  dynamic vendorSaleLocalstoreTotal;
  dynamic vendorSaleLocalstoreCommissionPay;
  dynamic vendorSaleLocalstoreCount;
  dynamic vendorClickExternalTotal;
  dynamic vendorClickExternalCommissionPay;
  dynamic vendorActionExternalTotal;
  dynamic vendorActionExternalCommissionPay;
  dynamic vendorOrderExternalCommissionPay;
  String vendorOrderExternalCount;
  dynamic vendorOrderExternalTotal;
  dynamic clickFormTotal;
  dynamic clickFormCommission;
  dynamic walletUnpaidAmount;
  dynamic walletUnpaidCount;
  dynamic userBalance;

  dynamic totalClicksCount;
  dynamic totalClicksCommission;
  factory UserTotals.fromJson(Map<String, dynamic> json) => UserTotals(
        clickLocalstoreTotal: json['click_localstore_total'],
        clickLocalstoreCommission: json['click_localstore_commission'],
        saleLocalstoreTotal: json['sale_localstore_total'],
        saleLocalstoreCommission: json['sale_localstore_commission'],
        saleLocalstoreCount: json['sale_localstore_count'],
        clickExternalTotal: json['click_external_total'],
        clickExternalCommission: json['click_external_commission'],
        orderExternalTotal: json['order_external_total'],
        orderExternalCount: json['order_external_count'],
        orderExternalCommission: json['order_external_commission'],
        clickActionTotal: json['click_action_total'],
        clickActionCommission: json['click_action_commission'],
        vendorClickLocalstoreTotal: json['vendor_click_localstore_total'],
        vendorClickLocalstoreCommissionPay:
            json['vendor_click_localstore_commission_pay'],
        vendorSaleLocalstoreTotal: json['vendor_sale_localstore_total'],
        vendorSaleLocalstoreCommissionPay:
            json['vendor_sale_localstore_commission_pay'],
        vendorSaleLocalstoreCount: json['vendor_sale_localstore_count'],
        vendorClickExternalTotal: json['vendor_click_external_total'],
        vendorClickExternalCommissionPay:
            json['vendor_click_external_commission_pay'],
        vendorActionExternalTotal: json['vendor_action_external_total'],
        vendorActionExternalCommissionPay:
            json['vendor_action_external_commission_pay'],
        vendorOrderExternalCommissionPay:
            json['vendor_order_external_commission_pay'],
        vendorOrderExternalCount: json['vendor_order_external_count'],
        vendorOrderExternalTotal: json['vendor_order_external_total'],
        clickFormTotal: json['click_form_total'],
        clickFormCommission: json['click_form_commission'],
        walletUnpaidAmount: json['wallet_unpaid_amount'],
        walletUnpaidCount: json['wallet_unpaid_count'],
        userBalance: json['user_balance'],
        totalClicksCount: json["total_clicks_count"] ?? 0.0,
        totalClicksCommission: json["total_clicks_commission"] ?? 0,
      );
}
