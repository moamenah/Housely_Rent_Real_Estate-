import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../repositories/location_repository.dart';
import 'location_picker_state.dart';

/// ViewModel of the "Location Details" map screen.
///
/// Responsibilities: resolve the address the pin opens on, honour searches
/// typed into the bar, and translate transport failures into a [Failure] the
/// View can announce — navigation itself stays in the View.
class LocationPickerCubit extends Cubit<LocationPickerState> {
  LocationPickerCubit({required LocationRepository locationRepository})
      : _locationRepository = locationRepository,
        super(const LocationPickerState());

  final LocationRepository _locationRepository;

  /// Loads the address the pin rests on (also used by the inline retry).
  Future<void> loadPinnedPlace() async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final place = await _locationRepository.getPinnedPlace();
      emit(state.copyWith(status: RequestStatus.success, place: place));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }

  /// Keeps the field value in state; no request until the user submits.
  void queryChanged(String query) =>
      emit(state.copyWith(query: query, clearFailure: true));

  /// Resolves the typed query. An empty/whitespace query is a no-op — there
  /// is nothing to ask the backend for.
  Future<void> search() async {
    final query = state.query.trim();
    if (query.isEmpty || state.isSearching) return;

    emit(state.copyWith(isSearching: true, clearFailure: true));
    try {
      final place = await _locationRepository.searchPlace(query: query);
      emit(state.copyWith(
        status: RequestStatus.success,
        place: place,
        isSearching: false,
      ));
    } catch (error) {
      // The previous address stays on the card — a failed lookup must not
      // blank out a place the user could already have chosen.
      emit(state.copyWith(
        isSearching: false,
        failure: FailureMapper.map(error),
      ));
    }
  }
}
