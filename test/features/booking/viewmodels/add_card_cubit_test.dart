import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/features/booking/models/payment_card.dart';
import 'package:housely/features/booking/viewmodels/add_card_cubit.dart';

void main() {
  AddCardCubit buildCubit({PaymentCard? initialCard}) =>
      AddCardCubit(initialCard: initialCard);

  test('starts from the mockup sample card', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.cardholder, 'Brooklyn Simmons');
    expect(cubit.state.number, '1234 5678 9101 1121');
    expect(cubit.state.expiry, '06/21');
    expect(cubit.state.cvv, '3134');
    expect(cubit.state.errors, isEmpty);
    expect(cubit.state.isValidated, isFalse);
  });

  test('an invalid submit reports every bad field', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.cardholderChanged('');
    cubit.numberChanged('1234');
    cubit.expiryChanged('13/99');
    cubit.cvvChanged('12');
    cubit.submit();

    expect(
      cubit.state.errors.keys,
      containsAll(['cardholder', 'number', 'expiry', 'cvv']),
    );
    expect(cubit.state.isValidated, isFalse);
    expect(cubit.state.status, RequestStatus.initial);
  });

  test('errors clear per field as it is retyped', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.numberChanged('1234');
    cubit.submit();
    expect(cubit.state.errorFor('number'), isNotNull);

    cubit.numberChanged('1234 5678 9101 1121');
    expect(cubit.state.errorFor('number'), isNull);
    expect(cubit.state.errors, isEmpty);

    cubit.submit();
    expect(cubit.state.isValidated, isTrue);
  });

  test('a valid submit validates and builds the card', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.submit();

    expect(cubit.state.isValidated, isTrue);
    expect(cubit.state.errors, isEmpty);

    final card = cubit.state.asCard;
    expect(card.cardholder, 'Brooklyn Simmons');
    expect(card.digits, '1234567891011121');
    expect(card.last4, '1121');
    expect(card.masked, '...........1121');
  });

  test('editing an attached card seeds the known fields, never the CVV', () {
    final cubit = buildCubit(
      initialCard: const PaymentCard(
        cardholder: 'Ada Lovelace',
        number: '4111 1111 1111 1111',
        expiry: '09/27',
      ),
    );
    addTearDown(cubit.close);

    expect(cubit.state.cardholder, 'Ada Lovelace');
    expect(cubit.state.number, '4111 1111 1111 1111');
    expect(cubit.state.expiry, '09/27');
    expect(cubit.state.cvv, isEmpty);

    cubit.submit();

    expect(cubit.state.errors.keys, ['cvv']);
    expect(cubit.state.isValidated, isFalse);
  });
}
