import 'package:equatable/equatable.dart';

/// Domain entity shown by the UI.
///
/// Pure Dart: no serialization, no framework imports. ViewModels and Views
/// only ever exchange this type.
class Property extends Equatable {
  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqm,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    this.type = PropertyType.apartment,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String description;

  /// Monthly price in USD.
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final double areaSqm;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final PropertyType type;
  final bool isFeatured;

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    double? areaSqm,
    String? imageUrl,
    double? rating,
    int? reviewsCount,
    PropertyType? type,
    bool? isFeatured,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      areaSqm: areaSqm ?? this.areaSqm,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      type: type ?? this.type,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        location,
        bedrooms,
        bathrooms,
        areaSqm,
        imageUrl,
        rating,
        reviewsCount,
        type,
        isFeatured,
      ];
}

enum PropertyType {
  apartment('Apartment'),
  house('House'),
  villa('Villa'),
  studio('Studio'),
  townhouse('Townhouse');

  const PropertyType(this.label);

  final String label;

  static PropertyType fromName(String? name) =>
      PropertyType.values.firstWhere(
        (type) => type.name == name,
        orElse: () => PropertyType.apartment,
      );
}
