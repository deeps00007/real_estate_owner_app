import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/property.dart';

enum PropertyStatus { initial, loading, success, error }

class PropertyState extends Equatable {
  final PropertyStatus status;
  final List<Property> properties;
  final String searchQuery;
  final bool isListView;
  final bool isNearbyActive;
  final double? userLatitude;
  final double? userLongitude;
  final String? currentAddress; // Added

  const PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.searchQuery = '',
    this.isListView = false,
    this.isNearbyActive = false,
    this.userLatitude,
    this.userLongitude,
    this.currentAddress, // Added
  });

  List<Property> get filteredProperties {
    List<Property> filtered = properties;

    // Search query filter
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q),
          )
          .toList();
    }

    // Nearby distance filter (10km radius)
    if (isNearbyActive && userLatitude != null && userLongitude != null) {
      const distance = Distance();
      final userPos = LatLng(userLatitude!, userLongitude!);
      filtered = filtered.where((p) {
        final propPos = LatLng(p.lat, p.lng);
        final distInMeters = distance.as(LengthUnit.Meter, userPos, propPos);
        return distInMeters <= 10000; // 10km radius
      }).toList();
    }

    return filtered;
  }

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
    String? searchQuery,
    bool? isListView,
    bool? isNearbyActive,
    double? userLatitude,
    double? userLongitude,
    String? currentAddress, // Added
  }) {
    return PropertyState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      searchQuery: searchQuery ?? this.searchQuery,
      isListView: isListView ?? this.isListView,
      isNearbyActive: isNearbyActive ?? this.isNearbyActive,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      currentAddress: currentAddress ?? this.currentAddress, // Added
    );
  }

  @override
  List<Object?> get props => [
    status,
    properties,
    searchQuery,
    isListView,
    isNearbyActive,
    userLatitude,
    userLongitude,
    currentAddress, // Added
  ];
}
