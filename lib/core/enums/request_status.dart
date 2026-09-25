/// Lifecycle of every async screen load.
///
/// ViewModel (Cubit) states expose this so Views can render a single switch:
/// `initial → loading → success | failure`.
enum RequestStatus {
  /// Nothing has been requested yet.
  initial,

  /// First load, show a full-screen placeholder.
  loading,

  /// Data is available.
  success,

  /// The request failed, show [Failure] with a retry affordance.
  failure,
}
