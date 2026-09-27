import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../models/payment_card.dart';
import '../repositories/booking_repository.dart';
import 'booking_state.dart';

/// ViewModel of the Booking checkout.
///
/// Session-scoped on purpose: the same instance serves the My Booking tab and
/// the details screen's "Rent now", so a card saved on one entry is attached
/// on the other. Screen-scoped concerns (the date sheet, the card form) feed
/// their results in through [setPeriod] / [attachCard].
class BookingCubit extends Cubit<BookingState> {
  BookingCubit({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(BookingState());

  final BookingRepository _bookingRepository;

  /// Points the checkout at [propertyId]; the attached card and the chosen
  /// period are session-level and survive the swap, while a previous
  /// confirm result is cleared so the new booking starts clean.
  void startBooking(String propertyId) {
    emit(
      state.copyWith(
        propertyId: propertyId,
        status: RequestStatus.initial,
        clearFailure: true,
      ),
    );
  }

  /// Commits the range picked in the "Select Date" sheet (order-agnostic).
  void setPeriod(DateTime start, DateTime end) {
    final reversed = end.isBefore(start);
    emit(
      state.copyWith(
        periodStart: reversed ? end : start,
        periodEnd: reversed ? start : end,
        status: RequestStatus.initial,
        clearFailure: true,
      ),
    );
  }

  /// Attaches the card saved on the Add Card form.
  void attachCard(PaymentCard card) {
    emit(
      state.copyWith(
        card: card,
        status: RequestStatus.initial,
        clearFailure: true,
      ),
    );
  }

  /// Confirms the checkout; success/failure lands in [BookingState.status]
  /// for the view to react to (success sheet / snackbar).
  Future<void> confirm() async {
    if (state.isConfirming) return;
    emit(state.copyWith(status: RequestStatus.loading, clearFailure: true));
    try {
      await _bookingRepository.confirmBooking(
        propertyId: state.propertyId,
        start: state.periodStart,
        end: state.periodEnd,
      );
      emit(state.copyWith(status: RequestStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          failure: FailureMapper.map(error),
        ),
      );
    }
  }
}
