import 'package:equatable/equatable.dart';

import '../../properties/models/property.dart';
import 'top_location.dart';

/// Composed Home screen content: three listing rails plus destination chips.
///
/// The rails may overlap on purpose — the design shows the same listing in
/// both "Nearby" and "Popular for you", so membership is data, not identity.
class HomeFeed extends Equatable {
  const HomeFeed({
    required this.recommended,
    required this.nearby,
    required this.popular,
    required this.topLocations,
  });

  final List<Property> recommended;
  final List<Property> nearby;
  final List<Property> popular;
  final List<TopLocation> topLocations;

  @override
  List<Object?> get props => [recommended, nearby, popular, topLocations];
}
