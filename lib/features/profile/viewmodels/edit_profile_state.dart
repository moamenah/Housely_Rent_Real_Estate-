import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/profile.dart';

/// State of the Edit Profile ViewModel.
///
/// Three concerns, three slots each: the *load* fills the form, per-field
/// *errors* come from local validation, and *save* carries its own lifecycle
/// plus a [Failure] for anything transport-scoped.
class EditProfileState extends Equatable {
  const EditProfileState({
    this.loadStatus = RequestStatus.initial,
    this.profile,
    this.name = '',
    this.username = '',
    this.email = '',
    this.dateOfBirth,
    this.nameError,
    this.usernameError,
    this.emailError,
    this.dateOfBirthError,
    this.saveStatus = RequestStatus.initial,
    this.failure,
  });

  /// Lifecycle of the initial profile load.
  final RequestStatus loadStatus;

  /// Snapshot the form was pre-filled from.
  final Profile? profile;

  final String name;
  final String username;
  final String email;
  final DateTime? dateOfBirth;

  /// Inline messages, rendered under the respective field.
  final String? nameError;
  final String? usernameError;
  final String? emailError;
  final String? dateOfBirthError;

  /// Lifecycle of *Save Change* (loading → success | failure).
  final RequestStatus saveStatus;

  /// Save problems that are not field-scoped → snackbar, never a red border.
  final Failure? failure;

  bool get isLoadingProfile => loadStatus == RequestStatus.loading;

  bool get loadFailed => loadStatus == RequestStatus.failure;

  bool get isSaving => saveStatus == RequestStatus.loading;

  /// Save finished — the View confirms and steps back to Profile.
  bool get isSaved => saveStatus == RequestStatus.success;

  bool get saveFailed => saveStatus == RequestStatus.failure;

  bool get hasFieldErrors =>
      nameError != null ||
      usernameError != null ||
      emailError != null ||
      dateOfBirthError != null;

  EditProfileState copyWith({
    RequestStatus? loadStatus,
    Profile? profile,
    String? name,
    String? username,
    String? email,
    DateTime? dateOfBirth,
    String? nameError,
    String? usernameError,
    String? emailError,
    String? dateOfBirthError,
    RequestStatus? saveStatus,
    Failure? failure,
    bool clearNameError = false,
    bool clearUsernameError = false,
    bool clearEmailError = false,
    bool clearDateOfBirthError = false,
    bool clearFailure = false,
  }) {
    return EditProfileState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nameError: clearNameError ? null : nameError ?? this.nameError,
      usernameError:
          clearUsernameError ? null : usernameError ?? this.usernameError,
      emailError: clearEmailError ? null : emailError ?? this.emailError,
      dateOfBirthError: clearDateOfBirthError
          ? null
          : dateOfBirthError ?? this.dateOfBirthError,
      saveStatus: saveStatus ?? this.saveStatus,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        profile,
        name,
        username,
        email,
        dateOfBirth,
        nameError,
        usernameError,
        emailError,
        dateOfBirthError,
        saveStatus,
        failure,
      ];
}
