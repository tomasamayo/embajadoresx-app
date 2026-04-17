import 'dart:convert';

DashboardModel dashboardModelFromJson(String str) =>
    DashboardModel.fromJson(json.decode(str));

class DashboardModel {
  DashboardModel({
    required this.status,
    required this.message,
    required this.data,
  });

  bool status;
  String message;
  Data data;

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        // SOLUCIÓN DEFINITIVA: Parseo seguro de bool para soportar PHP String/int
        status: _parseBool(json["status"]),
        message: json["message"]??"",
        data: Data.fromJson(json["data"]),
      );

  // Helper centralizado de parseo de bool seguro contra tipos PHP
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final str = value.toString();
    return str == '1' || str == 'true' || str == '200';
  }
}

class Data {
  Data({
    required this.currentRankName,
    required this.referStatus,
    required this.uniqueResellerLink,
    required this.isMembershipAccess,
    required this.userPlan,
    required this.userTotals,
    required this.referTotal,
    required this.userTotalsWeek,
    required this.userTotalsMonth,
    required this.userTotalsYear,
    required this.notifications,
    required this.marketTools,
    required this.affiliateStoreUrl,
    required this.topAffiliate,
    required this.recentActivities,
    required this.weeklyChartData,
  });

  String currentRankName;
  bool referStatus;
  String uniqueResellerLink;
  bool isMembershipAccess;
  UserPlan userPlan;
  UserTotals userTotals;
  ReferTotal referTotal;
  String userTotalsWeek;
  String userTotalsMonth;
  String userTotalsYear;
  List<Map<String, dynamic>> notifications;
  List<MarketTool> marketTools;
  String affiliateStoreUrl;
  List<TopAffiliate> topAffiliate;
  List<Map<String, dynamic>> recentActivities;
  List<double> weeklyChartData;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentRankName: json["current_rank_name"]?.toString() ?? "Sin Rango",
    referStatus: json["refer_status"] ?? false,
    uniqueResellerLink: json["unique_reseller_link"]?.toString() ?? "",
    isMembershipAccess: json["isMembershipAccess"] ?? false,
    // Add null check for user_plan
    userPlan: json["user_plan"] != null
        ? UserPlan.fromJson(json["user_plan"])
        : UserPlan.fromJson({
      "plan_name": "Sin Plan",
      "total_day": "0",
      "expire_at": DateTime.now().toIso8601String(),
      "started_at": DateTime.now().toIso8601String(),
      "status_id": "0",
      "is_active": "0",
      "is_lifetime": "0"
    }),
    userTotals: UserTotals.fromJson(json["user_totals"]),
    referTotal: ReferTotal.fromJson(json["refer_total"]),
    userTotalsWeek: json["user_totals_week"]?.toString() ?? "0",
    userTotalsMonth: json["user_totals_month"]?.toString() ?? "0",
    userTotalsYear: json["user_totals_year"]?.toString() ?? "0",
    notifications: json["notifications"] != null
        ? List<Map<String, dynamic>>.from(json["notifications"]
        .map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v))))
        : [],
    marketTools: json["market_tools"] != null
        ? List<MarketTool>.from(json["market_tools"].map((x) => MarketTool.fromJson(x)))
        : [],
    affiliateStoreUrl: json["affiliate_store_url"]?.toString() ?? "",
    topAffiliate: json["top_affiliate"] != null
        ? List<TopAffiliate>.from(json["top_affiliate"].map((x) => TopAffiliate.fromJson(x)))
        : [],
    recentActivities: json["recent_activities"] != null
        ? List<Map<String, dynamic>>.from(json["recent_activities"]
        .map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v))))
        : [],
    weeklyChartData: json["weekly_chart_data"] != null
        ? List<double>.from(json["weekly_chart_data"].map((x) => double.tryParse(x.toString()) ?? 0.0))
        : [],
  );
}

