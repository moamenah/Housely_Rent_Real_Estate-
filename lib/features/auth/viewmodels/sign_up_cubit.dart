import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/utils/form_validators.dart';
import '../repositories/auth_repository.dart';
import 'sign_up_state.dart';

/// ViewModel of the register screen.
///
/// Owns the form: field values, per-field validation, the agree-to-terms gate
/// and the submit lifecycle. Unlike sign-in there is no credential to reject,
/// so every repository failure is transport/policy-scoped and surfaces as a
/// banner — never as a red border.
class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SignUpState());

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearEmailError: true));
  }

  void usernameChanged(String value) {
    emit(state.copyWith(username: value, clearUsernameError: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearPasswordError: true));
  }

  void toggleObscurePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleAgreeToTerms() {
    emit(
      state.copyWith(
        agreeToTerms: !state.agreeToTerms,
        // Any interaction with the box resets its error; submit re-raises it
        // if the box is still unticked when the form is sent.
        clearTermsError: true,
      ),
    );
  }

  Future<void> submit() async {
    // Re-entry guard: a double tap while the request is in flight is a no-op.
    if (state.isLoading) return;

    final emailError = FormValidators.email(state.email);
    final usernameError = FormValidators.notBlank(state.username, 'Username');
    final passwordError = FormValidators.notBlank(state.password, 'Password');
    final termsError =
        state.agreeToTerms ? null : 'You must agree to the terms to continue.';

    // One state is built up-front so validation never needs a second emit.
    final validated = state.copyWith(
      emailError: emailError,
      usernameError: usernameError,
      passwordError: passwordError,
      termsError: termsError,
      clearEmailError: emailError == null,
      clearUsernameError: usernameError == null,
      clearPasswordError: passwordError == null,
      clearTermsError: termsError == null,
      clearFailure: true,
    );

    final hasErrors = emailError != null ||
        usernameError != null ||
        passwordError != null ||
        termsError != null;

    if (hasErrors) {
      emit(validated.copyWith(status: RequestStatus.initial));
      return;
    }

    emit(validated.copyWith(status: RequestStatus.loading));
    try {
      final user = await _authRepository.signUp(
        email: validated.email,
        username: validated.username,
        password: validated.password,
      );
      emit(
        state.copyWith(
          status: RequestStatus.success,
          user: user,
          clearFailure: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          failure: FailureMapper.map(error),
        ),
      );
    }
  }
}
