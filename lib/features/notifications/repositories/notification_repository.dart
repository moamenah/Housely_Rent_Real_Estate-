import '../models/notification_item.dart';

/// Use cases of the inbox, transport-agnostic.
///
/// Throws `AppException` subtypes (`core/error/exceptions.dart`) on failure —
/// ViewModels map them to a `Failure` with `FailureMapper`.
abstract interface class NotificationRepository {
  /// The inbox, grouped into day sections.
  Future<List<NotificationSection>> getNotifications();
}
