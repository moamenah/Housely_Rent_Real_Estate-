import '../models/home_feed.dart';

/// Assembles the Home feed: section membership from [HomeDataSource] joined
/// against the shared listing corpus.
abstract class HomeRepository {
  Future<HomeFeed> getFeed();
}