class MarketTool {
  MarketTool({
    required this.id,
    required this.affToolType,
    required this.publicPage,
    required this.feviIcon,
    required this.title,
    required this.shareUrl,
    required this.clickCommisionYouWillGet,
    required this.recurring,
    required this.clickRatio,
    required this.generalCount,
    required this.generalAmount,
    required this.saleCommisionYouWillGet,
    required this.saleRatio,
    required this.saleCount,
    required this.saleAmount,
    required this.clickCount,
    required this.clickAmount,
    required this.actionCount,
    required this.actionAmount,
    required this.isCampaignProduct,
    required this.description,
    required this.price,
    required this.productSku,
    required this.salesCommission,
    required this.clicksCommission,
    required this.totalCommission,
    required this.displayedOnStore,
  });

  String id;
  String affToolType;
  String publicPage;
  String feviIcon;
  String title;
  String shareUrl;
  String clickCommisionYouWillGet;
  String recurring;
  String clickRatio;
  int generalCount;
  String generalAmount;
  String saleCommisionYouWillGet;
  String saleRatio;
  int saleCount;
  String saleAmount;
  int clickCount;
  String clickAmount;
  int actionCount;
  String actionAmount;
  bool isCampaignProduct;
  String description;
  String price;
  String productSku;
  String salesCommission;
  String clicksCommission;
  String totalCommission;
  bool displayedOnStore;

  factory MarketTool.fromJson(Map<String, dynamic> json) => MarketTool(
        id: (json["id"] ?? json["product_id"] ?? "").toString(),
        affToolType: json["aff_tool_type"] ?? "",
        publicPage: json["public_page"] ?? "",
        feviIcon: json["fevi_icon"] ?? "",
        title: json["title"] ?? "",
        shareUrl: json["share_url"] ?? "",
        clickCommisionYouWillGet: json["click_commision_you_will_get"] ?? "",
        recurring: json["recurring"] ?? "",
        clickRatio: json["click_ratio"] ?? "",
        generalCount: json["general_count"] ?? 0,
        generalAmount: json["general_amount"] ?? "",
        saleCommisionYouWillGet: json["sale_commision_you_will_get"] ?? "",
        saleRatio: json["sale_ratio"] ?? "",
        saleCount: json["sale_count"] ?? 0,
        saleAmount: json["sale_amount"] ?? "",
        clickCount: json["click_count"] ?? 0,
        clickAmount: json["click_amount"] ?? "",
        actionCount: json["action_count"] ?? 0,
        actionAmount: json["action_amount"] ?? "",
        isCampaignProduct: json["is_campaign_product"] ?? false,
        description: json["description"] ?? "",
        price: json["price"] ?? "",
        productSku: json["product_sku"] ?? "",
        salesCommission: json["sales_commission"] ?? "",
        clicksCommission: json["clicks_commission"] ?? "",
        totalCommission: json["total_commission"] ?? "",
        displayedOnStore: json["displayed_on_store"] ?? false,
      );
}

class ReferTotal {
  ReferTotal({
    required this.totalProductClick,
    required this.totalGaneralClick,
    required this.totalAction,
    required this.totalProductSale,
  });

  TotalProductClick totalProductClick;
  TotalGaneralClick totalGaneralClick;
  TotalAction totalAction;
  TotalProductSale totalProductSale;

  factory ReferTotal.fromJson(Map<String, dynamic> json) => ReferTotal(
        totalProductClick:
            TotalProductClick.fromJson(json["total_product_click"]),
        totalGaneralClick:
            TotalGaneralClick.fromJson(json["total_ganeral_click"]),
        totalAction: TotalAction.fromJson(json["total_action"]),
        totalProductSale: TotalProductSale.fromJson(json["total_product_sale"]),
      );
}

class TotalAction {
  TotalAction({
    required this.clickCount,
  });

  String clickCount;

  factory TotalAction.fromJson(Map<String, dynamic> json) => TotalAction(
        clickCount: json["click_count"].toString(),
      );
}

class TotalGaneralClick {
  TotalGaneralClick({
    required this.totalClicks,
  });

  String totalClicks;

  factory TotalGaneralClick.fromJson(Map<String, dynamic> json) =>
      TotalGaneralClick(
        totalClicks: json["total_clicks"].toString(),
      );
}

class TotalProductClick {
  TotalProductClick({
    required this.amounts,
    required this.clicks,
  });

  dynamic amounts;
  String clicks;

