class MembershipPlansModel {
  final bool status;
  final String message;
  List<MembershipPlanItem> data;

  MembershipPlansModel({required this.status, required this.message, required this.data});

  factory MembershipPlansModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawPlans = (rawData is Map && rawData['plans'] is List)
        ? rawData['plans'] as List
        : <dynamic>[];
    final items = rawPlans.map((e) => MembershipPlanItem.fromJson(e as Map<String, dynamic>)).toList();
    return MembershipPlansModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: items,
    );
  }
}

class MembershipPlanItem {
  final String id;
  final String name;
  final String price;
  final String type;
  final String description;
  final List<String> benefits;

  MembershipPlanItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.description,
    required this.benefits,
  });

  factory MembershipPlanItem.fromJson(Map<String, dynamic> json) {
    final rawBenefits = json['benefits'];
    final benefitList = (rawBenefits is List)
        ? rawBenefits.map((e) => e.toString()).toList()
        : <String>[];

    return MembershipPlanItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      benefits: benefitList,
    );
  }
}

class MembershipHistoryModel {
  final bool status;
  final String message;
  List<MembershipHistoryItem> data;

  MembershipHistoryModel({required this.status, required this.message, required this.data});

  factory MembershipHistoryModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] is List)
        ? (json['data'] as List).map((e) => MembershipHistoryItem.fromJson(e)).toList()
        : <MembershipHistoryItem>[];
    return MembershipHistoryModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: items,
    );
  }
}

class MembershipHistoryItem {
  final String id;
  final String planName;
  final String price;
  final String planType;
  final String statusText;
  final String paymentMethod;
  final String startedAt;
  final String endedAt;
  final String createdAt;

  MembershipHistoryItem({
    required this.id,
    required this.planName,
    required this.price,
    required this.planType,
    required this.statusText,
    required this.paymentMethod,
    required this.startedAt,
    required this.endedAt,
    required this.createdAt,
  });

  factory MembershipHistoryItem.fromJson(Map<String, dynamic> json) {
    return MembershipHistoryItem(
      id: json['id']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      planType: json['plan_type']?.toString() ?? '',
      statusText: json['status_text']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      startedAt: json['started_at']?.toString() ?? '',
      endedAt: json['ended_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
