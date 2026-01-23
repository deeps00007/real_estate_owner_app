import 'package:equatable/equatable.dart';
import '../../../models/property.dart';

enum PropertyStatus { initial, loading, success, error }

class PropertyState extends Equatable {
  final PropertyStatus status;
  final List<Property> properties;
  final String searchQuery;

  const PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.searchQuery = '',
  });

  List<Property> get filteredProperties {
    if (searchQuery.isEmpty) return properties;
    return properties
        .where((p) => p.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
    String? searchQuery,
  }) {
    return PropertyState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, properties, searchQuery];
}
