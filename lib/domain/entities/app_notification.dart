import 'package:equatable/equatable.dart';

/// Notification types supported by the app.
enum AppNotificationType {
  taskAssigned,
  taskCompleted,
  comment,
  mention,
  deadline,
  projectInvite,
  unknown,
}

/// Domain entity representing a user notification.
class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final AppNotificationType type;
  final bool isRead;
  final String? relatedTaskId;
  final String? relatedProjectId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppNotification({
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

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    AppNotificationType? type,
    bool? isRead,
    String? Function()? relatedTaskId,
    String? Function()? relatedProjectId,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedTaskId:
          relatedTaskId != null ? relatedTaskId() : this.relatedTaskId,
      relatedProjectId:
          relatedProjectId != null ? relatedProjectId() : this.relatedProjectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        isRead,
        relatedTaskId,
        relatedProjectId,
        createdAt,
        updatedAt,
      ];
}
