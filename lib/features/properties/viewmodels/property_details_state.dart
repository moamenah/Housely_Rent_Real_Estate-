import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/property.dart';

/// State of the listing detail ViewModel.
class PropertyDetailsState extends Equatable {
  const PropertyDetailsState({
    this.status = RequestStatus.initial,
    this.property,
    this.failure,
  });

  final RequestStatus status;
  final Property? property;
  final Failure? failure;

  bool get isLoading => status == RequestStatus.loading;
  bool get hasError => status == RequestStatus.failure;
  bool get isReady => status == RequestStatus.success && property != null;

  PropertyDetailsState copyWith({
    RequestStatus? status,
    Property? property,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return PropertyDetailsState(
      status: status ?? this.status,
      property: property ?? this.property,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, property, failure];
}
