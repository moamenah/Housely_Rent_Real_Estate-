import 'package:equatable/equatable.dart';

/// A resolved spot on the map — everything the picker screen needs to show:
/// the address printed on the "Location Details" card.
class Place extends Equatable {
  const Place({required this.id, required this.address});

  /// Stable identifier (pinned default, or the query a search resolved).
  final String id;

  /// Human-readable address, exactly as the card renders it.
  final String address;

  @override
  List<Object?> get props => [id, address];
}
