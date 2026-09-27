import 'package:equatable/equatable.dart';

/// A destination chip on the Home screen's "Top Locations" rail.
class TopLocation extends Equatable {
  const TopLocation({required this.name, required this.imageUrl});

  final String name;

  /// Thumbnail asset path (the kit's gallery photos).
  final String imageUrl;

  @override
  List<Object?> get props => [name, imageUrl];
}
