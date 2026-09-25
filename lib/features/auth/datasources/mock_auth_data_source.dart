import 'dart:async';

import '../../../core/error/exceptions.dart';
import '../models/user.dart';
import 'auth_data_source.dart';

/// Offline stand-in for the auth API.
///
/// Demo credentials: **any** syntactically valid email + the password
/// `housely123`. Every other password is rejected with the exact message from
/// the design, so the error state can be exercised without a backend. Swapping
/// this for a real client happens in `core/di/injection.dart` only.
class MockAuthDataSource implements AuthDataSource {
  MockAuthDataSource({
    this.latency = const Duration(milliseconds: 700),
    this.demoPassword = 'housely123',
  });

  /// Simulated round-trip, so the button's loading state is real.
  final Duration latency;

  final String demoPassword;

  @override
  Future<User> signIn({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    if (password != demoPassword) {
      throw const InvalidCredentialsException();
    }
    return User(email: email);
  }

  @override
  Future<User> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    // No business rules to enforce yet: local validation already covers what
    // the design asks for, and the real API will own uniqueness/policy checks.
    return User(email: email, username: username);
  }
}
