import 'dart:convert';

ReportModel walletFromJson(String str) =>
    ReportModel.fromJson(json.decode(str));

class ReportModel {
  ReportModel({
    required this.status,
    required this.message,
    required this.data,
  });

  bool status;
  String message;
  Data data;

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );
}

class Statistics {
  Map<String, int>? sale;
  Map<String, int>? clicks;
  int? clicksCount;
  int? saleCount;
  Map<String, int>? affiliateUser;
  int? affiliateUserCount;

  Statistics({
    this.sale,
    this.clicks,
    this.clicksCount,
    this.saleCount,
    this.affiliateUser,
    this.affiliateUserCount,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      sale: _parseMap(json['sale']),
      clicks: _parseMap(json['clicks']),
      clicksCount: json['clicks_count'] ?? 0,
      saleCount: json['sale_count'] ?? 0,
      affiliateUser: _parseMap(json['affiliate_user']),
      affiliateUserCount: json['affiliate_user_count'] ?? 0,
    );
  }

  static Map<String, int> _parseMap(dynamic data) {
    if (data == null || data is List) return {};
    if (data is Map) {
      return data.map((key, value) {
        int parsedValue = 0;
        if (value is int) {
          parsedValue = value;
        } else if (value is double) {
          parsedValue = value.toInt();
        } else if (value is String) {
          parsedValue = num.tryParse(value)?.toInt() ?? 0;
        }
        return MapEntry(key.toString(), parsedValue);
      });
    }
    return {};
  }
}

class Totals {
  double unpaidCommition;
  int totalSaleCommi;
  int totalInRequest;
  int totalClickCommi;
  int totalFormClickCommi;
  int totalStoreMCommission;
  int totalAffiliateClickCommission;
  int totalNoClick;
  int totalNoFormClick;
  int affTotalNoClick;
  int adminClickEarning;
  int allClicksComm;
  int allSaleComm;
  int affiliatesProgram;
  int totalSaleCount;
  int totalSale;
  int totalVendorSale;
  int totalSaleBalance;
  int totalSaleWeek;
  int totalSaleMonth;
  int totalSaleYear;
  int adminClickEarningWeek;
  int adminClickEarningMonth;
  int adminClickEarningYear;
  int adminTotalNoClick;
  int allClicks;
  int vendorOrderCount;
  int totalPaid;
  int totalPaidCommition;
  int paidCommition;
  int requestedCommition;
  int affPaidCommition;
  int affUnpaidCommition;
  int affRequestedCommition;
  int formPaidCommition;
  int formUnpaidCommition;
  int formRequestedCommition;
  int totalTransaction;
  int walletTrashCount;
  int walletTrashAmount;
  int walletCancelCount;
  int walletCancelAmount;
  int walletAcceptCount;
  int walletAcceptAmount;
  int walletRequestSentCount;
  int walletRequestSentAmount;
  int walletOnHoldCount;
  int walletOnHoldAmount;
  double walletUnpaidAmount;
  int walletUnpaidCount;
  Integration integration;
  Map<String, dynamic>? adminTransaction;
  Store store;
  int totalSaleAmount;
  int totalBalance;
  int weeklyBalance;
  int monthlyBalance;
  int yearlyBalance;

