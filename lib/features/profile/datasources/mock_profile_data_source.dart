import '../models/profile.dart';
import 'profile_data_source.dart';

/// Offline account store — the Brooklyn Simmons profile from the design.
///
/// Latency is simulated so the loading/saving states on both screens are
/// real rather than instant flips.
class MockProfileDataSource implements ProfileDataSource {
  MockProfileDataSource({
    this.readLatency = const Duration(milliseconds: 600),
    this.writeLatency = const Duration(milliseconds: 700),
  });

  final Duration readLatency;
  final Duration writeLatency;

  @override
  Future<Profile> getProfile() async {
    await Future<void>.delayed(readLatency);
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
    await Future<void>.delayed(writeLatency);
    return Profile(
      name: name,
      username: username,
      email: email,
      dateOfBirth: dateOfBirth,
    );
  }
}
