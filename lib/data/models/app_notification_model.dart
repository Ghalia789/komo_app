import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? relatedTaskId;
  final String? relatedProjectId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedTaskId,
    this.relatedProjectId,
    this.updatedAt,
  });

  factory AppNotificationModel.fromDomain(AppNotification notification) {
    return AppNotificationModel(
      id: notification.id,
      userId: notification.userId,
      title: notification.title,
      message: notification.message,
      type: _typeToString(notification.type),
      isRead: notification.isRead,
      relatedTaskId: notification.relatedTaskId,
      relatedProjectId: notification.relatedProjectId,
      createdAt: notification.createdAt,
      updatedAt: notification.updatedAt,
    );
  }

  AppNotification toDomain() {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: _typeFromString(type),
      isRead: isRead,
      relatedTaskId: relatedTaskId,
      relatedProjectId: relatedProjectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      isRead: json['isRead'] as bool? ?? false,
      relatedTaskId: json['relatedTaskId'] as String?,
      relatedProjectId: json['relatedProjectId'] as String?,
      createdAt: _fromTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: _fromTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'relatedTaskId': relatedTaskId,
      'relatedProjectId': relatedProjectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}

AppNotificationType _typeFromString(String value) {
  switch (value) {
    case 'taskAssigned':
    case 'task_assigned':
      return AppNotificationType.taskAssigned;
    case 'taskCompleted':
    case 'task_completed':
      return AppNotificationType.taskCompleted;
    case 'comment':
      return AppNotificationType.comment;
    case 'mention':
      return AppNotificationType.mention;
    case 'deadline':
      return AppNotificationType.deadline;
    case 'projectInvite':
    case 'project_invite':
      return AppNotificationType.projectInvite;
    default:
      return AppNotificationType.unknown;
  }
}

String _typeToString(AppNotificationType type) {
  switch (type) {
    case AppNotificationType.taskAssigned:
      return 'taskAssigned';
    case AppNotificationType.taskCompleted:
      return 'taskCompleted';
    case AppNotificationType.comment:
      return 'comment';
    case AppNotificationType.mention:
      return 'mention';
    case AppNotificationType.deadline:
      return 'deadline';
    case AppNotificationType.projectInvite:
      return 'projectInvite';
    case AppNotificationType.unknown:
      return 'unknown';
  }
}
