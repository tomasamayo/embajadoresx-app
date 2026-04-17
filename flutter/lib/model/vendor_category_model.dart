class VendorCategoryModel {
  final bool status;
  final String message;
  final List<VendorCategory> data;

  VendorCategoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<VendorCategory> categoriesList =
        list.map((i) => VendorCategory.fromJson(i)).toList();

    return VendorCategoryModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: categoriesList,
    );
  }
}

class VendorCategory {
  final String id;
  final String name;

  VendorCategory({
    required this.id,
    required this.name,
  });

  factory VendorCategory.fromJson(Map<String, dynamic> json) {
    return VendorCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
