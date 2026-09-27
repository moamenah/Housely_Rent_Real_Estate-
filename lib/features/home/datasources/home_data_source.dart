import '../models/home_feed_plan.dart';

/// Delivers the Home feed plan (section membership + destination chips).
///
/// Listing rows themselves are NOT part of this contract — they come from the
/// shared `PropertyRepository`, so Home, Explore and Favorites all render the
/// same corpus.
abstract class HomeDataSource {
  Future<HomeFeedPlan> fetchFeedPlan();
}
