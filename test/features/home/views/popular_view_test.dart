import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/home/models/home_feed.dart';
import 'package:housely/features/home/models/top_location.dart';
import 'package:housely/features/home/repositories/home_repository.dart';
import 'package:housely/features/home/views/popular_view.dart';
import 'package:housely/features/favorites/viewmodels/favorites_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:housely/features/properties/models/property.dart';

/// Behavioural fake: five popular rows unless [failLoad] is armed.
class _FakeHomeRepository implements HomeRepository {
  bool failLoad = false;

  @override
  Future<HomeFeed> getFeed() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return HomeFeed(
      recommended: [_property('1', 'Ayana Homestay')],
      nearby: [_property('3', 'Maharani Villa Yogyakarta')],
      popular: [
        _property('5', 'Takatea Homestay'),
        _property('3', 'Maharani Villa Yogyakarta'),
        _property('2', 'Bali Komang Guest'),
        _property('8', 'Batavia Apartments'),
        _property('9', 'Manhattan Hotel'),
      ],
      topLocations: const [TopLocation(name: 'Bali', imageUrl: 'assets/x.png')],
    );
  }
}

Property _property(String id, String title) => Property(
      id: id,
      title: title,
      description: 'Cozy stay',
      price: 120,
      location: 'Yogyakarta',
      bedrooms: 2,
      bathrooms: 1,
      areaSqm: 90,
      imageUrl: 'assets/images/gallery_1.png',
      rating: 4.5,
      reviewsCount: 41,
    );

void main() {
  late _FakeHomeRepository repository;

  setUp(() {
    repository = _FakeHomeRepository();
  });

  Future<void> pumpPopular(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<FavoritesCubit>(
        create: (_) => FavoritesCubit(initialIds: {'3'}),
        child: MaterialApp(
          theme: AppTheme.light,
          home: PopularView(homeRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every popular row with the mockup dividers',
      (tester) async {
    await pumpPopular(tester);

    expect(find.text('Popular'), findsOneWidget);
    for (final title in [
      'Takatea Homestay',
      'Maharani Villa Yogyakarta',
      'Bali Komang Guest',
      'Batavia Apartments',
      'Manhattan Hotel',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    // Four hairlines between the five rows.
    expect(find.byType(Divider), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed list announces itself and can be retried',
      (tester) async {
    repository.failLoad = true;
    await pumpPopular(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Takatea Homestay'), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsNothing);
    expect(find.text('Takatea Homestay'), findsOneWidget);
  });
}
