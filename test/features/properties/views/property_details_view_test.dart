import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/favorites/viewmodels/favorites_cubit.dart';
import 'package:housely/features/properties/models/property.dart';
import 'package:housely/features/properties/repositories/property_repository.dart';
import 'package:housely/features/properties/views/property_details_view.dart';

/// Behavioural fake: returns one listing unless [failLoad] is armed.
class _FakePropertyRepository implements PropertyRepository {
  bool failLoad = false;

  static final Property _property = Property(
    id: '1',
    title: 'Ayana Homestay',
    description:
        'A design-led homestay wrapped around a courtyard pool in Imogiri. '
        'Open-plan living, king bedroom and a shaded terrace for slow '
        'mornings, twenty minutes from the city.',
    price: 310,
    location: 'Imogiri, Yogyakarta',
    bedrooms: 3,
    bathrooms: 2,
    areaSqm: 120,
    imageUrl: 'assets/images/gallery_1.png',
    rating: 4.8,
    reviewsCount: 126,
  );

  @override
  Future<List<Property>> getProperties() async => [_property];

  @override
  Future<Property> getPropertyById(String id) async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return _property;
  }
}

void main() {
  late _FakePropertyRepository repository;
  late FavoritesCubit favorites;

  setUp(() {
    repository = _FakePropertyRepository();
    favorites = FavoritesCubit(initialIds: {'9'});
    addTearDown(favorites.close);
  });

  Future<void> pumpDetails(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<FavoritesCubit>.value(
        value: favorites,
        child: MaterialApp(
          theme: AppTheme.light,
          home: PropertyDetailsView(
            propertyId: '1',
            propertyRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The single vertical scroller of the details page.
  Finder verticalScrollable() => find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
      );

  testWidgets('renders every section of the design', (tester) async {
    await pumpDetails(tester);

    // Above the fold: AppBar, title row, facts grid, description.
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Ayana Homestay'), findsOneWidget);
    expect(find.textContaining(r'$310', findRichText: true), findsOneWidget);
    expect(find.text('Property Details'), findsOneWidget);
    expect(find.text('Bedrooms'), findsOneWidget);
    expect(find.text('Bathroom'), findsOneWidget);
    expect(find.text('Area'), findsOneWidget);
    expect(find.text('1,292 sqft'), findsOneWidget);
    expect(find.text('2020'), findsOneWidget);
    expect(find.text('1 Indoor'), findsOneWidget);
    expect(find.text('For Rent'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.textContaining('Read more', findRichText: true), findsOneWidget);
    expect(find.text('Rent now'), findsOneWidget);

    // Reveal the lower sections: agent, facilities, map, reviews.
    await tester.drag(verticalScrollable(), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Agent'), findsOneWidget);
    expect(find.text('Esther Howard'), findsOneWidget);
    expect(find.text('Real Estate Agent'), findsOneWidget);
    expect(find.text('Location & Public Facilities'), findsOneWidget);
    expect(find.text('Hospital'), findsOneWidget);
    expect(find.text('Gas stations'), findsOneWidget);
    // The rail bleeds right — the fourth chip is built past the gutter.
    expect(find.text('Mosque', skipOffstage: false), findsOneWidget);
    expect(find.text('Reviews 126'), findsOneWidget);
    expect(find.text('Theresa Webb'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the AppBar heart toggles the session favorite', (tester) async {
    await pumpDetails(tester);
    expect(favorites.state.isFavorite('1'), isFalse);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();
    expect(favorites.state.isFavorite('1'), isTrue);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(favorites.state.isFavorite('1'), isFalse);
  });

  testWidgets('the share button opens the design sheet and reports a stub',
      (tester) async {
    await pumpDetails(tester);

    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    expect(find.text('Share to'), findsOneWidget);
    for (final target in [
      'Facebook',
      'Instagram',
      'Twitter',
      'Whatsapp',
      'Linkedin',
      'Pinterest',
    ]) {
      expect(find.text(target), findsOneWidget);
    }

    await tester.tap(find.text('Twitter'));
    await tester.pumpAndSettle();

    expect(find.text('Share to'), findsNothing);
    expect(
      find.text("Sharing via Twitter isn't available in this build yet."),
      findsOneWidget,
    );
  });

  testWidgets('a failed load announces itself and can be retried',
      (tester) async {
    repository.failLoad = true;
    await pumpDetails(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Details'), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsNothing);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Ayana Homestay'), findsOneWidget);
  });
}
