import '../datasources/notification_data_source.dart';
import '../models/notification_item.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({required NotificationDataSource dataSource})
      : _dataSource = dataSource;

  final NotificationDataSource _dataSource;

  @override
  Future<List<NotificationSection>> getNotifications() =>
      _dataSource.fetchNotifications();
}
