import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/user.dart';

/// State of the login ViewModel.
///
/// Everything the form renders — field values, per-field validation errors,
/// visibility flags and the async lifecycle — lives here, so the View stays a
/// pure function of state.
class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.rememberMe = true,
    this.status = RequestStatus.initial,
    this.emailError,
    this.passwordError,
    this.failure,
    this.user,
  });

  final String email;
  final String password;

  /// Password field is masked (dot obscure) by default, as in the design.
  final bool obscurePassword;

  final bool rememberMe;

  final RequestStatus status;

  /// Rendered under the email field — set only for local validation problems.
  final String? emailError;

  /// Rendered under the password field. Set for local validation **and** for a
  /// rejected credential (that is exactly the error state in the design).
  final String? passwordError;

  /// Set only for failures that are *not* field-scoped (offline, server error)
  /// so the View can snackbar them instead of drawing a red border.
  final Failure? failure;

  final User? user;

  bool get isLoading => status == RequestStatus.loading;

  bool get isAuthenticated => status == RequestStatus.success;

  bool get hasFailed => status == RequestStatus.failure;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? rememberMe,
    RequestStatus? status,
    String? emailError,
    String? passwordError,
    Failure? failure,
    User? user,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearFailure = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      emailError: clearEmailError ? null : emailError ?? this.emailError,
      passwordError:
          clearPasswordError ? null : passwordError ?? this.passwordError,
      failure: clearFailure ? null : failure ?? this.failure,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        obscurePassword,
        rememberMe,
        status,
        emailError,
        passwordError,
        failure,
        user,
      ];
}
