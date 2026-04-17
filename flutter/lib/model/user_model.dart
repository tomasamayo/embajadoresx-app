import '../utils/session_manager.dart';

class UserModel {
  UserModel({
    this.status,
    this.message,
    this.data,
  });

  UserModel.fromJson(dynamic json) {
    // SOLUCIÓN DEFINITIVA: Parseo seguro con try/catch para cualquier tipo de dato
    try {
      final s = json['status'];
      if (s is bool) {
        status = s;
      } else {
        final str = s?.toString() ?? 'false';
        status = str == '1' || str == 'true' || str == '200';
      }
    } catch (_) {
      status = false;
    }
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? status;
  String? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    this.token,
    this.userId,
    this.levelId,
    this.currentLevelId,
    this.planName,
    this.userStatus,
    this.firstname,
    this.lastname,
    this.email,
    this.isVendor,
    this.profileAvatar,
    this.phoneNumber,
    this.isVerified,
    this.verificationRequest,
  });

  Data.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return;
    
    token = json['token'];

    // REQUERIMIENTO: Unificador de ID de usuario (v4.0.0)
    userId = SessionManager.extractUserId(json);

    levelId = json['level_id'] ?? json['levelId'];
    currentLevelId = json['current_level_id'] ?? json['currentLevelId'] ?? levelId;
    planName = json['plan_name'] ?? json['planName'] ?? (json['plan_details'] is Map ? json['plan_details']['name'] : null);
    userStatus = json['user_status'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    email = json['email'];
    isVendor = json['is_vendor'];
    phoneNumber = json['PhoneNumber'];
    profileAvatar = json['profile_avatar'] ?? json['profile_image'];
    username = json['username'] ?? json['user_name'];
    userType = json['user_type'];
    isVerified = int.tryParse(json['is_verified']?.toString() ?? '0') ?? 0;
    verificationRequest = VerificationRequest.fromJson(json['verification_request']);
  }

  String? token;
  dynamic userId;
  dynamic levelId;
  dynamic currentLevelId;
  String? planName;
  String? userStatus;
  String? firstname;
  String? lastname;
  String? email;
  String? isVendor;
  String? profileAvatar;
  String? phoneNumber;
  String? username;
  String? userType;
  int? isVerified;
  VerificationRequest? verificationRequest;

  // REQUERIMIENTO V1.2.9: Validación dinámica de roles (Centralizada en el Modelo)
  bool get isAdmin {
    // 1. Normalización de campos para validación robusta
    final String role = userType?.toString().toLowerCase() ?? '';
    final String uName = username?.toString().toLowerCase() ?? '';
    final String uId = userId?.toString() ?? '';

    // 2. Validación Multinivel (ID 1, Rol Admin/Superadmin, o Nombre 'admin')
    if (role == "1" || role.contains("admin") || role == "superadmin") return true;
    if (uName == "admin" || uName.contains("admin")) return true;
    if (uId == "1") return true;

    return false;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    map['user_id'] = userId;
    map['level_id'] = levelId;
    map['current_level_id'] = currentLevelId;
    map['plan_name'] = planName;
    map['user_status'] = userStatus;
    map['firstname'] = firstname;
    map['lastname'] = lastname;
    map['email'] = email;
    map['is_vendor'] = isVendor;
    map['profile_avatar'] = profileAvatar;
    map['PhoneNumber'] = phoneNumber;
    map['is_verified'] = isVerified;
    return map;
  }
}

class VerificationRequest {
  bool? exists;
  int? status;
  String? adminComment;

  VerificationRequest({this.exists = false, this.status = 0, this.adminComment = ''});

  factory VerificationRequest.fromJson(dynamic json) {
    if (json == null) return VerificationRequest();
    return VerificationRequest(
      exists: json['exists'] is bool ? json['exists'] : (json['exists']?.toString() == 'true' || json['exists']?.toString() == '1'),
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      adminComment: json['admin_comment']?.toString() ?? '',
    );
  }
}
