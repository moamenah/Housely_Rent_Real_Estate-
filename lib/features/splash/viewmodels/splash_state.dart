import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';

/// State of the splash ViewModel.
///
/// Follows the app-wide `initial → loading → success | failure` contract:
/// `success` means "bootstrap finished, it is safe to enter the app".
class SplashState extends Equatable {
  const SplashState({
    this.status = RequestStatus.initial,
    this.failure,
  });

  final RequestStatus status;

  /// Only set when [status] is [RequestStatus.failure].
  final Failure? failure;

  bool get isLoading => status == RequestStatus.loading;

  /// Bootstrap finished — the View may navigate to the shell.
  bool get isReady => status == RequestStatus.success;

  bool get hasError => status == RequestStatus.failure;

  SplashState copyWith({
    RequestStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SplashState(
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}
