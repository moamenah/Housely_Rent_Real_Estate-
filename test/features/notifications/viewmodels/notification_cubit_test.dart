import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/notifications/models/notification_item.dart';
import 'package:housely/features/notifications/repositories/notification_repository.dart';
import 'package:housely/features/notifications/viewmodels/notification_cubit.dart';

/// Behavioural fake: returns [sections] unless [failLoad] is armed.
class _FakeNotificationRepository implements NotificationRepository {
  _FakeNotificationRepository({this.sections = const []});

  List<NotificationSection> sections;
  bool failLoad = false;
  int calls = 0;

  @override
  Future<List<NotificationSection>> getNotifications() async {
    calls++;
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return sections;
  }
}

const NotificationSection _todayGroup = NotificationSection(
  title: 'Today',
  items: [
    NotificationItem(
      id: 't1',
      kind: NotificationIconKind.bell,
      unread: true,
      segments: [NotificationSegment('Hello there')],
    ),
  ],
);

void main() {
  late _FakeNotificationRepository repository;

  NotificationCubit buildCubit() =>
      NotificationCubit(notificationRepository: repository);

  setUp(() {
    repository = _FakeNotificationRepository(sections: const [_todayGroup]);
  });

  test('starts empty, before the first load', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.status, RequestStatus.initial);
    expect(cubit.state.sections, isEmpty);
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.failure, isNull);
  });

  test('load groups the inbox and leaves the loading state', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    final future = cubit.load();
    expect(cubit.state.isLoading, isTrue);
    await future;

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.sections, hasLength(1));
    expect(cubit.state.sections.single.title, 'Today');
    expect(cubit.state.sections.single.items.single.message, 'Hello there');
    expect(cubit.state.isEmpty, isFalse);
    expect(cubit.state.failure, isNull);
  });

  test('a successful load with nothing to show is the empty state', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    repository.sections = [];
    await cubit.load();

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.sections, isEmpty);
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.hasFailed, isFalse);
  });

  test('groups without items count as empty too', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    repository.sections = const [
      NotificationSection(title: 'Today', items: []),
    ];
    await cubit.load();

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.isEmpty, isTrue);
  });

  test('a failing load maps the exception to a Failure', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    repository.failLoad = true;
    await cubit.load();

    expect(cubit.state.hasFailed, isTrue);
    expect(cubit.state.failure, isA<Failure>());
    expect(
      cubit.state.failure?.message,
      'No internet connection. Check your network and try again.',
    );
    expect(cubit.state.isLoaded, isFalse);
  });

  test('retry clears the failure and loads for real', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    repository.failLoad = true;
    await cubit.load();
    expect(cubit.state.hasFailed, isTrue);

    repository.failLoad = false;
    await cubit.load();

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.failure, isNull);
    expect(cubit.state.sections, hasLength(1));
    expect(repository.calls, 2);
  });
}
