import 'package:equatable/equatable.dart';

/// The account shown on the Profile / Edit Profile screens.
class Profile extends Equatable {
  const Profile({
    required this.name,
    required this.username,
    required this.email,
    this.dateOfBirth,
  });

  final String name;
  final String username;
  final String email;
  final DateTime? dateOfBirth;

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Date exactly as the design writes it: `November/21/1992`.
  static String formatDateOfBirth(DateTime date) =>
      '${_months[date.month - 1]}/${date.day}/${date.year}';

  /// Same format, or a `Not set` placeholder when there is no date yet.
  String get dateOfBirthLabel => dateOfBirth == null
      ? 'Not set'
      : formatDateOfBirth(dateOfBirth!);

  Profile copyWith({
    String? name,
    String? username,
    String? email,
    DateTime? dateOfBirth,
  }) {
    return Profile(
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  @override
  List<Object?> get props => [name, username, email, dateOfBirth];
}
