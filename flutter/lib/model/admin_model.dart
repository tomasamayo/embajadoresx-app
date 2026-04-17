import 'package:flutter/foundation.dart';

class AdminDashboard {
  final int status;
  final double balanceGrowth;
  final double clicksGrowth;
  final double onHold;
  final double unpaid;
  final Map<String, double> incomeSources;
  final int iosUsers;
  final int androidUsers;

  AdminDashboard({
    required this.status,
    required this.balanceGrowth,
    required this.clicksGrowth,
    required this.onHold,
    required this.unpaid,
    required this.incomeSources,
    required this.iosUsers,
    required this.androidUsers,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    // PATRÓN EXACTO REQUERIDO V1.2.9
    final int status = json['status'] != null ? int.tryParse(json['status'].toString()) ?? 0 : 0;
    final Map<String, dynamic> incomeSources = json['income_sources'] is Map ? json['income_sources'] : {};
    final Map<String, dynamic> appStats = json['app_stats'] is Map ? json['app_stats'] : {};

    return AdminDashboard(
      status: status,
      balanceGrowth: double.tryParse(json['balance_growth']?.toString() ?? '0') ?? 0.0,
      clicksGrowth: double.tryParse(json['clicks_growth']?.toString() ?? '0') ?? 0.0,
      onHold: double.tryParse(json['on_hold']?.toString() ?? '0') ?? 0.0,
      unpaid: double.tryParse(json['unpaid']?.toString() ?? '0') ?? 0.0,
      incomeSources: {
        'local_store': double.tryParse(incomeSources['local_store']?.toString() ?? '0') ?? 0.0,
        'external_integrations': double.tryParse(incomeSources['external_integrations']?.toString() ?? '0') ?? 0.0,
        'vendor_pay': double.tryParse(incomeSources['vendor_pay']?.toString() ?? '0') ?? 0.0,
      },
      iosUsers: int.tryParse(appStats['ios_users']?.toString() ?? '0') ?? 0,
      androidUsers: int.tryParse(appStats['android_users']?.toString() ?? '0') ?? 0,
    );
  }
}

class GlobalNetworkNode {
  final int status;
  final int id;
  final String firstname;
  final String lastname;
  final String? profileAvatar;
  final List<GlobalNetworkNode> children;

  GlobalNetworkNode({
    required this.status,
    required this.id,
    required this.firstname,
    required this.lastname,
    this.profileAvatar,
    required this.children,
  });

  factory GlobalNetworkNode.fromJson(Map<String, dynamic> json) {
    return GlobalNodeWrapper.parseNode(json);
  }
}

class GlobalNodeWrapper {
    static GlobalNetworkNode parseNode(Map<String, dynamic> json) {
        var childrenList = json['children'] as List? ?? [];
        
        // EXTRACCIÓN DE AVATAR Y NOMBRE DESDE HTML (v1.2.9)
        String rawName = json['name']?.toString() ?? '';
        String? extractedAvatar;
        String cleanFirstname = json['firstname']?.toString() ?? '';
        String cleanLastname = json['lastname']?.toString() ?? '';

        if (rawName.contains('<img')) {
            // Extraer src='...'
            final match = RegExp(r"src='([^']+)'").firstMatch(rawName);
            if (match != null) {
                extractedAvatar = match.group(1);
            }
            // Limpiar tags HTML para el nombre
            String nameText = rawName.replaceAll(RegExp(r"<[^>]*>"), '').trim();
            if (nameText.isNotEmpty) {
                cleanFirstname = nameText;
                cleanLastname = '';
            }
        }

        if (cleanFirstname.isEmpty && cleanLastname.isEmpty) {
            cleanFirstname = "Usuario Principal";
        }

        return GlobalNetworkNode(
            // PATRÓN EXACTO REQUERIDO V1.2.9
            status: json['status'] != null ? int.tryParse(json['status'].toString()) ?? 0 : 0,
            id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
            firstname: cleanFirstname,
            lastname: cleanLastname,
            profileAvatar: extractedAvatar ?? json['profile_avatar']?.toString(),
            children: childrenList.map((c) => parseNode(c is Map ? Map<String, dynamic>.from(c) : <String, dynamic>{})).toList(),
        );
    }
}

class Complaint {
  final int status;
  final String firstname;
  final String lastname;
  final String email;
  final String description;

  Complaint({
    required this.status,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.description,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      // PATRÓN EXACTO REQUERIDO V1.2.9
      status: json['status'] != null ? int.tryParse(json['status'].toString()) ?? 0 : 0,
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
