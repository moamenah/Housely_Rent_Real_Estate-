import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../repositories/property_repository.dart';
import 'property_details_state.dart';

/// ViewModel of the listing detail screen.
///
/// Created by `PropertyDetailsView` through `BlocProvider`, so it is scoped to
/// that route and disposed with it.
class PropertyDetailsCubit extends Cubit<PropertyDetailsState> {
  PropertyDetailsCubit({required PropertyRepository repository})
      : _repository = repository,
        super(const PropertyDetailsState());

  final PropertyRepository _repository;

  Future<void> load(String propertyId) async {
    emit(state.copyWith(status: RequestStatus.loading, clearFailure: true));
    try {
      final property = await _repository.getPropertyById(propertyId);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          property: property,
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
}
