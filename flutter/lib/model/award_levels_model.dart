import 'dart:convert';

class AwardLevelsResponse {
  final bool success;
  final List<AwardLevel> data;
  final UserStats? userStats;
  final String? currentLevelId;

  AwardLevelsResponse({
    required this.success,
    required this.data,
    this.userStats,
    this.currentLevelId,
  });

  factory AwardLevelsResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['data'];
    List rawLevels = const [];
    if (rawData is List) {
      rawLevels = rawData;
    } else if (rawData is Map<String, dynamic>) {
      final innerData = rawData['data'];
      final levels = rawData['levels'];
      if (innerData is List) {
        rawLevels = innerData;
      } else if (levels is List) {
        rawLevels = levels;
      }
    }

    final dynamic rawUserStats = (json['user_stats'] ??
        (rawData is Map<String, dynamic> ? rawData['user_stats'] : null));
    final dynamic rawCurrentLevelId = (json['current_level_id'] ??
        (rawData is Map<String, dynamic> ? rawData['current_level_id'] : null));

    return AwardLevelsResponse(
      success: json['success'] == true || json['status'] == true,
      data: rawLevels
          .map((e) => AwardLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userStats: rawUserStats is Map<String, dynamic>
          ? UserStats.fromJson(rawUserStats as Map<String, dynamic>)
          : null,
      currentLevelId: rawCurrentLevelId?.toString().trim(),
    );
  }

  static AwardLevelsResponse fromJsonString(String str) {
    return AwardLevelsResponse.fromJson(json.decode(str) as Map<String, dynamic>);
  }
}

class AwardLevel {
  final String id;
  final String levelNumber;
  final double minimumEarning;
  final int minimumPatrocinios;
  final int minimumSocios;
  final double minimumEarningTeam; // Nueva meta para Plata
  final double bonus;
  final String physicalPrize;
  final String? imageUrl;
  final String status; // Nuevo campo status: Reached, Current Level, Locked

  AwardLevel({
    required this.id,
    required this.levelNumber,
    required this.minimumEarning,
    required this.minimumPatrocinios,
    required this.minimumSocios,
    required this.minimumEarningTeam,
    required this.bonus,
    required this.physicalPrize,
    required this.imageUrl,
    required this.status,
  });

  factory AwardLevel.fromJson(Map<String, dynamic> json) {
    // Limpieza profunda del campo status para coincidir exactamente con la nueva API
    String rawStatus = (json['status'] ?? 'Locked').toString().trim().toLowerCase();
    String finalStatus = "Locked";
    
    if (rawStatus.contains("current")) {
      finalStatus = "Current Level";
    } else if (rawStatus.contains("reached")) {
      finalStatus = "Reached";
    }

    return AwardLevel(
      id: (json['id'] ?? json['level_id'] ?? json['award_level_id'])?.toString().trim() ?? '',
      levelNumber: json['level_number']?.toString() ?? '',
      minimumEarning: double.tryParse(json['minimum_earning']?.toString() ?? '0') ?? 0.0,
      minimumPatrocinios: int.tryParse(json['minimum_patrocinios']?.toString() ?? '0') ?? 0,
      minimumSocios: int.tryParse(json['minimum_socios']?.toString() ?? '0') ?? 0,
      minimumEarningTeam: double.tryParse(json['minimum_earning_team']?.toString() ?? '0') ?? 0.0,
      bonus: double.tryParse(json['bonus']?.toString() ?? '0') ?? 0.0,
      physicalPrize: json['physical_prize']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      status: finalStatus,
    );
  }
}

class UserStats {
  final double userBalance;
  final int userPatrocinios;
  final int userSocios;
  final double userEarningTeam; // Nueva métrica real del usuario
  final double totalPersonalSales; // REQUERIMIENTO v1.8.0: Ventas históricas del usuario

  UserStats({
    required this.userBalance,
    required this.userPatrocinios,
    required this.userSocios,
    required this.userEarningTeam,
    required this.totalPersonalSales,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userBalance: (json['user_balance'] is num)
          ? (json['user_balance'] as num).toDouble()
          : double.tryParse(json['user_balance']?.toString() ?? '0') ?? 0.0,
      userPatrocinios: int.tryParse(json['user_patrocinios']?.toString() ?? '0') ?? 0,
      userSocios: int.tryParse(json['user_socios']?.toString() ?? '0') ?? 0,
      userEarningTeam: (json['user_earning_team'] is num)
          ? (json['user_earning_team'] as num).toDouble()
          : double.tryParse(json['user_earning_team']?.toString() ?? '0') ?? 0.0,
      totalPersonalSales: (json['total_personal_sales'] is num)
          ? (json['total_personal_sales'] as num).toDouble()
          : double.tryParse(json['total_personal_sales']?.toString() ?? '0') ?? 0.0,
    );
  }
}
