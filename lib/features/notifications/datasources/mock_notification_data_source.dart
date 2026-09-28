import '../../../core/constants/app_assets.dart';
import '../models/notification_item.dart';
import 'notification_data_source.dart';

/// Offline inbox fixture — the two day-groups from the design, in order.
///
/// Latency is simulated so the loading skeleton on the screen is real rather
/// than an instant flip.
class MockNotificationDataSource implements NotificationDataSource {
  MockNotificationDataSource({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  static const String _welcome = 'Welcome, Don\'t forget to complete your '
      'personal info';

  static const List<NotificationSection> _sections = [
    NotificationSection(
      title: 'Today',
      items: [
        NotificationItem(
          id: 't1',
          kind: NotificationIconKind.bell,
          unread: true,
          segments: [
            NotificationSegment(
              'Congratulations, your listing is now active. ',
            ),
            NotificationSegment(
              'click here to see your listing',
              bold: true,
            ),
          ],
        ),
        NotificationItem(
          id: 't2',
          kind: NotificationIconKind.bell,
          unread: true,
          segments: [NotificationSegment(_welcome)],
        ),
      ],
    ),
    NotificationSection(
      title: 'Yesterday',
      items: [
        NotificationItem(
          id: 'y1',
          kind: NotificationIconKind.avatar,
          avatarAsset: AppAssets.agentAvatar,
          segments: [
            NotificationSegment('Anggela and joni', bold: true),
            NotificationSegment(' send you message, check it now'),
          ],
        ),
        NotificationItem(
          id: 'y2',
          kind: NotificationIconKind.bell,
          unread: true,
          segments: [NotificationSegment(_welcome)],
        ),
        NotificationItem(
          id: 'y3',
          kind: NotificationIconKind.person,
          segments: [NotificationSegment(_welcome)],
        ),
        NotificationItem(
          id: 'y4',
          kind: NotificationIconKind.avatar,
          avatarAsset: AppAssets.reviewerAvatar,
          segments: [
            NotificationSegment('Jhon, ani & 2 other', bold: true),
            NotificationSegment(' send you message, check it now'),
          ],
        ),
        NotificationItem(
          id: 'y5',
          kind: NotificationIconKind.person,
          segments: [NotificationSegment(_welcome)],
        ),
      ],
    ),
  ];

  @override
  Future<List<NotificationSection>> fetchNotifications() async {
    await Future<void>.delayed(latency);
    return _sections;
  }
}
