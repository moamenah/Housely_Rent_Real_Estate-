import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/profile.dart';

/// State of the Profile tab ViewModel.
class ProfileState extends Equatable {
  const ProfileState({
    this.status = RequestStatus.initial,
    this.profile,
    this.failure,
  });

  /// Lifecycle of the account load.
  final RequestStatus status;
  final Profile? profile;

  /// Only set for failures (transport problems get a snackbar + retry).
  final Failure? failure;

  bool get isLoading => status == RequestStatus.loading;

  bool get isLoaded => status == RequestStatus.success;

  bool get hasFailed => status == RequestStatus.failure;

  ProfileState copyWith({
    RequestStatus? status,
    Profile? profile,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, profile, failure];
}
