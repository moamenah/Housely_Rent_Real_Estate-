import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../repositories/home_repository.dart';
import 'popular_state.dart';

/// ViewModel of the pushed "Popular" screen.
///
/// Reads the same composed feed as the Home tab — the screen is simply the
/// untruncated "Popular for you" section — and maps repository errors to a
/// user-facing [Failure] like every other ViewModel.
class PopularCubit extends Cubit<PopularState> {
  PopularCubit({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(const PopularState());

  final HomeRepository _homeRepository;

  Future<void> load() async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final feed = await _homeRepository.getFeed();
      emit(state.copyWith(
        status: RequestStatus.success,
        properties: feed.popular,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }
}
