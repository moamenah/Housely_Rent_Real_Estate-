import 'package:equatable/equatable.dart';

/// The signed-in user.
///
/// Deliberately minimal for now (no avatar/roles yet): it exists so the
/// ViewModel has a typed result to hold instead of `void`, and so the rest of
/// the app has something to attach to once a profile screen shows up.
class User extends Equatable {
  const User({required this.email, this.username});

  /// Canonical, already-trimmed email the session was created with.
  final String email;

  /// Chosen display name — present only after a sign-up (sign-in responses
  /// don't carry one yet).
  final String? username;

  @override
  List<Object?> get props => [email, username];
}
