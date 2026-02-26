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
