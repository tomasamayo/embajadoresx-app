class VendorStatsModel {
  final bool status;
  final String message;
  final VendorStatsData data;

  VendorStatsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) {
    return VendorStatsModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: VendorStatsData.fromJson(json['data'] ?? {}),
    );
  }
}

class VendorStatsData {
  final VendorStatsSummary stats;
  final List<VendorRecentOrder> recentOrders;

  VendorStatsData({
    required this.stats,
    required this.recentOrders,
  });

  factory VendorStatsData.fromJson(Map<String, dynamic> json) {
    var list = json['recent_orders'] as List? ?? [];
    List<VendorRecentOrder> ordersList =
        list.map((i) => VendorRecentOrder.fromJson(i)).toList();

    return VendorStatsData(
      stats: VendorStatsSummary.fromJson(json['stats'] ?? {}),
      recentOrders: ordersList,
    );
  }
}

class VendorStatsSummary {
  final String totalSales;
  final String totalClicks;
  final String totalProducts;
  final String totalCoupons;

  VendorStatsSummary({
    required this.totalSales,
    required this.totalClicks,
    required this.totalProducts,
    required this.totalCoupons,
  });

  factory VendorStatsSummary.fromJson(Map<String, dynamic> json) {
    return VendorStatsSummary(
      totalSales: json['total_sales']?.toString() ?? '0.00',
      totalClicks: json['total_clicks']?.toString() ?? '0',
      totalProducts: json['total_products']?.toString() ?? '0',
      totalCoupons: json['total_coupons']?.toString() ?? '0',
    );
  }
}

class VendorRecentOrder {
  final String id;
  final String orderId;
  final String totalAmount;
  final String paymentMethod;
  final String statusText;
  final String createdAt;

  VendorRecentOrder({
    required this.id,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.statusText,
    required this.createdAt,
  });

  factory VendorRecentOrder.fromJson(Map<String, dynamic> json) {
    return VendorRecentOrder(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paymentMethod: json['payment_method']?.toString() ?? '',
      statusText: json['status_text']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
