import 'package:equatable/equatable.dart';

/// One masked destination the reset code can be sent to.
///
/// The server only ever hands a logged-out client the *masked* form — the
/// raw phone number / address stays on the backend, which is also what makes
/// this screen safe to show before anyone has authenticated.
class RecoveryContact extends Equatable {
  const RecoveryContact({
    required this.id,
    required this.label,
    required this.maskedValue,
  });

  /// Backend key for the destination ('phone', 'email').
  final String id;

  /// Row caption from the design ('Via phone', 'Via email').
  final String label;

  /// Already-masked display value ('mu***@gmail.com').
  final String maskedValue;

  @override
  List<Object?> get props => [id, label, maskedValue];
}