  Totals({
    required this.unpaidCommition,
    required this.totalSaleCommi,
    required this.totalInRequest,
    required this.totalClickCommi,
    required this.totalFormClickCommi,
    required this.totalStoreMCommission,
    required this.totalAffiliateClickCommission,
    required this.totalNoClick,
    required this.totalNoFormClick,
    required this.affTotalNoClick,
    required this.adminClickEarning,
    required this.allClicksComm,
    required this.allSaleComm,
    required this.affiliatesProgram,
    required this.totalSaleCount,
    required this.totalSale,
    required this.totalVendorSale,
    required this.totalSaleBalance,
    required this.totalSaleWeek,
    required this.totalSaleMonth,
    required this.totalSaleYear,
    required this.adminClickEarningWeek,
    required this.adminClickEarningMonth,
    required this.adminClickEarningYear,
    required this.adminTotalNoClick,
    required this.allClicks,
    required this.vendorOrderCount,
    required this.totalPaid,
    required this.totalPaidCommition,
    required this.paidCommition,
    required this.requestedCommition,
    required this.affPaidCommition,
    required this.affUnpaidCommition,
    required this.affRequestedCommition,
    required this.formPaidCommition,
    required this.formUnpaidCommition,
    required this.formRequestedCommition,
    required this.totalTransaction,
    required this.walletTrashCount,
    required this.walletTrashAmount,
    required this.walletCancelCount,
    required this.walletCancelAmount,
    required this.walletAcceptCount,
    required this.walletAcceptAmount,
    required this.walletRequestSentCount,
    required this.walletRequestSentAmount,
    required this.walletOnHoldCount,
    required this.walletOnHoldAmount,
    required this.walletUnpaidAmount,
    required this.walletUnpaidCount,
    required this.integration,
    this.adminTransaction,
    required this.store,
    required this.totalSaleAmount,
    required this.totalBalance,
    required this.weeklyBalance,
    required this.monthlyBalance,
    required this.yearlyBalance,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      unpaidCommition: json['unpaid_commition']?.toDouble() ?? 0.0,
      totalSaleCommi: json['total_sale_commi'] ?? 0,
      totalInRequest: json['total_in_request'] ?? 0,
      totalClickCommi: json['total_click_commi'] ?? 0,
      totalFormClickCommi: json['total_form_click_commi'] ?? 0,
      totalStoreMCommission: json['total_store_m_commission'] ?? 0,
      totalAffiliateClickCommission:
          json['total_affiliate_click_commission'] ?? 0,
      totalNoClick: json['total_no_click'] ?? 0,
      totalNoFormClick: json['total_no_form_click'] ?? 0,
      affTotalNoClick: json['aff_total_no_click'] ?? 0,
      adminClickEarning: json['admin_click_earning'] ?? 0,
      allClicksComm: json['all_clicks_comm'] ?? 0,
      allSaleComm: json['all_sale_comm'] ?? 0,
      affiliatesProgram: json['affiliates_program'] ?? 0,
      totalSaleCount: json['total_sale_count'] ?? 0,
      totalSale: json['total_sale'] ?? 0,
      totalVendorSale: json['total_vendor_sale'] ?? 0,
      totalSaleBalance: json['total_sale_balance'] ?? 0,
      totalSaleWeek: json['total_sale_week'] ?? 0,
      totalSaleMonth: json['total_sale_month'] ?? 0,
      totalSaleYear: json['total_sale_year'] ?? 0,
      adminClickEarningWeek: json['admin_click_earning_week'] ?? 0,
      adminClickEarningMonth: json['admin_click_earning_month'] ?? 0,
      adminClickEarningYear: json['admin_click_earning_year'] ?? 0,
      adminTotalNoClick: json['admin_total_no_click'] ?? 0,
      allClicks: json['all_clicks'] ?? 0,
      vendorOrderCount: json['vendor_order_count'] ?? 0,
      totalPaid: json['total_paid'] ?? 0,
      totalPaidCommition: json['total_paid_commition'] ?? 0,
      paidCommition: json['paid_commition'] ?? 0,
      requestedCommition: json['requested_commition'] ?? 0,
      affPaidCommition: json['aff_paid_commition'] ?? 0,
      affUnpaidCommition: json['aff_unpaid_commition'] ?? 0,
      affRequestedCommition: json['aff_requested_commition'] ?? 0,
      formPaidCommition: json['form_paid_commition'] ?? 0,
      formUnpaidCommition: json['form_unpaid_commition'] ?? 0,
      formRequestedCommition: json['form_requested_commition'] ?? 0,
      totalTransaction: json['total_transaction'] ?? 0,
      walletTrashCount: json['wallet_trash_count'] ?? 0,
      walletTrashAmount: json['wallet_trash_amount'] ?? 0,
      walletCancelCount: json['wallet_cancel_count'] ?? 0,
      walletCancelAmount: json['wallet_cancel_amount'] ?? 0,
      walletAcceptCount: json['wallet_accept_count'] ?? 0,
      walletAcceptAmount: json['wallet_accept_amount'] ?? 0,
      walletRequestSentCount: json['wallet_request_sent_count'] ?? 0,
      walletRequestSentAmount: json['wallet_request_sent_amount'] ?? 0,
      walletOnHoldCount: json['wallet_on_hold_count'] ?? 0,
      walletOnHoldAmount: json['wallet_on_hold_amount'] ?? 0,
      walletUnpaidAmount: json['wallet_unpaid_amount']?.toDouble() ?? 0.0,
      walletUnpaidCount: json['wallet_unpaid_count'] ?? 0,
      integration: json['integration'] != null
          ? Integration.fromJson(json['integration'])
          : Integration(holdActionCount: 0, holdOrders: 0, totalCommission: 0),
      adminTransaction: json['admin_transaction'] != null
          ? Map<String, dynamic>.from(json['admin_transaction'])
          : null,
      store: Store.fromJson(
          json['store']), // Assuming Store has a default constructor.
      totalSaleAmount: json['total_sale_amount'] ?? 0,
      totalBalance: json['total_balance'] ?? 0,
      weeklyBalance: json['weekly_balance'] ?? 0,
      monthlyBalance: json['monthly_balance'] ?? 0,
      yearlyBalance: json['yearly_balance'] ?? 0,
    );
  }
}

