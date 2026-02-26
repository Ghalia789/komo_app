import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationsLoadData>(_onLoadData);
    on<NotificationTapped>(_onNotificationTapped);
    on<NotificationDismissed>(_onNotificationDismissed);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
  }

  Future<void> _onLoadData(
    NotificationsLoadData event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Load from Firebase/API
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(
      isLoading: false,
      notifications: NotificationItem.getMockData(),
    ));
  }

  void _onNotificationTapped(
    NotificationTapped event,
    Emitter<NotificationsState> emit,
  ) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == event.notificationId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));
    // TODO: Navigate based on notification type
  }

  void _onNotificationDismissed(
    NotificationDismissed event,
    Emitter<NotificationsState> emit,
  ) {
    final updatedNotifications = state.notifications
        .where((n) => n.id != event.notificationId)
        .toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }

  void _onMarkAllRead(
    NotificationsMarkAllRead event,
    Emitter<NotificationsState> emit,
  ) {
    final updatedNotifications = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }
}
