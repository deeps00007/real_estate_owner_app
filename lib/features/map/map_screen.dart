import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_smart/flutter_map_smart.dart';
import '../../../models/property.dart';
import '../../../core/auth_bloc.dart';
import 'bloc/property_bloc.dart';
import 'bloc/property_event.dart';
import 'bloc/property_state.dart';
import 'add_property_screen.dart';
import 'widgets/property_detail_sheet.dart';
import 'widgets/floating_action_dock.dart';
import 'widgets/map_property_card.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // MapController is managed by FlutterMapSmart internally
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final bloc = context.read<PropertyBloc>();
    if (query.isEmpty) {
      bloc.add(const SearchProperties(''));
      return;
    }
    bloc.add(SearchProperties(query));
    // Geocoding centering not supported by simple widget currently
  }

  void _onMarkerTap(Property property) {
    // Check if property exists in filtered list
    final state = context.read<PropertyBloc>().state;
    final index = state.filteredProperties.indexWhere(
      (p) => p.id == property.id,
    );
    if (index != -1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // 1. Full Screen Map
              Positioned.fill(
                child: FlutterMapSmart.simple(
                  items: state.filteredProperties,
                  latitude: (property) => property.lat,
                  longitude: (property) => property.lng,
                  markerImage: (property) => property.imageUrl,
                  showUserLocation: true,
                  enableNearby: true,
                  nearbyRadiusKm: 10.0,
                  markerSize: 100, // Slightly larger for better touch target
                  itemBuilder: (context, property) {
                    final prop = property as Property;
                    // Pink Pill with Pin design
                    return GestureDetector(
                      onTap: () => _onMarkerTap(prop),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF80AB),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              prop.formattedPrice,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 30,
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: (property) => _onMarkerTap(property as Property),
                  onLocationPermissionDenied: () {
                    // Handle permission denial
                  },
                ),
              ),

              // 2. Floating Search Bar (Top)
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: _buildFloatingSearchBar(context),
              ),

              // 3. Properties Carousel (Bottom)
              Positioned(
                bottom: 120, // Space for Bottom Navigation and Action Dock
                left: 0,
                right: 0,
                height: 140,
                child: state.filteredProperties.isEmpty
                    ? const SizedBox()
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: state.filteredProperties.length,
                        padEnds: true,
                        itemBuilder: (context, index) {
                          final prop = state.filteredProperties[index];
                          return MapPropertyCard(
                            property: prop,
                            onTap: () => _showDetails(context, prop),
                          );
                        },
                      ),
              ),

              // 4. Floating Action Dock (Bottom Center)
              Positioned(
                bottom: 30, // Above MainNavigation
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionDock(
                    onExpand: () {}, // Toggle full screen
                    onNavigate: () {}, // Start navigation
                    onRefresh: () =>
                        context.read<PropertyBloc>().add(LoadProperties()),
                    onFilter: () {}, // Open filter sheet
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) =>
            context.read<PropertyBloc>().add(SearchProperties(val)),
        decoration: InputDecoration(
          hintText: 'Silverpine Meadows, Warburton', // Example from image
          hintStyle: TextStyle(color: Colors.pink[100]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFF80AB)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFFFF80AB)),
            onPressed: () {},
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyDetailSheet(property: property),
    );
  }
}
