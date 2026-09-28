import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../models/my_booking.dart';
import '../repositories/my_booking_repository.dart';
import 'my_bookings_state.dart';

/// ViewModel of the My Booking screen.
///
/// Loads the demo account's stays once per visit; segment taps filter the
/// loaded list client-side (no reload), card/action taps stay in the View.
class MyBookingsCubit extends Cubit<MyBookingsState> {
  MyBookingsCubit({required MyBookingRepository myBookingRepository})
      : _myBookingRepository = myBookingRepository,
        super(const MyBookingsState());

  final MyBookingRepository _myBookingRepository;

  Future<void> load() async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final bookings = await _myBookingRepository.getBookings();
      emit(state.copyWith(status: RequestStatus.success, bookings: bookings));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }

  /// A segment pill was tapped — switch the active segment.
  void select(BookingStatus status) {
    if (status == state.selected) return;
    emit(state.copyWith(selected: status));
  }
}
