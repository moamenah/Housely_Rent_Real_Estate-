import '../datasources/auth_data_source.dart';
import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthDataSource dataSource})
      : _dataSource = dataSource;

  final AuthDataSource _dataSource;

  @override
  Future<User> signIn({required String email, required String password}) {
    // Normalization lives here (not in the data source): every transport —
    // mock, REST, OAuth — receives the same clean payload.
    return _dataSource.signIn(email: email.trim(), password: password);
  }

  @override
  Future<User> signUp({
    required String email,
    required String username,
    required String password,
  }) {
    return _dataSource.signUp(
      email: email.trim(),
      username: username.trim(),
      password: password,
    );
  }
}
