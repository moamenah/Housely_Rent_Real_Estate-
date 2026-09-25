import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/profile/models/profile.dart';
import 'package:housely/features/profile/repositories/profile_repository.dart';
import 'package:housely/features/profile/viewmodels/profile_cubit.dart';

/// Behavioural fake: returns the demo account unless [failLoad] is armed.
class _FakeProfileRepository implements ProfileRepository {
  bool failLoad = false;

  @override
  Future<Profile> getProfile() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return Profile(
      name: 'Brooklyn Simmons',
      username: 'brooklynsim',
      email: 'brooklynsim@gmail.com',
      dateOfBirth: DateTime(1992, 11, 21),
    );
  }

  @override
  Future<Profile> updateProfile({
    required String name,
    required String username,
    required String email,
    required DateTime? dateOfBirth,
  }) async {
    await Future<void>.delayed(Duration.zero);
    return Profile(
      name: name,
      username: username,
      email: email,
      dateOfBirth: dateOfBirth,
    );
  }
}

void main() {
  late _FakeProfileRepository repository;

  ProfileCubit buildCubit() =>
      ProfileCubit(profileRepository: repository);

  setUp(() {
    repository = _FakeProfileRepository();
  });

  test('load fills the state with the stored account', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.status, RequestStatus.initial);

    await cubit.load();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.profile?.name, 'Brooklyn Simmons');
    expect(cubit.state.profile?.email, 'brooklynsim@gmail.com');
    expect(cubit.state.failure, isNull);
  });

  test('a transport failure becomes a banner failure with a retryable state',
      () async {
    repository.failLoad = true;
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, RequestStatus.failure);
    expect(cubit.state.profile, isNull);
    expect(cubit.state.failure, isA<NetworkFailure>());

    // The View's inline retry simply re-runs the same call.
    repository.failLoad = false;
    await cubit.load();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.profile, isNotNull);
    expect(cubit.state.failure, isNull);
  });
}
