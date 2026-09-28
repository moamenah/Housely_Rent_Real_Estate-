import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/notification_item.dart';

/// State of the inbox ViewModel.
class NotificationState extends Equatable {
  const NotificationState({
    this.status = RequestStatus.initial,
    this.sections = const [],
    this.failure,
  });

  /// Lifecycle of the inbox load.
  final RequestStatus status;

  /// Day groups in mockup order; empty until the load succeeds.
  final List<NotificationSection> sections;

  /// Only set for failures (transport problems render the retry screen).
  final Failure? failure;

  bool get isLoading => status == RequestStatus.loading;

  bool get isLoaded => status == RequestStatus.success;

  bool get hasFailed => status == RequestStatus.failure;

  /// The design's "No notification yet" state: a successful load with
  /// nothing (or no non-empty groups) to show.
  bool get isEmpty =>
      sections.isEmpty || sections.every((section) => section.items.isEmpty);

  NotificationState copyWith({
    RequestStatus? status,
    List<NotificationSection>? sections,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, sections, failure];
}
