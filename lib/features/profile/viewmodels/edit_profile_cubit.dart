import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/utils/form_validators.dart';
import '../repositories/profile_repository.dart';
import 'edit_profile_state.dart';

/// ViewModel of the Edit Profile form.
///
/// Local validation decides *field* errors; anything the repository throws
/// becomes a [Failure] the View announces as a banner. The date of birth is
/// chosen through a date picker, so it arrives as a value change instead of
/// text.
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const EditProfileState());

  final ProfileRepository _profileRepository;

  /// Fills the form from the stored account.
  Future<void> load() async {
    emit(state.copyWith(
      loadStatus: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final profile = await _profileRepository.getProfile();
      emit(state.copyWith(
        loadStatus: RequestStatus.success,
        profile: profile,
        name: profile.name,
        username: profile.username,
        email: profile.email,
        dateOfBirth: profile.dateOfBirth,
      ));
    } catch (error) {
      emit(state.copyWith(
        loadStatus: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }

  void nameChanged(String value) =>
      emit(state.copyWith(name: value, clearNameError: true));

  void usernameChanged(String value) =>
      emit(state.copyWith(username: value, clearUsernameError: true));

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearEmailError: true));

  void dateOfBirthChanged(DateTime value) => emit(state.copyWith(
        dateOfBirth: value,
        clearDateOfBirthError: true,
        clearFailure: true,
      ));

  /// Validates every field, then persists. Local errors never touch
  /// [EditProfileState.saveStatus] — the design shows them inline.
  Future<void> save() async {
    final nameError = FormValidators.notBlank(state.name, 'Name');
    final usernameError = FormValidators.notBlank(state.username, 'Username');
    final emailError = FormValidators.email(state.email);
    final dateOfBirthError =
        state.dateOfBirth == null ? 'Date of birth is required.' : null;

    if (nameError != null ||
        usernameError != null ||
        emailError != null ||
        dateOfBirthError != null) {
      emit(state.copyWith(
        nameError: nameError,
        usernameError: usernameError,
        emailError: emailError,
        dateOfBirthError: dateOfBirthError,
      ));
      return;
    }

    emit(state.copyWith(
      saveStatus: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final profile = await _profileRepository.updateProfile(
        name: state.name,
        username: state.username,
        email: state.email,
        dateOfBirth: state.dateOfBirth,
      );
      emit(state.copyWith(
        saveStatus: RequestStatus.success,
        profile: profile,
        name: profile.name,
        username: profile.username,
        email: profile.email,
        dateOfBirth: profile.dateOfBirth,
      ));
    } catch (error) {
      emit(state.copyWith(
        saveStatus: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }
}
