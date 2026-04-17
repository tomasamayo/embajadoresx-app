import 'dart:convert';

VendorOrderModel vendorOrderModelFromJson(String str) => VendorOrderModel.fromJson(json.decode(str));

class VendorOrderModel {
  final bool status;
  final String message;
  final List<VendorOrder> data;

  VendorOrderModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VendorOrderModel.fromJson(Map<String, dynamic> json) => VendorOrderModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null ? [] : List<VendorOrder>.from(json["data"].map((x) => VendorOrder.fromJson(x))),
      );
}

class VendorOrder {
  final String id;
  final String orderId;
  final String customerName;
  final String totalAmount;
  final String status; // TAREA 4: Agregar ID de estado para colores dinámicos
  final String statusText;
  final String createdAt;
  final String paymentMethod;

  VendorOrder({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.statusText,
    required this.createdAt,
    required this.paymentMethod,
  });

  factory VendorOrder.fromJson(Map<String, dynamic> json) => VendorOrder(
        id: json["id"]?.toString() ?? "",
        orderId: json["order_id"]?.toString() ?? "",
        customerName: json["customer_name"]?.toString() ?? "Cliente",
        totalAmount: json["total_amount"]?.toString() ?? "0.00",
        status: json["status"]?.toString() ?? "0",
        statusText: json["status_text"]?.toString() ?? "Pendiente",
        createdAt: json["created_at"]?.toString() ?? "",
        paymentMethod: json["payment_method"]?.toString() ?? "",
      );
}

class VendorOrderDetailModel {
  final bool status;
  final VendorOrderDetail? data;

  VendorOrderDetailModel({required this.status, this.data});

  factory VendorOrderDetailModel.fromJson(Map<String, dynamic> json) => VendorOrderDetailModel(
        status: json["status"] ?? false,
        data: json["data"] == null ? null : VendorOrderDetail.fromJson(json["data"]),
      );
}

class VendorOrderDetail {
  final String id;
  final String orderId;
  final String total;
  final String status;
  final String statusText;
  final String createdAt;
  final String paymentMethod;
  final VendorCustomer customer;
  final List<VendorOrderProduct> products;

  VendorOrderDetail({
    required this.id,
    required this.orderId,
    required this.total,
    required this.status,
    required this.statusText,
    required this.createdAt,
    required this.paymentMethod,
    required this.customer,
    required this.products,
  });

  factory VendorOrderDetail.fromJson(Map<String, dynamic> json) => VendorOrderDetail(
        id: json["id"]?.toString() ?? "",
        orderId: json["order_id"]?.toString() ?? "",
        total: json["total_amount"]?.toString() ?? "0.00",
        status: json["status"]?.toString() ?? "0",
        statusText: json["status_text"]?.toString() ?? "",
        createdAt: json["created_at"]?.toString() ?? "",
        paymentMethod: json["payment_method"]?.toString() ?? "",
        customer: VendorCustomer.fromJson(json["customer"] ?? {}),
        products: json["products"] == null ? [] : List<VendorOrderProduct>.from(json["products"].map((x) => VendorOrderProduct.fromJson(x))),
      );
}

class VendorCustomer {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;

  VendorCustomer({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
  });

  factory VendorCustomer.fromJson(Map<String, dynamic> json) => VendorCustomer(
        name: json["name"]?.toString() ?? "N/A",
        email: json["email"]?.toString() ?? "N/A",
        phone: json["phone"]?.toString() ?? "N/A",
        address: json["address"]?.toString() ?? "N/A",
        city: json["city"]?.toString() ?? "N/A",
        country: json["country"]?.toString() ?? "N/A",
      );
}

class VendorOrderProduct {
  final String name;
  final String price;
  final String quantity;
  final String total;
  final String image;

  VendorOrderProduct({
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.image,
  });

  factory VendorOrderProduct.fromJson(Map<String, dynamic> json) => VendorOrderProduct(
        name: json["product_name"]?.toString() ?? "",
        price: json["price"]?.toString() ?? "0.00",
        quantity: json["quantity"]?.toString() ?? "1",
        total: json["total"]?.toString() ?? "0.00",
        image: json["product_featured_image"]?.toString() ?? "",
      );
}
