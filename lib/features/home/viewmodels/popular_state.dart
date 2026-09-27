import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../../properties/models/property.dart';

/// State of the "Popular" list ViewModel.
class PopularState extends Equatable {
  const PopularState({
    this.status = RequestStatus.initial,
    this.properties = const [],
    this.failure,
  });

  final RequestStatus status;

  /// The full "Popular for you" membership, in design order.
  final List<Property> properties;

  /// Set only when the list could not be loaded.
  final Failure? failure;

  bool get isLoading => status == RequestStatus.loading;

  bool get hasFailed => status == RequestStatus.failure;

  PopularState copyWith({
    RequestStatus? status,
    List<Property>? properties,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return PopularState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, properties, failure];
}
