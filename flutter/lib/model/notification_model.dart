import 'dart:convert';

NotificationsListModel notificationsListFromJson(String str) =>
    NotificationsListModel.fromJson(json.decode(str));

class NotificationsListModel {
  final bool status;
  final String message;
  final List<NotificationItem> data;

  NotificationsListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationsListModel.fromJson(Map<String, dynamic> json) {
    // Add proper null safety like in dashboard model
    final status = json['status'] ?? false;
    final message = json['message'] ?? '';

    List<NotificationItem> notifications = [];
    if (json['data'] != null && json['data'] is List) {
      notifications = List<NotificationItem>.from(
          json['data'].map((x) => NotificationItem.fromJson(x))
      );
    }

    return NotificationsListModel(
      status: status,
      message: message,
      data: notifications,
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String url;
  final String createdDate;
  final String type;
  final String actionId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.createdDate,
    required this.type,
    required this.actionId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // Add proper null safety checks
    return NotificationItem(
      id: json['notification_id']?.toString() ?? '',
      title: json['notification_title'] ?? '',
      description: json['notification_description'] ?? '',
      url: json['notification_url'] ?? '',
      createdDate: json['notification_created_date'] ?? '',
      type: json['notification_type'] ?? '',
      actionId: json['notification_actionID']?.toString() ?? '',
    );
  }
}