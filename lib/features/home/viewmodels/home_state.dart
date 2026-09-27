import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/home_feed.dart';

/// State of the Home ViewModel.
class HomeState extends Equatable {
  const HomeState({
    this.status = RequestStatus.initial,
    this.feed,
    this.failure,
    this.selectedTopLocation = baliIndex,
  });

  /// The design's Home mockup highlights Bali — the default selection keeps
  /// the first paint identical to the mockup.
  static const int baliIndex = 1;

  final RequestStatus status;
  final HomeFeed? feed;

  /// Set only when the feed could not be loaded.
  final Failure? failure;

  /// Index of the highlighted destination chip.
  final int selectedTopLocation;

  bool get isLoading => status == RequestStatus.loading;

  bool get isLoaded => status == RequestStatus.success;

  bool get hasFailed => status == RequestStatus.failure;

  HomeState copyWith({
    RequestStatus? status,
    HomeFeed? feed,
    Failure? failure,
    bool clearFailure = false,
    int? selectedTopLocation,
  }) {
    return HomeState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      failure: clearFailure ? null : failure ?? this.failure,
      selectedTopLocation: selectedTopLocation ?? this.selectedTopLocation,
    );
  }

  @override
  List<Object?> get props =>
      [status, feed, failure, selectedTopLocation];
}
