
class MarketingMaterialModel {
  final bool status;
  final String message;
  final List<MarketingMaterial> data;

  MarketingMaterialModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MarketingMaterialModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = (rawData is List) ? rawData : [];
    return MarketingMaterialModel(
      status: (json['success'] == true || json['status'] == true),
      message: json['message']?.toString() ?? '',
      data: list.map((e) => MarketingMaterial.fromJson(e)).toList(),
    );
  }
}

class MarketingMaterial {
  final String id;
  final String type; // image, video, pdf
  final String url;
  final String name;

  MarketingMaterial({
    required this.id,
    required this.type,
    required this.url,
    required this.name,
  });

  factory MarketingMaterial.fromJson(Map<String, dynamic> json) {
    return MarketingMaterial(
      id: (json['id'] ?? json['marketing_id'] ?? '').toString(),
      type: json['type']?.toString() ?? 'image',
      url: json['full_path']?.toString() ?? json['url']?.toString() ?? '',
      name: json['title']?.toString() ?? json['name']?.toString() ?? 'Material',
    );
  }
}
