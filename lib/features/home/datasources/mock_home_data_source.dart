import 'dart:async';

import '../../../core/constants/app_assets.dart';
import '../models/home_feed_plan.dart';
import '../models/top_location.dart';
import 'home_data_source.dart';

/// Offline fixture source for the Home feed.
///
/// Section membership mirrors the design's Home mockup: the two oversized
/// cards under "Recommended", the four tiles in the two-row "Nearby" grid
/// (the right-hand column peeks off-screen), and the rows of
/// "Popular for you" — which deliberately overlaps "Nearby" with the same
/// listing, exactly like the mockup. The Home screen shows the first three
/// popular rows; the full list feeds the pushed "Popular" screen.
class MockHomeDataSource implements HomeDataSource {
  MockHomeDataSource({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  static const HomeFeedPlan _plan = HomeFeedPlan(
    recommendedIds: ['1', '2'],
    nearbyIds: ['3', '4', '6', '7'],
    popularIds: ['5', '3', '2', '8', '9'],
    topLocations: [
      TopLocation(name: 'Malang', imageUrl: AppAssets.gallery7),
      TopLocation(name: 'Bali', imageUrl: AppAssets.gallery9),
      TopLocation(name: 'Yogyakarta', imageUrl: AppAssets.gallery8),
      TopLocation(name: 'Lombok', imageUrl: AppAssets.gallery1),
    ],
  );

  @override
  Future<HomeFeedPlan> fetchFeedPlan() async {
    await Future<void>.delayed(latency);
    return _plan;
  }
}
