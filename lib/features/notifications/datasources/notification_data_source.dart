import '../models/notification_item.dart';

/// Contract of the notification **Model** layer as seen by the repository.
///
/// The mock returns the design's two day-groups; a real data source would
/// page the inbox from the backend.
abstract interface class NotificationDataSource {
  Future<List<NotificationSection>> fetchNotifications();
}
