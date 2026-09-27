import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/views/widgets/auth_field.dart';
import '../viewmodels/add_card_cubit.dart';
import '../viewmodels/add_card_state.dart';
import '../viewmodels/booking_cubit.dart';

/// "Add Card" form from the mockup: the baked card artwork, four fields
/// seeded with the design's sample card, and the pinned "Add card" CTA.
///
/// Validates through [AddCardCubit]; once the form passes, the card is
/// attached to the checkout session and the route pops back to Booking.
class AddCardView extends StatelessWidget {
  const AddCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddCardCubit>(
      // Editing an attached card seeds from it; first run uses the
      // mockup's filled sample.
      create: (context) => AddCardCubit(
        initialCard: context.read<BookingCubit>().state.card,
      ),
      child: const _AddCardBody(),
    );
  }
}

class _AddCardBody extends StatefulWidget {
  const _AddCardBody();

  @override
  State<_AddCardBody> createState() => _AddCardBodyState();
}

class _AddCardBodyState extends State<_AddCardBody> {
  late final TextEditingController _cardholderController;
  late final TextEditingController _numberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;

  @override
  void initState() {
    super.initState();
    final initial = context.read<AddCardCubit>().state;
    _cardholderController = TextEditingController(text: initial.cardholder);
    _numberController = TextEditingController(text: initial.number);
    _expiryController = TextEditingController(text: initial.expiry);
    _cvvController = TextEditingController(text: initial.cvv);
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCardCubit, AddCardState>(
      listenWhen: (previous, current) =>
          current.isValidated && !previous.isValidated,
      listener: (context, state) {
        context.read<BookingCubit>().attachCard(state.asCard);
        context.pop();
      },
      builder: (context, state) {
        final cubit = context.read<AddCardCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Card'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.space16,
              AppDimensions.pagePadding,
              AppDimensions.space32,
            ),
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusXl),
                child: AspectRatio(
                  aspectRatio: 654 / 410,
                  child: Image.asset(
                    AppAssets.bookingCardArt,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              const AuthFieldLabel('Name'),
              const SizedBox(height: AppDimensions.space8),
              TextField(
                key: const Key('add_card_name_field'),
                controller: _cardholderController,
                style: authInputStyle,
                textInputAction: TextInputAction.next,
                onChanged: cubit.cardholderChanged,
                decoration: authInputDecoration(
                  errorText: state.errorFor('cardholder'),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              const AuthFieldLabel('Card Number'),
              const SizedBox(height: AppDimensions.space8),
              TextField(
                key: const Key('add_card_number_field'),
                controller: _numberController,
                style: authInputStyle,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [_cardNumberFormat],
                onChanged: cubit.numberChanged,
                decoration: authInputDecoration(
                  errorText: state.errorFor('number'),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthFieldLabel('Expired'),
                        const SizedBox(height: AppDimensions.space8),
                        TextField(
                          key: const Key('add_card_expiry_field'),
                          controller: _expiryController,
                          style: authInputStyle,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_expiryFormat],
                          onChanged: cubit.expiryChanged,
                          decoration: authInputDecoration(
                            errorText: state.errorFor('expiry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthFieldLabel('Cvv'),
                        const SizedBox(height: AppDimensions.space8),
                        TextField(
                          key: const Key('add_card_cvv_field'),
                          controller: _cvvController,
                          style: authInputStyle,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_digitsFormat],
                          onChanged: cubit.cvvChanged,
                          decoration: authInputDecoration(
                            errorText: state.errorFor('cvv'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.space12,
                AppDimensions.pagePadding,
                AppDimensions.space12,
              ),
              child: ElevatedButton(
                key: const Key('add_card_submit'),
                onPressed: cubit.submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    AppDimensions.buttonHeightLarge,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXl),
                  ),
                ),
                child: const Text('Add card'),
              ),
            ),
          ),
        );
      },
    );
  }

  /// `1234 5678 9101 1121` — digits grouped in fours, sixteen max.
  static final TextInputFormatter _cardNumberFormat =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final groups = <String>[];
    for (var i = 0; i < clipped.length; i += 4) {
      final end = i + 4 > clipped.length ? clipped.length : i + 4;
      groups.add(clipped.substring(i, end));
    }
    final text = groups.join(' ');
    if (text == newValue.text) return newValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  });

  /// `06/21` — two digits, slash, two digits.
  static final TextInputFormatter _expiryFormat =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = clipped.length > 2
        ? '${clipped.substring(0, 2)}/${clipped.substring(2)}'
        : clipped;
    if (text == newValue.text) return newValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  });

  /// Digits only, four max (used for the CVV).
  static final TextInputFormatter _digitsFormat =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 4 ? digits.substring(0, 4) : digits;
    if (clipped == newValue.text) return newValue;
    return TextEditingValue(
      text: clipped,
      selection: TextSelection.collapsed(offset: clipped.length),
    );
  });
}
