import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../models/payment_card.dart';

/// State of the Add Card form ViewModel.
///
/// Defaults are the mockup's filled-in sample card; editing an attached card
/// seeds the form from it (the CVV is never stored, so it starts empty).
/// Validation errors live in one map — `null`/missing means "no complaint".
class AddCardState extends Equatable {
  const AddCardState({
    this.cardholder = 'Brooklyn Simmons',
    this.number = '1234 5678 9101 1121',
    this.expiry = '06/21',
    this.cvv = '3134',
    this.errors = const {},
    this.status = RequestStatus.initial,
  });

  factory AddCardState.forCard(PaymentCard? card) {
    if (card == null) return const AddCardState();
    return AddCardState(
      cardholder: card.cardholder,
      number: card.number,
      expiry: card.expiry,
      cvv: '',
    );
  }

  final String cardholder;
  final String number;
  final String expiry;
  final String cvv;

  /// Field name → message for the fields that failed [AddCardCubit.submit].
  final Map<String, String> errors;

  /// Flips to [RequestStatus.success] once the form validates — the view
  /// listens for it, attaches the card and pops back to the checkout.
  final RequestStatus status;

  bool get isValidated => status == RequestStatus.success;

  String? errorFor(String field) => errors[field];

  /// The card this form would save.
  PaymentCard get asCard => PaymentCard(
        cardholder: cardholder.trim(),
        number: number.trim(),
        expiry: expiry.trim(),
      );

  AddCardState copyWith({
    String? cardholder,
    String? number,
    String? expiry,
    String? cvv,
    Map<String, String>? errors,
    RequestStatus? status,
  }) {
    return AddCardState(
      cardholder: cardholder ?? this.cardholder,
      number: number ?? this.number,
      expiry: expiry ?? this.expiry,
      cvv: cvv ?? this.cvv,
      errors: errors ?? this.errors,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [cardholder, number, expiry, cvv, errors, status];
}
