import '../../../domain/entities/app_notification.dart';

abstract class NotificationsEvent {}

class NotificationsLoadData extends NotificationsEvent {}

class NotificationTapped extends NotificationsEvent {
  final String notificationId;
  NotificationTapped(this.notificationId);
}

class NotificationDismissed extends NotificationsEvent {
  final String notificationId;
  NotificationDismissed(this.notificationId);
}

class NotificationsMarkAllRead extends NotificationsEvent {}

class NotificationsStreamUpdated extends NotificationsEvent {
  final List<AppNotification> notifications;
  NotificationsStreamUpdated(this.notifications);
}

class NotificationsStreamFailed extends NotificationsEvent {
  final String message;
  NotificationsStreamFailed(this.message);
}
