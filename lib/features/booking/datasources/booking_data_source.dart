/// Contract of the booking **Model** layer as seen by the repository.
///
/// Today it settles payments offline (mock latency); a real integration —
/// payment gateway, booking API — only replaces this side of the feature.
abstract interface class BookingDataSource {
  /// Confirms the checkout for [propertyId] over the [start]–[end] period.
  Future<void> confirmBooking({
    required String propertyId,
    required DateTime start,
    required DateTime end,
  });
}
