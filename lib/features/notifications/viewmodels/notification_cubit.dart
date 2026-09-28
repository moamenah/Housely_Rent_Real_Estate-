import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../repositories/notification_repository.dart';
import 'notification_state.dart';

/// ViewModel of the Notification inbox.
///
/// Loads the day-groups once per visit; rows and the back arrow are pure
/// rendering/navigation in the View, so they stay out of the ViewModel.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(const NotificationState());

  final NotificationRepository _notificationRepository;

  Future<void> load() async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final sections = await _notificationRepository.getNotifications();
      emit(state.copyWith(status: RequestStatus.success, sections: sections));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }
}
