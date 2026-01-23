import 'package:equatable/equatable.dart';
import '../../../models/property.dart';

enum PropertyStatus { initial, loading, success, error }

class PropertyState extends Equatable {
  final PropertyStatus status;
  final List<Property> properties;
  final String searchQuery;
  final bool isListView;

  const PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.searchQuery = '',
    this.isListView = false,
  });

  List<Property> get filteredProperties {
    if (searchQuery.isEmpty) return properties;
    final q = searchQuery.toLowerCase();
    return properties
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
    String? searchQuery,
    bool? isListView,
  }) {
    return PropertyState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      searchQuery: searchQuery ?? this.searchQuery,
      isListView: isListView ?? this.isListView,
    );
  }

  @override
  List<Object?> get props => [status, properties, searchQuery, isListView];
}
