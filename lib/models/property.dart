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

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.type,
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
  }) =>
      Property(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        imageUrl: imageUrl ?? this.imageUrl,
        type: type ?? this.type,
      );

  @override
  List<Object?> get props => [id, title, price, lat, lng];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'lat': lat,
        'lng': lng,
        'imageUrl': imageUrl,
        'type': type,
      };

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        lat: (json['lat'] as num?)?.toDouble() ?? 28.6692,  // Ghaziabad default
        lng: (json['lng'] as num?)?.toDouble() ?? 77.4549,
        imageUrl: json['imageUrl'] ?? '',
        type: json['type'] ?? '',
      );
}
