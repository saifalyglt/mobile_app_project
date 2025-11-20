import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hostel.g.dart';

@JsonSerializable()
class Hostel extends Equatable {
  final String id;
  final String name;
  final String city;
  final String address;
  final Coordinates? coordinates;
  final String? thumbnailUrl;
  final List<String> gallery;
  final String ownerId;
  final PriceRange priceRange;
  final List<Room> rooms;
  final List<String> amenities;
  final double rating;
  final int reviewsCount;
  final bool isVerified;
  final DateTime createdAt;
  final String? description;
  final String? phoneNumber;
  final String? email;
  final Map<String, dynamic>? policies;

  const Hostel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    this.coordinates,
    this.thumbnailUrl,
    required this.gallery,
    required this.ownerId,
    required this.priceRange,
    required this.rooms,
    required this.amenities,
    required this.rating,
    required this.reviewsCount,
    required this.isVerified,
    required this.createdAt,
    this.description,
    this.phoneNumber,
    this.email,
    this.policies,
  });

  factory Hostel.fromJson(Map<String, dynamic> json) => _$HostelFromJson(json);
  Map<String, dynamic> toJson() => _$HostelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        city,
        address,
        coordinates,
        thumbnailUrl,
        gallery,
        ownerId,
        priceRange,
        rooms,
        amenities,
        rating,
        reviewsCount,
        isVerified,
        createdAt,
      ];

  Hostel copyWith({
    String? id,
    String? name,
    String? city,
    String? address,
    Coordinates? coordinates,
    String? thumbnailUrl,
    List<String>? gallery,
    String? ownerId,
    PriceRange? priceRange,
    List<Room>? rooms,
    List<String>? amenities,
    double? rating,
    int? reviewsCount,
    bool? isVerified,
    DateTime? createdAt,
    String? description,
    String? phoneNumber,
    String? email,
    Map<String, dynamic>? policies,
  }) {
    return Hostel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      gallery: gallery ?? this.gallery,
      ownerId: ownerId ?? this.ownerId,
      priceRange: priceRange ?? this.priceRange,
      rooms: rooms ?? this.rooms,
      amenities: amenities ?? this.amenities,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      policies: policies ?? this.policies,
    );
  }
}

@JsonSerializable()
class Coordinates extends Equatable {
  final double lat;
  final double lng;

  const Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);

  @override
  List<Object?> get props => [lat, lng];
}

@JsonSerializable()
class PriceRange extends Equatable {
  final double min;
  final double max;

  const PriceRange({required this.min, required this.max});

  factory PriceRange.fromJson(Map<String, dynamic> json) =>
      _$PriceRangeFromJson(json);
  Map<String, dynamic> toJson() => _$PriceRangeToJson(this);

  @override
  List<Object?> get props => [min, max];
}

@JsonSerializable()
class Room extends Equatable {
  final String type;
  final double price;
  final int quantity;
  final int? availableQuantity;

  const Room({
    required this.type,
    required this.price,
    required this.quantity,
    this.availableQuantity,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  List<Object?> get props => [type, price, quantity, availableQuantity];
}

