import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/utils/form_validators.dart';
import '../repositories/auth_repository.dart';
import 'login_state.dart';

/// ViewModel of the login screen.
///
/// Owns the form: field values, per-field validation, the submit lifecycle and
/// the distinction between "wrong password" (inline) and "could not reach the
/// service" (banner). It never shows a full-screen error — a failed login is a
/// recoverable, in-place condition.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState());

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearEmailError: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearPasswordError: true));
  }

  void toggleObscurePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleRememberMe() {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  Future<void> submit() async {
    // Re-entry guard: a double tap while the request is in flight is a no-op.
    if (state.isLoading) return;

    final emailError = FormValidators.email(state.email);
    final passwordError = FormValidators.notBlank(state.password, 'Password');

    // One state is built up-front so validation never needs a second emit.
    final validated = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      clearEmailError: emailError == null,
      clearPasswordError: passwordError == null,
      clearFailure: true,
    );

    if (emailError != null || passwordError != null) {
      emit(validated.copyWith(status: RequestStatus.initial));
      return;
    }

    emit(validated.copyWith(status: RequestStatus.loading));
    try {
      final user = await _authRepository.signIn(
        email: validated.email,
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
      final failure = FailureMapper.map(error);
      final rejectedCredentials = failure is AuthFailure;
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          // Rejected credentials belong under the password field; anything
          // else keeps the fields clean and surfaces as a snackbar.
          passwordError: rejectedCredentials ? failure.message : null,
          clearPasswordError: !rejectedCredentials,
          failure: rejectedCredentials ? null : failure,
          clearFailure: rejectedCredentials,
        ),
      );
    }
  }
}
