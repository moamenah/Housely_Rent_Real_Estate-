import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/place.dart';

/// State of the map picker ViewModel.
///
/// Two async paths run on this screen and they report differently: the
/// *pinned place* load drives the card itself (`RequestStatus`, with an
/// inline retry when it fails), while the *search* only toggles a spinner
/// and escalates its problems to a snackbar banner.
class LocationPickerState extends Equatable {
  const LocationPickerState({
    this.status = RequestStatus.initial,
    this.place,
    this.query = '',
    this.isSearching = false,
    this.failure,
  });

  /// Lifecycle of the initial pin load (and later retries).
  final RequestStatus status;

  /// Address shown on the "Location Details" card.
  final Place? place;

  /// Text currently in the search field.
  final String query;

  /// A search request is in flight (spinner in the field's suffix).
  final bool isSearching;

  /// Set for failures that surface as snackbar banners.
  final Failure? failure;

  bool get isLoadingPlace => status == RequestStatus.loading;

  bool get hasPlace => place != null;

  /// The CTA only enables once there is an address and no search is running.
  bool get canChoose => hasPlace && !isSearching;

  LocationPickerState copyWith({
    RequestStatus? status,
    Place? place,
    String? query,
    bool? isSearching,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return LocationPickerState(
      status: status ?? this.status,
      place: place ?? this.place,
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, place, query, isSearching, failure];
}
