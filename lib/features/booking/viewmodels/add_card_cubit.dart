import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../models/payment_card.dart';
import 'add_card_state.dart';

/// ViewModel of the Add Card form.
///
/// Purely local: the view's input formatters keep the text grouped
/// (`1234 5678 …`, `06/21`), and [submit] is the only gate — it validates
/// every field and flips [AddCardState.status] to success, at which point the
/// view attaches the card to the session and pops back to the checkout.
class AddCardCubit extends Cubit<AddCardState> {
  AddCardCubit({PaymentCard? initialCard})
      : super(AddCardState.forCard(initialCard));

  void cardholderChanged(String value) {
    emit(state.copyWith(
      cardholder: value,
      errors: _dropped(state.errors, 'cardholder'),
    ));
  }

  void numberChanged(String value) {
    emit(state.copyWith(
      number: value,
      errors: _dropped(state.errors, 'number'),
    ));
  }

  void expiryChanged(String value) {
    emit(state.copyWith(expiry: value, errors: _dropped(state.errors, 'expiry')));
  }

  void cvvChanged(String value) {
    emit(state.copyWith(cvv: value, errors: _dropped(state.errors, 'cvv')));
  }

  /// Validates all four fields; errors clear per-field as they are retyped.
  void submit() {
    final errors = <String, String>{};
    if (state.cardholder.trim().isEmpty) {
      errors['cardholder'] = 'Please enter the cardholder name.';
    }
    if (state.number.replaceAll(RegExp(r'\D'), '').length != 16) {
      errors['number'] = 'Enter the full 16-digit card number.';
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(state.expiry.trim())) {
      errors['expiry'] = 'Use the MM/YY format, e.g. 06/21.';
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(state.cvv.trim())) {
      errors['cvv'] = 'Enter the 3-4 digit CVV.';
    }

    emit(state.copyWith(
      errors: errors,
      status: errors.isEmpty ? RequestStatus.success : RequestStatus.initial,
    ));
  }

  /// Copy of [errors] without [field] (returns the same instance when the
  /// field had nothing to clear, so no spurious emits happen).
  static Map<String, String> _dropped(Map<String, String> errors, String field) {
    if (!errors.containsKey(field)) return errors;
    return Map<String, String>.of(errors)..remove(field);
  }
}
