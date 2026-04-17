import 'dart:convert';

VendorClientModel vendorClientModelFromJson(String str) => VendorClientModel.fromJson(json.decode(str));

class VendorClientModel {
  final bool status;
  final String message;
  final List<VendorClient> data;
  final VendorPagination? pagination;

  VendorClientModel({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory VendorClientModel.fromJson(Map<String, dynamic> json) => VendorClientModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null ? [] : List<VendorClient>.from(json["data"].map((x) => VendorClient.fromJson(x))),
        pagination: json["pagination"] == null ? null : VendorPagination.fromJson(json["pagination"]),
      );
}

class VendorClient {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String createdAt;

  VendorClient({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.createdAt,
  });

  factory VendorClient.fromJson(Map<String, dynamic> json) => VendorClient(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "Cliente",
        email: json["email"]?.toString() ?? "",
        avatar: json["avatar"]?.toString() ?? "",
        createdAt: json["created_at"]?.toString() ?? "",
      );
}

class VendorPagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  VendorPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory VendorPagination.fromJson(Map<String, dynamic> json) => VendorPagination(
        total: json["total"] ?? 0,
        count: json["count"] ?? 0,
        perPage: json["per_page"] ?? 10,
        currentPage: json["current_page"] ?? 1,
        totalPages: json["total_pages"] ?? 1,
      );
}
