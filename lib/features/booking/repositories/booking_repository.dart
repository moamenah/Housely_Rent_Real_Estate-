/// Booking **Service** contract — what the checkout ViewModel can ask for.
abstract interface class BookingRepository {
  /// Confirms the checkout for [propertyId] over the [start]–[end] period.
  Future<void> confirmBooking({
    required String propertyId,
    required DateTime start,
    required DateTime end,
  });
}
