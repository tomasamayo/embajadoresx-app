class VendorProductsModel {
  final dynamic status;
  final dynamic message;
  final dynamic pendingCount;
  final List<VendorProduct> products;

  VendorProductsModel({
    required this.status,
    required this.message,
    required this.pendingCount,
    required this.products,
  });

  factory VendorProductsModel.fromJson(Map<String, dynamic> json) {
    // TAREA 1: REESCRITURA TOTAL (v34.0.0) - Blindaje de Tipos por IA Master
    return VendorProductsModel(
      status: json['status']?.toString() == "true" ||
          json['status']?.toString() == "1" ||
          json['status'] == true ||
          json['status'] == 1,
      message: json['message']?.toString() ?? json['msg']?.toString() ?? '',
      pendingCount: int.tryParse(json['pending_count']?.toString() ??
              json['pending_products_count']?.toString() ??
              '0') ??
          0,
      products: ((json['data'] as List?) ?? (json['products'] as List?) ?? [])
          .map((i) => VendorProduct.fromJson(i))
          .toList(),
    );
  }
}

class VendorProduct {
  final String product_id;
  final String id;
  final dynamic name;
  final dynamic sku;
  final dynamic price;
  final dynamic salePrice;
  final dynamic stock;
  final dynamic imageUrl;
  final String status;
  final String categoryId;
  final dynamic description;
  final dynamic shortDescription;
  final dynamic affiliateCommission;
  final dynamic rawCommission;
  final dynamic adminNote;
  final dynamic isTopProduct;

  VendorProduct({
    required this.product_id,
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.salePrice,
    required this.stock,
    required this.imageUrl,
    required this.status,
    required this.categoryId,
    required this.description,
    required this.shortDescription,
    required this.affiliateCommission,
    required this.rawCommission,
    required this.adminNote,
    this.isTopProduct = false,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    // TAREA 1: REESCRITURA TOTAL (v35.0.0) - Blindaje de Tipos String por IA Master
    return VendorProduct(
      product_id: json['product_id']?.toString() ?? "0",
      id: json['product_id']?.toString() ?? json['id']?.toString() ?? "0",
      name: json['name']?.toString() ?? "",
      sku: json['sku']?.toString() ?? "",
      price: double.tryParse(json['price']?.toString() ?? json['product_price']?.toString() ?? '0') ?? 0.0,
      salePrice: double.tryParse(json['sale_price']?.toString() ?? json['product_price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString() ?? "",
      status: json['status']?.toString() ?? "0",
      categoryId: json['category_id']?.toString() ?? "0",
      description: json['product_description']?.toString() ?? json['description']?.toString() ?? "",
      shortDescription: json['product_short_description']?.toString() ?? json['short_description']?.toString() ?? "",
      affiliateCommission: double.tryParse(json['affiliate_commission_value']?.toString() ?? json['commission']?.toString() ?? '0') ?? 0.0,
      rawCommission: json['affiliate_commission_value']?.toString() ?? json['commission']?.toString() ?? '0',
      adminNote: json['admin_note']?.toString() ?? json['admin_comment']?.toString() ?? "",
      isTopProduct: json['is_top_products'] == true ||
          json['is_top_products'] == 1 ||
          json['is_top_products']?.toString() == "1" ||
          json['is_top_products']?.toString() == "true",
    );
  }
}
