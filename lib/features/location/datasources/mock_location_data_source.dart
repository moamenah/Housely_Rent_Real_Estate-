import '../models/place.dart';
import 'location_data_source.dart';

/// Offline address resolver.
///
/// The pin opens on the address from the design; searches resolve through a
/// tiny gazetteer (any query containing a known street returns its full
/// address) and otherwise fall back to `<query>, Kota Yogyakarta`. Latency is
/// simulated so loading states on the map are real.
class MockLocationDataSource implements LocationDataSource {
  MockLocationDataSource({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  /// What the pin points at before the user moves anything.
  static const Place pinnedPlace = Place(
    id: 'pinned',
    address: 'Jl. Jend. Sudirman, Gowongan, Kec. Jetis, Kota Yogyakarta',
  );

  static const Map<String, String> _gazetteer = {
    'sudirman': 'Jl. Jend. Sudirman, Gowongan, Kec. Jetis, Kota Yogyakarta',
    'gowongan': 'Gowongan, Kec. Jetis, Kota Yogyakarta',
    'mawar': 'Gg. Mawar, Gowongan, Kec. Jetis, Kota Yogyakarta',
    'kricak': 'Jl. Kricak Kidul, Terban, Kec. Gondokusuman, Kota Yogyakarta',
    'jetis': 'Kec. Jetis, Kota Yogyakarta',
    'yogyakarta': 'Kota Yogyakarta, Daerah Istimewa Yogyakarta',
  };

  @override
  Future<Place> getPinnedPlace() async {
    await Future<void>.delayed(latency);
    return pinnedPlace;
  }

  @override
  Future<Place> searchPlace({required String query}) async {
    await Future<void>.delayed(latency);
    final cleaned = query.trim();
    if (cleaned.isEmpty) return pinnedPlace;

    final needle = cleaned.toLowerCase();
    for (final entry in _gazetteer.entries) {
      if (needle.contains(entry.key)) {
        return Place(id: 'search:${entry.key}', address: entry.value);
      }
    }
    return Place(
      id: 'search:${needle.hashCode}',
      address: '$cleaned, Kota Yogyakarta',
    );
  }
}
