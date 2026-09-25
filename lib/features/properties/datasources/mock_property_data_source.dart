import 'dart:async';

import '../../../core/error/exceptions.dart';
import '../models/property_model.dart';
import 'property_data_source.dart';

/// Offline fixture source.
///
/// Keeps the app fully runnable before the backend exists (and keeps widget
/// tests deterministic). It still honours the async contract and throws the
/// same exceptions as the remote source, so ViewModels are exercised exactly
/// as they will be in production.
class MockPropertyDataSource implements PropertyDataSource {
  MockPropertyDataSource({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  static const List<PropertyModel> _fixtures = [
    PropertyModel(
      id: '1',
      title: 'Sunlit loft with city views',
      description:
          'A bright, open-plan loft in the heart of the district. Floor-to-ceiling '
          'windows, polished concrete floors and a kitchen fitted with Bosch '
          'appliances. Two blocks from the metro and a five minute walk to the '
          'farmers market.',
      price: 2450,
      location: 'Downtown, Seattle',
      bedrooms: 2,
      bathrooms: 2,
      areaSqm: 96,
      imageUrl: 'https://picsum.photos/seed/housely1/900/700',
      rating: 4.8,
      reviewsCount: 126,
      type: 'apartment',
      isFeatured: true,
    ),
    PropertyModel(
      id: '2',
      title: 'Quiet garden townhouse',
      description:
          'Three bedroom townhouse with a private courtyard, home office nook and '
          'off-street parking. Recently refurbished with warm oak flooring throughout.',
      price: 3100,
      location: 'Capitol Hill, Seattle',
      bedrooms: 3,
      bathrooms: 2,
      areaSqm: 142,
      imageUrl: 'https://picsum.photos/seed/housely2/900/700',
      rating: 4.6,
      reviewsCount: 84,
      type: 'townhouse',
      isFeatured: true,
    ),
    PropertyModel(
      id: '3',
      title: 'Modern studio near the park',
      description:
          'Compact, cleverly planned studio with a wall bed, full kitchen and a '
          'sunny reading corner facing the park.',
      price: 1450,
      location: 'Ballard, Seattle',
      bedrooms: 1,
      bathrooms: 1,
      areaSqm: 42,
      imageUrl: 'https://picsum.photos/seed/housely3/900/700',
      rating: 4.4,
      reviewsCount: 51,
      type: 'studio',
    ),
    PropertyModel(
      id: '4',
      title: 'Waterfront villa with terrace',
      description:
          'Spacious villa with a wrap-around terrace, outdoor kitchen and unobstructed '
          'water views. Smart-home wiring and a double garage.',
      price: 6200,
      location: 'Magnolia, Seattle',
      bedrooms: 4,
      bathrooms: 3,
      areaSqm: 260,
      imageUrl: 'https://picsum.photos/seed/housely4/900/700',
      rating: 4.9,
      reviewsCount: 39,
      type: 'villa',
      isFeatured: true,
    ),
    PropertyModel(
      id: '5',
      title: 'Renovated family house',
      description:
          'Classic craftsman with a new roof, updated electrical and a fenced '
          'backyard. Walking distance to two top rated schools.',
      price: 3750,
      location: 'Wallingford, Seattle',
      bedrooms: 4,
      bathrooms: 2,
      areaSqm: 188,
      imageUrl: 'https://picsum.photos/seed/housely5/900/700',
      rating: 4.7,
      reviewsCount: 72,
      type: 'house',
    ),
    PropertyModel(
      id: '6',
      title: 'Minimalist apartment, top floor',
      description:
          'Top floor one bedroom with a private balcony, in-unit laundry and a '
          'dedicated bike store.',
      price: 1980,
      location: 'Fremont, Seattle',
      bedrooms: 1,
      bathrooms: 1,
      areaSqm: 61,
      imageUrl: 'https://picsum.photos/seed/housely6/900/700',
      rating: 4.5,
      reviewsCount: 103,
      type: 'apartment',
    ),
    PropertyModel(
      id: '7',
      title: 'Countryside house with studio',
      description:
          'Peaceful retreat on a quarter acre plot with a detached artist studio, '
          'wood burner and mature orchard.',
      price: 2890,
      location: 'Issaquah, Seattle',
      bedrooms: 3,
      bathrooms: 2,
      areaSqm: 170,
      imageUrl: 'https://picsum.photos/seed/housely7/900/700',
      rating: 4.3,
      reviewsCount: 27,
      type: 'house',
    ),
    PropertyModel(
      id: '8',
      title: 'Cozy studio above the bakery',
      description:
          'Charming studio in a converted 1920s building with exposed brick, '
          'high ceilings and a shared rooftop terrace.',
      price: 1320,
      location: 'Queen Anne, Seattle',
      bedrooms: 1,
      bathrooms: 1,
      areaSqm: 38,
      imageUrl: 'https://picsum.photos/seed/housely8/900/700',
      rating: 4.2,
      reviewsCount: 65,
      type: 'studio',
    ),
  ];

  @override
  Future<List<PropertyModel>> fetchProperties() async {
    await Future<void>.delayed(latency);
    return _fixtures;
  }

  @override
  Future<PropertyModel> fetchPropertyById(String id) async {
    await Future<void>.delayed(latency);
    return _fixtures.firstWhere(
      (property) => property.id == id,
      orElse: () => throw const NotFoundException(),
    );
  }
}
