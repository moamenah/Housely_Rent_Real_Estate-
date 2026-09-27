import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/property.dart';

/// State of the property feed ViewModel.
///
/// One sealed-ish shape for the whole screen: status + data + last failure,
/// with derived getters so the View never filters or checks flags itself.
class PropertiesState extends Equatable {
  const PropertiesState({
    this.status = RequestStatus.initial,
    this.properties = const [],
    this.query = '',
    this.failure,
  });

  final RequestStatus status;

  /// All listings returned by the repository.
  final List<Property> properties;

  /// Current search text (title / location / type).
  final String query;

  /// Populated only when [status] is [RequestStatus.failure].
  final Failure? failure;

  bool get isLoading => status == RequestStatus.loading;
  bool get isRefreshing => status == RequestStatus.loading && properties.isNotEmpty;
  bool get hasError => status == RequestStatus.failure;
  bool get hasData => status == RequestStatus.success;

  /// Listings that survive the current [query] — what the View renders.
  List<Property> get visibleProperties {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return properties;
    return properties
        .where(
          (property) =>
              property.title.toLowerCase().contains(trimmed) ||
              property.location.toLowerCase().contains(trimmed) ||
              property.type.label.toLowerCase().contains(trimmed),
        )
        .toList(growable: false);
  }

  /// Highlighted listings for the "Featured" rail.
  List<Property> get featuredProperties => visibleProperties
      .where((property) => property.isFeatured)
      .toList(growable: false);

  /// The single listing with [id] — joins like the booking checkout use
  /// this instead of filtering in the view.
  Property? propertyById(String id) {
    for (final property in properties) {
      if (property.id == id) return property;
    }
    return null;
  }

  bool get isEmpty => hasData && visibleProperties.isEmpty;

  PropertiesState copyWith({
    RequestStatus? status,
    List<Property>? properties,
    String? query,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return PropertiesState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      query: query ?? this.query,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, properties, query, failure];
}
