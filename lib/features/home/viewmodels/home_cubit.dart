import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../repositories/home_repository.dart';
import 'home_state.dart';

/// ViewModel of the Home tab.
///
/// Loads the feed once when the branch mounts, tracks the highlighted
/// destination chip, and maps data-source errors to user-facing [Failure]s —
/// the same contract every other ViewModel in the app honours.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(const HomeState());

  final HomeRepository _homeRepository;

  Future<void> load() async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final feed = await _homeRepository.getFeed();
      emit(state.copyWith(status: RequestStatus.success, feed: feed));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }

  /// Highlights the tapped destination chip (visual only for now).
  void selectTopLocation(int index) {
    if (index == state.selectedTopLocation) return;
    emit(state.copyWith(selectedTopLocation: index));
  }
}
