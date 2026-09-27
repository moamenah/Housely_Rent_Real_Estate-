import 'top_location.dart';

/// Section plan as the data source returns it: which listing ids belong to
/// each Home rail, plus the destination chips.
///
/// A DTO — it only carries ids, never listing rows: the repository joins it
/// against the shared corpus so every screen shows the same listings.
class HomeFeedPlan {
  const HomeFeedPlan({
    required this.recommendedIds,
    required this.nearbyIds,
    required this.popularIds,
    required this.topLocations,
  });

  final List<String> recommendedIds;
  final List<String> nearbyIds;
  final List<String> popularIds;
  final List<TopLocation> topLocations;
}
