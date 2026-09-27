import 'dart:async';

import '../../../core/constants/app_assets.dart';
import '../../../core/error/exceptions.dart';
import '../models/property_model.dart';
import 'property_data_source.dart';

/// Offline fixture source.
///
/// Keeps the app fully runnable before the backend exists (and keeps widget
/// tests deterministic). It still honours the async contract and throws the
/// same exceptions as the remote source, so ViewModels are exercised exactly
/// as they will be in production.
///
/// Content mirrors the design kit: the Yogyakarta/Bali listings shown on the
/// Home mockup, photographed with the kit's `gallery_*` exports (so cards
/// render from local assets — no network in widget tests).
class MockPropertyDataSource implements PropertyDataSource {
  MockPropertyDataSource({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  static const List<PropertyModel> _fixtures = [
    PropertyModel(
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
      imageUrl: AppAssets.gallery1,
      rating: 4.8,
      reviewsCount: 126,
      type: 'villa',
      isFeatured: true,
    ),
    PropertyModel(
      id: '2',
      title: 'Bali Komang Guest',
      description:
          'White-washed guest house a short ride from the Nusa Penida '
          'harbour. Two rooms, a shared garden and a rooftop to watch the '
          'boats come in.',
      price: 180,
      pricePeriod: 'night',
      location: 'Nusa penida, Bali',
      bedrooms: 2,
      bathrooms: 1,
      areaSqm: 70,
      imageUrl: AppAssets.gallery4,
      rating: 4.6,
      reviewsCount: 98,
      type: 'house',
      isFeatured: true,
    ),
    PropertyModel(
      id: '3',
      title: 'Maharani Villa Yogyakarta',
      description:
          'Four-bedroom villa on a quiet Bendungan Hilir lane. Bright '
          'interiors, a private courtyard and easy access to the business '
          'district.',
      price: 320,
      location: 'Benhil, Jl. Bendungan Hilir Karet Tengah',
      bedrooms: 4,
      bathrooms: 3,
      areaSqm: 180,
      imageUrl: AppAssets.gallery2,
      rating: 4.5,
      reviewsCount: 87,
      type: 'villa',
    ),
    PropertyModel(
      id: '4',
      title: 'Apartement landing Seturan',
      description:
          'Two-bedroom apartment above the Seturan strip — cafés and the '
          'campus at your doorstep, with a balcony that catches the '
          'afternoon breeze.',
      price: 320,
      location: 'Jl. Tentara Pelajar No.12, Caturtunggal, Depok',
      bedrooms: 2,
      bathrooms: 1,
      areaSqm: 56,
      imageUrl: AppAssets.gallery3,
      rating: 4.7,
      reviewsCount: 64,
      type: 'apartment',
    ),
    PropertyModel(
      id: '5',
      title: 'Takatea Homestay',
      description:
          'Compact one-bedroom homestay with a garden, made for short stays. '
          'Fast wifi, a kitchenette and parking for one bike.',
      price: 120,
      pricePeriod: 'night',
      location: 'Jl. Tentara Pelajar No.47, RW.001',
      bedrooms: 1,
      bathrooms: 1,
      areaSqm: 45,
      imageUrl: AppAssets.gallery6,
      rating: 4.5,
      reviewsCount: 41,
      type: 'house',
    ),
    PropertyModel(
      id: '6',
      title: 'Prawirotaman Loft',
      description:
          'Bright loft above the Prawirotaman café row. Full kitchen, '
          'reading corner and a shared roof terrace.',
      price: 260,
      location: 'Jl. Prawirotaman No.5, Mergangsan, Kota Yogyakarta',
      bedrooms: 2,
      bathrooms: 1,
      areaSqm: 68,
      imageUrl: AppAssets.gallery5,
      rating: 4.6,
      reviewsCount: 52,
      type: 'apartment',
    ),
    PropertyModel(
      id: '7',
      title: 'Sindu Praya Loft',
      description:
          'Mezzanine loft with a sculptural stair, double-height windows '
          'and a workspace that gets the morning sun.',
      price: 190,
      location: 'Jl. Sindu Praya No.9, Kota Yogyakarta',
      bedrooms: 1,
      bathrooms: 1,
      areaSqm: 52,
      imageUrl: AppAssets.detailsLoft,
      rating: 4.4,
      reviewsCount: 33,
      type: 'studio',
    ),
    PropertyModel(
      id: '8',
      title: 'Batavia Apartments',
      description:
          'Serviced apartment in the Batavia tower — floor-to-ceiling '
          'windows over the harbour, a gym on the fourth floor and '
          'twenty-four hour reception.',
      price: 120,
      pricePeriod: 'night',
      location: 'Benhil, Jl. Bendungan Hilir Karet Tengah',
      bedrooms: 2,
      bathrooms: 2,
      areaSqm: 96,
      imageUrl: AppAssets.gallery8,
      rating: 4.5,
      reviewsCount: 73,
      type: 'apartment',
    ),
    PropertyModel(
      id: '9',
      title: 'Manhattan Hotel',
      description:
          'City hotel with a rooftop pool and sun loungers, ten minutes '
          'from the business district. Rooms come with a work desk and '
          'skyline views.',
      price: 230,
      pricePeriod: 'night',
      location: 'Jl. Prof. DR. Satrio No.Kav.19-24, Kuningan, Jakarta',
      bedrooms: 2,
      bathrooms: 2,
      areaSqm: 88,
      imageUrl: AppAssets.gallery1,
      rating: 4.5,
      reviewsCount: 152,
      type: 'hotel',
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