class Integration {
  final int holdActionCount;
  final int holdOrders;
  final int totalCommission;

  Integration({
    required this.holdActionCount,
    required this.holdOrders,
    required this.totalCommission,
  });

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      holdActionCount: json['hold_action_count'] ?? 0,
      holdOrders: json['hold_orders'] ?? 0,
      totalCommission: json['total_commission'] ?? 0,
    );
  }
}

class Transaction {
  String id;
  String username;
  String name;
  String userId;
  String amount;
  String comment;
  String createdAt;
  String type;
  String commFrom;
  String disType;
  String status;
  String statusId;
  dynamic integrationOrdersTotal;
  String statusIcon;
  dynamic paymentMethod;

  Transaction({
    required this.id,
    required this.username,
    required this.name,
    required this.userId,
    required this.amount,
    required this.comment,
    required this.createdAt,
    required this.type,
    required this.commFrom,
    required this.disType,
    required this.status,
    required this.statusId,
    this.integrationOrdersTotal,
    required this.statusIcon,
    this.paymentMethod,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      userId: json['user_id'] ?? '',
      amount: json['amount'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
      type: json['type'] ?? '',
      commFrom: json['comm_from'] ?? '',
      disType: json['dis_type'] ?? '',
      status: json['status'] ?? '',
      statusId: json['status_id'] ?? '',
      integrationOrdersTotal: json['integration_orders_total'],
      statusIcon: json['status_icon'] ?? '',
      paymentMethod: json['payment_method'],
    );
  }
}

class Data {
  Data({
    required this.referStatus,
    required this.statistics,
    // required this.totals,
    // required this.transaction,
  });

  bool referStatus;
  Statistics statistics;
  // Totals totals;
  // List<Transaction> transaction;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        referStatus: json["refer_status"],
        statistics: Statistics.fromJson(json["statistics"]),
        // totals: Totals.fromJson(json["totals"]),
        // transaction: List<Transaction>.from(
        //   json['transaction'].map((x) => Transaction.fromJson(x)),
        // ),
      );
}

class Store {
  Store({
    required this.holdOrders,
    required this.balance,
    required this.sale,
    required this.clickCount,
    required this.clickAmount,
    required this.totalCommission,
  });

  int holdOrders;
  int balance;
  int sale;
  int clickCount;
  int clickAmount;
  int totalCommission;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        holdOrders: json["hold_orders"],
        balance: json["balance"],
        sale: json["sale"],
        clickCount: json["click_count"],
        clickAmount: json["click_amount"],
        totalCommission: json["total_commission"],
      );
}
