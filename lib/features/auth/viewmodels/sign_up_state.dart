import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/user.dart';

/// State of the sign-up ViewModel.
///
/// Mirrors [LoginState]: every value the register screen renders lives here,
/// so the View stays a pure function of state.
class SignUpState extends Equatable {
  const SignUpState({
    this.email = '',
    this.username = '',
    this.password = '',
    this.obscurePassword = true,
    // The design shows the box pre-ticked.
    this.agreeToTerms = true,
    this.status = RequestStatus.initial,
    this.emailError,
    this.usernameError,
    this.passwordError,
    this.termsError,
    this.failure,
    this.user,
  });

  final String email;
  final String username;
  final String password;

  /// Password field is masked (dot obscure) by default, as in the design.
  final bool obscurePassword;

  final bool agreeToTerms;

  final RequestStatus status;

  /// Rendered under the email field — set only for local validation problems.
  final String? emailError;

  /// Rendered under the username field.
  final String? usernameError;

  /// Rendered under the password field.
  final String? passwordError;

  /// Rendered under the "Agree with terms and privacy" row.
  final String? termsError;

  /// Set only for failures that are *not* field-scoped (offline, server error)
  /// so the View can snackbar them instead of drawing a red border.
  final Failure? failure;

  final User? user;

  bool get isLoading => status == RequestStatus.loading;

  bool get isRegistered => status == RequestStatus.success;

  bool get hasFailed => status == RequestStatus.failure;

  SignUpState copyWith({
    String? email,
    String? username,
    String? password,
    bool? obscurePassword,
    bool? agreeToTerms,
    RequestStatus? status,
    String? emailError,
    String? usernameError,
    String? passwordError,
    String? termsError,
    Failure? failure,
    User? user,
    bool clearEmailError = false,
    bool clearUsernameError = false,
    bool clearPasswordError = false,
    bool clearTermsError = false,
    bool clearFailure = false,
  }) {
    return SignUpState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      status: status ?? this.status,
      emailError: clearEmailError ? null : emailError ?? this.emailError,
      usernameError:
          clearUsernameError ? null : usernameError ?? this.usernameError,
      passwordError:
          clearPasswordError ? null : passwordError ?? this.passwordError,
      termsError: clearTermsError ? null : termsError ?? this.termsError,
      failure: clearFailure ? null : failure ?? this.failure,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        email,
        username,
        password,
        obscurePassword,
        agreeToTerms,
        status,
        emailError,
        usernameError,
        passwordError,
        termsError,
        failure,
        user,
      ];
}
