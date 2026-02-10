import 'package:equatable/equatable.dart';

class Property extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final double lat;
  final double lng;
  final String imageUrl;
  final String type;
  final String? address; // Added
  final String? ownerId; // Added

  final int beds;
  final int baths;
  final double sqft;
  final bool hasKitchen;
  final String agentName;
  final String agentPhone;
  final List<String> gallery;

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.type,
    this.ownerId,
    this.address,
    this.beds = 0,
    this.baths = 0,
    this.sqft = 0.0,
    this.hasKitchen = false,
    this.agentName = '',
    this.agentPhone = '',
    this.gallery = const [],
  });

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? lat,
    double? lng,
    String? imageUrl,
    String? type,
    String? ownerId,
    String? address,
    int? beds,
    int? baths,
    double? sqft,
    bool? hasKitchen,
    String? agentName,
    String? agentPhone,
    List<String>? gallery,
  }) => Property(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    price: price ?? this.price,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    imageUrl: imageUrl ?? this.imageUrl,
    type: type ?? this.type,
    ownerId: ownerId ?? this.ownerId,
    address: address ?? this.address,
    beds: beds ?? this.beds,
    baths: baths ?? this.baths,
    sqft: sqft ?? this.sqft,
    hasKitchen: hasKitchen ?? this.hasKitchen,
    agentName: agentName ?? this.agentName,
    agentPhone: agentPhone ?? this.agentPhone,
    gallery: gallery ?? this.gallery,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    lat,
    lng,
    ownerId,
    address,
    beds,
    baths,
    sqft,
    hasKitchen,
    agentName,
    agentPhone,
    gallery,
  ];

  String get formattedPrice {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(1)}Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '₹${(price / 1000).toStringAsFixed(0)}k';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'lat': lat,
    'lng': lng,
    'imageUrl': imageUrl,
    'type': type,
    'ownerId': ownerId,
    'address': address,
    'beds': beds,
    'baths': baths,
    'sqft': sqft,
    'hasKitchen': hasKitchen,
    'agentName': agentName,
    'agentPhone': agentPhone,
    'gallery': gallery,
  };

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    lat: (json['lat'] as num?)?.toDouble() ?? 28.6692,
    lng: (json['lng'] as num?)?.toDouble() ?? 77.4549,
    imageUrl: json['imageUrl'] ?? '',
    type: json['type'] ?? '',
    ownerId: json['ownerId'],
    address: json['address'],
    beds: json['beds'] ?? 0,
    baths: json['baths'] ?? 0,
    sqft: (json['sqft'] as num?)?.toDouble() ?? 0.0,
    hasKitchen: json['hasKitchen'] ?? false,
    agentName: json['agentName'] ?? '',
    agentPhone: json['agentPhone'] ?? '',
    gallery: List<String>.from(json['gallery'] ?? []),
  );
}
