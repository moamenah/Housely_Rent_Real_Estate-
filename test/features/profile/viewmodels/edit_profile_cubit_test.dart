import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/profile/models/profile.dart';
import 'package:housely/features/profile/repositories/profile_repository.dart';
import 'package:housely/features/profile/viewmodels/edit_profile_cubit.dart';

/// Behavioural fake mirroring the real repository's contract (trimming
/// happens here, failures are armed by the test).
class _FakeProfileRepository implements ProfileRepository {
  bool failLoad = false;
  bool failSave = false;
  int saveCalls = 0;

  Profile storedProfile = Profile(
    name: 'Brooklyn Simmons',
    username: 'brooklynsim',
    email: 'brooklynsim@gmail.com',
    dateOfBirth: DateTime(1992, 11, 21),
  );

  @override
  Future<Profile> getProfile() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return storedProfile;
  }

  @override
  Future<Profile> updateProfile({
    required String name,
    required String username,
    required String email,
    required DateTime? dateOfBirth,
  }) async {
    await Future<void>.delayed(Duration.zero);
    saveCalls++;
    if (failSave) {
      throw const NetworkException();
    }
    storedProfile = Profile(
      name: name.trim(),
      username: username.trim(),
      email: email.trim(),
      dateOfBirth: dateOfBirth,
    );
    return storedProfile;
  }
}

void main() {
  late _FakeProfileRepository repository;

  EditProfileCubit buildCubit() =>
      EditProfileCubit(profileRepository: repository);

  Future<EditProfileCubit> loadedCubit() async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();
    return cubit;
  }

  setUp(() {
    repository = _FakeProfileRepository();
  });

  group('load', () {
    test('pre-fills every field from the stored account', () async {
      final cubit = await loadedCubit();

      expect(cubit.state.loadStatus, RequestStatus.success);
      expect(cubit.state.name, 'Brooklyn Simmons');
      expect(cubit.state.username, 'brooklynsim');
      expect(cubit.state.email, 'brooklynsim@gmail.com');
      expect(cubit.state.dateOfBirth, DateTime(1992, 11, 21));
      expect(cubit.state.hasFieldErrors, isFalse);
    });

    test('a transport failure becomes a banner failure', () async {
      repository.failLoad = true;
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.loadStatus, RequestStatus.failure);
      expect(cubit.state.profile, isNull);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });
  });

  group('local validation', () {
    test('empty fields render inline errors without a round-trip', () async {
      final cubit = await loadedCubit();

      cubit.nameChanged('');
      cubit.usernameChanged('');
      cubit.emailChanged('');
      await cubit.save();

      expect(cubit.state.nameError, 'Name is required.');
      expect(cubit.state.usernameError, 'Username is required.');
      expect(cubit.state.emailError, 'Email is required.');
      // A stored date satisfies the requirement — no fourth error.
      expect(cubit.state.dateOfBirthError, isNull);
      expect(cubit.state.saveStatus, RequestStatus.initial);
      expect(repository.saveCalls, 0);
    });

    test('a malformed email is rejected inline', () async {
      final cubit = await loadedCubit();

      cubit.emailChanged('not-an-email');
      await cubit.save();

      expect(cubit.state.emailError, 'Enter a valid email address.');
      expect(repository.saveCalls, 0);
    });

    test('editing a field clears only its own error', () async {
      final cubit = await loadedCubit();
      cubit.nameChanged('');
      cubit.emailChanged('');
      await cubit.save();
      expect(cubit.state.nameError, isNotNull);
      expect(cubit.state.emailError, isNotNull);

      cubit.nameChanged('Brooklyn Simmons');

      expect(cubit.state.nameError, isNull);
      expect(cubit.state.emailError, isNotNull);
    });

    test('a profile without a date must pick one before saving', () async {
      repository.storedProfile = const Profile(
        name: 'Brooklyn Simmons',
        username: 'brooklynsim',
        email: 'brooklynsim@gmail.com',
      );
      final cubit = await loadedCubit();

      await cubit.save();

      expect(cubit.state.dateOfBirthError, 'Date of birth is required.');
      expect(repository.saveCalls, 0);

      cubit.dateOfBirthChanged(DateTime(1993, 3, 14));

      expect(cubit.state.dateOfBirthError, isNull);
      await cubit.save();
      expect(repository.saveCalls, 1);
      expect(cubit.state.saveStatus, RequestStatus.success);
    });
  });

  group('save', () {
    test('persists the edited values and reports success', () async {
      final cubit = await loadedCubit();

      cubit.nameChanged('  Brooklyn Simmons Jr  ');
      await cubit.save();

      expect(cubit.state.saveStatus, RequestStatus.success);
      // The repository contract trims — the state mirrors the stored result.
      expect(cubit.state.profile?.name, 'Brooklyn Simmons Jr');
      expect(cubit.state.name, 'Brooklyn Simmons Jr');
      expect(cubit.state.failure, isNull);
    });

    test('a transport failure is a banner failure, never a field error',
        () async {
      final cubit = await loadedCubit();
      repository.failSave = true;

      await cubit.save();

      expect(cubit.state.saveStatus, RequestStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure>());
      expect(cubit.state.hasFieldErrors, isFalse);
      expect(repository.saveCalls, 1);
    });

    test('a fixed form saves on the second attempt', () async {
      final cubit = await loadedCubit();
      repository.failSave = true;
      await cubit.save();
      expect(cubit.state.saveFailed, isTrue);

      repository.failSave = false;
      cubit.usernameChanged('brooklyn');
      await cubit.save();

      expect(cubit.state.isSaved, isTrue);
      expect(cubit.state.failure, isNull);
    });
  });
}