  factory TotalProductClick.fromJson(Map<String, dynamic> json) =>
      TotalProductClick(
        amounts: json["amounts"],
        clicks: json["clicks"].toString(),
      );
}

class TotalProductSale {
  TotalProductSale({
    required this.amounts,
    required this.counts,
    required this.paid,
    required this.request,
    required this.unpaid,
  });

  dynamic amounts;
  String counts;
  dynamic paid;
  dynamic request;
  dynamic unpaid;

  factory TotalProductSale.fromJson(Map<String, dynamic> json) =>
      TotalProductSale(
        amounts: json["amounts"],
        counts: json["counts"],
        paid: json["paid"],
        request: json["request"],
        unpaid: json["unpaid"],
      );
}

class TopAffiliate {
  TopAffiliate({
    required this.amount,
    required this.allCommition,
    required this.userId,
    required this.type,
    required this.avatar,
    required this.firstname,
    required this.lastname,
    required this.country,
    required this.email,
    required this.sortname,
    this.isVerified = 0,
  });

  String amount;
  String allCommition;
  String userId;
  Type type;
  String avatar;
  String firstname;
  String lastname;
  String country;
  String email;
  String sortname;
  int isVerified;

  factory TopAffiliate.fromJson(Map<String, dynamic> json) => TopAffiliate(
        amount: json["amount"].toString(),
        allCommition: json["all_commition"].toString(),
        userId: json["user_id"].toString(),
        type: typeValues.map[json["type"]]!,
        avatar: json["avatar"] ?? "",
        firstname: json["firstname"].toString(),
        lastname: json["lastname"].toString(),
        country: json["Country"].toString(),
        email: json["email"].toString(),
        sortname: json["sortname"].toString(),
        isVerified: int.tryParse(json["is_verified"]?.toString() ?? '0') ?? 0,
      );
}

enum Type { USER }

final typeValues = EnumValues({"user": Type.USER});

class UserPlan {
  UserPlan({
    required this.planName,
    required this.totalDay,
    required this.expireAt,
    required this.startedAt,
    required this.statusId,
    required this.isActive,
    required this.isLifetime,
  });

  String planName;
  String totalDay;
  DateTime expireAt;
  DateTime startedAt;
  String statusId;
  String isActive;
  String isLifetime;

