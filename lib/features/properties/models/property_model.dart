import 'property.dart';

/// Serializable representation of a listing as the API returns it.
///
/// The DTO is the **only** place that knows about JSON: data sources return
/// `PropertyModel`s, repositories map them to [Property] with [toEntity] so the
/// rest of the app never touches `fromJson` keys.
class PropertyModel {
  const PropertyModel({
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
    required this.type,
    this.isFeatured = false,
    this.pricePeriod = 'month',
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      location: json['location'] as String? ?? '',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      areaSqm: (json['area_sqm'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? PropertyType.apartment.name,
      isFeatured: json['is_featured'] as bool? ?? false,
      pricePeriod: json['price_period'] as String? ?? 'month',
    );
  }

  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final double areaSqm;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final String type;
  final bool isFeatured;

  /// [PricePeriod] name — enums don't survive JSON on their own.
  final String pricePeriod;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'location': location,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'area_sqm': areaSqm,
        'image_url': imageUrl,
        'rating': rating,
        'reviews_count': reviewsCount,
        'type': type,
        'is_featured': isFeatured,
        'price_period': pricePeriod,
      };

  /// Maps the DTO onto the domain entity used by the ViewModels/Views.
  Property toEntity() => Property(
        id: id,
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        areaSqm: areaSqm,
        imageUrl: imageUrl,
        rating: rating,
        reviewsCount: reviewsCount,
        type: PropertyType.fromName(type),
        isFeatured: isFeatured,
        pricePeriod: PricePeriod.fromName(pricePeriod),
      );
}
