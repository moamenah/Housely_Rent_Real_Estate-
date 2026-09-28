import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/constants/app_assets.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/notifications/datasources/mock_notification_data_source.dart';
import 'package:housely/features/notifications/models/notification_item.dart';
import 'package:housely/features/notifications/repositories/notification_repository.dart';
import 'package:housely/features/notifications/views/notification_view.dart';

/// Behavioural fake over the design's own fixture: returns [sections] unless
/// [failLoad] is armed, or holds the first load open while [gate] is set
/// (that's how the skeleton gets asserted).
class _FakeNotificationRepository implements NotificationRepository {
  List<NotificationSection> sections = const [];
  bool failLoad = false;
  Completer<List<NotificationSection>>? gate;

  @override
  Future<List<NotificationSection>> getNotifications() {
    final pending = gate;
    if (pending != null) {
      return pending.future;
    }
    return Future(() async {
      await Future<void>.delayed(Duration.zero);
      if (failLoad) {
        throw const NetworkException();
      }
      return sections;
    });
  }
}

void main() {
  late GoRouter router;
  late _FakeNotificationRepository repository;
  late List<NotificationSection> fixture;

  void setUpRouter() {
    repository = _FakeNotificationRepository();
    router = GoRouter(
      initialLocation: RoutePaths.notifications,
      routes: [
        GoRoute(
          path: RoutePaths.notifications,
          builder: (context, state) =>
              NotificationView(notificationRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) =>
              const Scaffold(body: Text('HOME_STUB')),
        ),
      ],
    );
  }

  setUpAll(() async {
    // The mockup copy itself, straight from the design's fixture source.
    fixture = await MockNotificationDataSource(
      latency: Duration.zero,
    ).fetchNotifications();
  });

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  Future<void> pumpNotifications(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('holds a static skeleton until the inbox arrives',
      (tester) async {
    repository
      ..sections = fixture
      ..gate = Completer<List<NotificationSection>>();
    await pumpNotifications(tester);

    // Loading is a static placeholder — never an indeterminate spinner.
    expect(find.text('Today'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No notification yet'), findsNothing);

    repository.gate!.complete(fixture);
    repository.gate = null;
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('renders both day groups and every mockup row',
      (tester) async {
    repository.sections = fixture;
    await pumpNotifications(tester);

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);

    // Leading slots: three unread bells, two person circles, two photos.
    expect(find.byIcon(Icons.notifications_none), findsNWidgets(3));
    expect(find.byIcon(Icons.person_outline), findsNWidgets(2));
    expect(find.byType(Image), findsNWidgets(2));

    // Rich messages, in full (segments concatenate verbatim).
    expect(
      find.text(
        'Congratulations, your listing is now active. '
        'click here to see your listing',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Welcome, Don\'t forget to complete your personal info',
        findRichText: true,
      ),
      findsNWidgets(4),
    );
    expect(
      find.text(
        'Anggela and joni send you message, check it now',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Jhon, ani & 2 other send you message, check it now',
        findRichText: true,
      ),
      findsOneWidget,
    );

    expect(find.byKey(const Key('notification_back_button')), findsOneWidget);
    expect(find.text('No notification yet'), findsNothing);
  });

  testWidgets('an empty inbox renders the Opps!! hero and its copy',
      (tester) async {
    repository.sections = [];
    await pumpNotifications(tester);

    expect(find.text('No notification yet'), findsOneWidget);
    expect(
      find.text(
        'All notification we send will appear here, so you can view them '
        'easly anytime.',
      ),
      findsOneWidget,
    );
    expect(find.image(const AssetImage(AppAssets.notificationOops)),
        findsOneWidget);

    expect(find.text('Today'), findsNothing);
    expect(find.byIcon(Icons.notifications_none), findsNothing);
  });

  testWidgets('a failed load announces itself and can be retried',
      (tester) async {
    repository
      ..sections = fixture
      ..failLoad = true;
    await pumpNotifications(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(find.text('Today'), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
  });

  testWidgets('the back arrow returns to the entry point', (tester) async {
    repository.sections = fixture;
    await pumpNotifications(tester);

    await tester.tap(find.byKey(const Key('notification_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('HOME_STUB'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