  factory UserPlan.fromJson(Map<String, dynamic> json) {
    // REQUERIMIENTO V15.1: Limpiar nombre del plan (quitar precio en paréntesis)
    String rawPlanName = json["plan_name"]?.toString() ?? json["planName"]?.toString() ?? "";
    if (rawPlanName.contains('(')) {
      rawPlanName = rawPlanName.split('(')[0].trim();
    }
    
    return UserPlan(
        planName: rawPlanName,
        totalDay: json["total_day"].toString(),
        expireAt: json["expire_at"] != null ? DateTime.parse(json["expire_at"]) : DateTime.now(),
        startedAt: json["started_at"] != null ? DateTime.parse(json["started_at"]) : DateTime.now(),
        statusId: json["status_id"].toString(),
        isActive: json["is_active"].toString(),
        isLifetime: json["is_lifetime"].toString(),
      );
  }
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
    required this.vendorClickLocalstoreCommission,
    required this.vendorClickLocalstoreCommissionPay,
    required this.vendorSaleLocalstoreTotal,
    required this.vendorSaleLocalstoreCommissionPay,
    required this.vendorSaleLocalstoreCount,
    required this.vendorClickExternalTotal,
    required this.vendorClickExternalCommission,
    required this.vendorClickExternalCommissionPay,
    required this.vendorActionExternalTotal,
    required this.vendorActionExternalCommission,
    required this.vendorActionExternalCommissionPay,
    required this.vendorOrderExternalCommissionPay,
    required this.vendorOrderExternalCount,
    required this.vendorOrderExternalTotal,
    required this.clickFormTotal,
    required this.clickFormCommission,
    required this.walletUnpaidAmount,
    required this.walletUnpaidCount,
    required this.totalClicksCount,
    required this.totalClicksCommission,
    required this.userBalance,
  });

  int clickLocalstoreTotal;
  dynamic clickLocalstoreCommission;
  dynamic saleLocalstoreTotal;
  dynamic saleLocalstoreCommission;
  dynamic saleLocalstoreCount;
  dynamic clickExternalTotal;
  String clickExternalCommission;
  dynamic orderExternalTotal;
  String orderExternalCount;
  dynamic orderExternalCommission;
  dynamic clickActionTotal;
  String clickActionCommission;
  dynamic vendorClickLocalstoreTotal;
  dynamic vendorClickLocalstoreCommission;
  dynamic vendorClickLocalstoreCommissionPay;
  dynamic vendorSaleLocalstoreTotal;
  dynamic vendorSaleLocalstoreCommissionPay;
  dynamic vendorSaleLocalstoreCount;
  dynamic vendorClickExternalTotal;
  dynamic vendorClickExternalCommission;
  dynamic vendorClickExternalCommissionPay;
  dynamic vendorActionExternalTotal;
  dynamic vendorActionExternalCommission;
  dynamic vendorActionExternalCommissionPay;
  dynamic vendorOrderExternalCommissionPay;
  String vendorOrderExternalCount;
  dynamic vendorOrderExternalTotal;
  dynamic clickFormTotal;
  dynamic clickFormCommission;
  dynamic walletUnpaidAmount;
  dynamic walletUnpaidCount;
  dynamic totalClicksCount;
  dynamic totalClicksCommission;
  String userBalance;

  factory UserTotals.fromJson(Map<String, dynamic> json) => UserTotals(
        clickLocalstoreTotal: int.tryParse(json["click_localstore_total"]?.toString() ?? '0') ?? 0,
        clickLocalstoreCommission: json["click_localstore_commission"],
        saleLocalstoreTotal: json["sale_localstore_total"]??0.0,
        saleLocalstoreCommission: json["sale_localstore_commission"]??0.0,
        saleLocalstoreCount: json["sale_localstore_count"]??0.0,
        clickExternalTotal: json["click_external_total"]??0.0,
        clickExternalCommission: json["click_external_commission"].toString(),
        orderExternalTotal: json["order_external_total"],
        orderExternalCount: json["order_external_count"].toString(),
        orderExternalCommission: json["order_external_commission"],
        clickActionTotal: json["click_action_total"]??0.0,
        clickActionCommission: json["click_action_commission"].toString(),
        vendorClickLocalstoreTotal:
            json["vendor_click_localstore_total"]??0.0,
        vendorClickLocalstoreCommission:
            json["vendor_click_localstore_commission"],
        vendorClickLocalstoreCommissionPay:
            json["vendor_click_localstore_commission_pay"],
        vendorSaleLocalstoreTotal: json["vendor_sale_localstore_total"],
        vendorSaleLocalstoreCommissionPay:
            json["vendor_sale_localstore_commission_pay"],
        vendorSaleLocalstoreCount: json["vendor_sale_localstore_count"],
        vendorClickExternalTotal:
            json["vendor_click_external_total"]??0.0,
        vendorClickExternalCommission:
            json["vendor_click_external_commission"]??0.0,
        vendorClickExternalCommissionPay:
            json["vendor_click_external_commission_pay"],
        vendorActionExternalTotal:
            json["vendor_action_external_total"]??0.0,
        vendorActionExternalCommission:
            json["vendor_action_external_commission"]??0.0,
        vendorActionExternalCommissionPay:
            json["vendor_action_external_commission_pay"],
        vendorOrderExternalCommissionPay:
            json["vendor_order_external_commission_pay"],
        vendorOrderExternalCount:
            json["vendor_order_external_count"].toString(),
        vendorOrderExternalTotal: json["vendor_order_external_total"],
        clickFormTotal: json["click_form_total"]??0.0,
        clickFormCommission: json["click_form_commission"],
        walletUnpaidAmount: json["wallet_unpaid_amount"]??0.0,
        walletUnpaidCount: json["wallet_unpaid_count"]??0.0,
        totalClicksCount: json["total_clicks_count"]??0.0,
        totalClicksCommission: json["total_clicks_commission"]??0.0,
        userBalance: json["user_balance"].toString(),
      );
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
