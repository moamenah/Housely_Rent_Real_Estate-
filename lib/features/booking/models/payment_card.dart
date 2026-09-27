import 'package:equatable/equatable.dart';

/// A saved payment method shown on the Booking screen as "...........1121".
///
/// The design ships one brand (the Mastercard mark), so the card is carried
/// around by cardholder, grouped number and expiry. The number stays inside
/// the checkout session — nothing is persisted or sent anywhere in this build.
class PaymentCard extends Equatable {
  const PaymentCard({
    required this.cardholder,
    required this.number,
    required this.expiry,
  });

  /// Cardholder name as typed on the Add Card form.
  final String cardholder;

  /// Grouped digits, e.g. `1234 5678 9101 1121`.
  final String number;

  /// Expiry in `MM/YY`, e.g. `06/21`.
  final String expiry;

  /// Digits only, separators stripped.
  String get digits => number.replaceAll(RegExp(r'\D'), '');

  /// Last four digits of the number (`1121`).
  String get last4 {
    final all = digits;
    return all.length <= 4 ? all : all.substring(all.length - 4);
  }

  /// The mockup's saved-card row: eleven dots followed by [last4].
  String get masked => '${'.' * 11}$last4';

  @override
  List<Object?> get props => [cardholder, number, expiry];
}
