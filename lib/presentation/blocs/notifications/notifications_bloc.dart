import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/app_notification.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/project_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required AuthRepository authRepository,
    required ProjectRepository projectRepository,
  })  : _authRepository = authRepository,
        _projectRepository = projectRepository,
        super(const NotificationsState()) {
    on<NotificationsLoadData>(_onLoadData);
    on<NotificationTapped>(_onNotificationTapped);
    on<NotificationDismissed>(_onNotificationDismissed);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
    on<NotificationsStreamUpdated>(_onStreamUpdated);
    on<NotificationsStreamFailed>(_onStreamFailed);
    on<NotificationsNavigationHandled>(_onNavigationHandled);
  }

  final AuthRepository _authRepository;
  final ProjectRepository _projectRepository;
  StreamSubscription? _notificationsSub;
  String _currentUserId = '';

  Future<void> _onLoadData(
    NotificationsLoadData event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final userResult = await _authRepository.getCurrentUser();
    await userResult.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        ));
      },
      (user) async {
        _currentUserId = user.id;
        await _notificationsSub?.cancel();
        _notificationsSub = _projectRepository
            .watchNotifications(userId: user.id)
            .listen((result) {
          result.fold(
            (failure) => add(NotificationsStreamFailed(failure.message)),
            (notifications) => add(NotificationsStreamUpdated(notifications)),
          );
        });
      },
    );
  }

  void _onStreamUpdated(
    NotificationsStreamUpdated event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      notifications: event.notifications.map(_mapNotification).toList(),
      errorMessage: () => null,
    ));
  }

  void _onStreamFailed(
    NotificationsStreamFailed event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: () => event.message,
    ));
  }

  Future<void> _onNotificationTapped(
    NotificationTapped event,
    Emitter<NotificationsState> emit,
  ) async {
    NotificationItem? tapped;
    for (final item in state.notifications) {
      if (item.id == event.notificationId) {
        tapped = item;
        break;
      }
    }

    final updatedNotifications = state.notifications.map((n) {
      if (n.id == event.notificationId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(
      notifications: updatedNotifications,
      navigation: () => _resolveNavigation(tapped),
    ));

    final result =
        await _projectRepository.markNotificationRead(notificationId: event.notificationId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: () => failure.message)),
      (_) {},
    );

  }

  void _onNavigationHandled(
    NotificationsNavigationHandled event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(navigation: () => null));
  }

  Future<void> _onNotificationDismissed(
    NotificationDismissed event,
    Emitter<NotificationsState> emit,
  ) async {
    final updatedNotifications = state.notifications
        .where((n) => n.id != event.notificationId)
        .toList();

    emit(state.copyWith(notifications: updatedNotifications));

    final result =
        await _projectRepository.deleteNotification(notificationId: event.notificationId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: () => failure.message)),
      (_) {},
    );
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final updatedNotifications = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(state.copyWith(notifications: updatedNotifications));

    if (_currentUserId.isEmpty) return;

    final result =
        await _projectRepository.markAllNotificationsRead(userId: _currentUserId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: () => failure.message)),
      (_) {},
    );
  }

  NotificationItem _mapNotification(AppNotification notification) {
    return NotificationItem(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: _mapNotificationType(notification.type),
      createdAt: notification.createdAt,
      isRead: notification.isRead,
      relatedTaskId: notification.relatedTaskId,
      relatedProjectId: notification.relatedProjectId,
    );
  }

  NotificationNavigation? _resolveNavigation(NotificationItem? notification) {
    if (notification == null) return null;

    switch (notification.type) {
      case NotificationType.taskAssigned:
      case NotificationType.taskCompleted:
      case NotificationType.comment:
      case NotificationType.mention:
      case NotificationType.deadline:
        if (notification.relatedTaskId == null ||
            notification.relatedTaskId!.isEmpty) {
          return null;
        }
        return NotificationNavigation(
          route: RouteConstants.taskDetails,
          argument: notification.relatedTaskId,
        );
      case NotificationType.projectInvite:
        return const NotificationNavigation(route: RouteConstants.dashboard);
    }
  }

  NotificationType _mapNotificationType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.taskAssigned:
        return NotificationType.taskAssigned;
      case AppNotificationType.taskCompleted:
        return NotificationType.taskCompleted;
      case AppNotificationType.comment:
        return NotificationType.comment;
      case AppNotificationType.mention:
        return NotificationType.mention;
      case AppNotificationType.deadline:
        return NotificationType.deadline;
      case AppNotificationType.projectInvite:
        return NotificationType.projectInvite;
      case AppNotificationType.unknown:
        return NotificationType.comment;
    }
  }

  @override
  Future<void> close() async {
    await _notificationsSub?.cancel();
    return super.close();
  }
}
