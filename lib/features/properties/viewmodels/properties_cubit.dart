import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';
import 'properties_state.dart';

/// ViewModel of the property feed.
///
/// Owns the async flow for `PropertiesView`: load → success/failure, plus
/// client-side search. It is the only class that talks to the repository —
/// the View never awaits anything, it only renders [PropertiesState].
class PropertiesCubit extends Cubit<PropertiesState> {
  PropertiesCubit({required PropertyRepository repository})
      : _repository = repository,
        super(const PropertiesState());

  final PropertyRepository _repository;

  /// First load / retry after a failure.
  Future<void> fetchProperties() async {
    emit(state.copyWith(status: RequestStatus.loading, clearFailure: true));
    try {
      final properties = await _repository.getProperties();
      emit(
        state.copyWith(
          status: RequestStatus.success,
          properties: properties,
          clearFailure: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          failure: FailureMapper.map(error),
        ),
      );
    }
  }

  /// Pull-to-refresh: keeps the current data on screen while re-fetching.
  Future<void> refresh() => fetchProperties();

  /// Live search, filtered in [PropertiesState.visibleProperties].
  void setQuery(String query) => emit(state.copyWith(query: query));

  void clearQuery() => emit(state.copyWith(query: ''));

  /// Convenience used by tests and by `Retry` affordances on empty states.
  Property? findById(String id) {
    for (final property in state.properties) {
      if (property.id == id) return property;
    }
    return null;
  }
}
