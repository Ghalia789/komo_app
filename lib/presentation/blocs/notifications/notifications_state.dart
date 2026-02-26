import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum NotificationType {
  taskAssigned,
  taskCompleted,
  comment,
  mention,
  deadline,
  projectInvite,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.taskAssigned:
        return Icons.assignment_ind_outlined;
      case NotificationType.taskCompleted:
        return Icons.check_circle_outline;
      case NotificationType.comment:
        return Icons.chat_bubble_outline;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.deadline:
        return Icons.schedule_outlined;
      case NotificationType.projectInvite:
        return Icons.group_add_outlined;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.taskAssigned:
        return AppColors.primary;
      case NotificationType.taskCompleted:
        return AppColors.success;
      case NotificationType.comment:
        return const Color(0xFF4F9BD8);
      case NotificationType.mention:
        return const Color(0xFFD4A017);
      case NotificationType.deadline:
        return AppColors.error;
      case NotificationType.projectInvite:
        return const Color(0xFF268060);
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static List<NotificationItem> getMockData() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: '1',
        title: 'New task assigned',
        message: 'Sarah Chen assigned you to "Design homepage mockups"',
        type: NotificationType.taskAssigned,
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Task completed',
        message: 'Mike Johnson completed "Setup project structure"',
        type: NotificationType.taskCompleted,
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'New comment',
        message: 'Emma Davis commented on "Create wireframes"',
        type: NotificationType.comment,
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      NotificationItem(
        id: '4',
        title: 'You were mentioned',
        message: '@you was mentioned in "Design system review"',
        type: NotificationType.mention,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Deadline approaching',
        message: '"Homepage redesign" is due in 2 days',
        type: NotificationType.deadline,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationItem(
        id: '6',
        title: 'Project invitation',
        message: 'You were invited to join "Mobile App V2"',
        type: NotificationType.projectInvite,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }
}

class NotificationsState {
  final List<NotificationItem> notifications;
  final bool isLoading;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
