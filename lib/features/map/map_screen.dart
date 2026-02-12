import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_smart/flutter_map_smart.dart' hide debugPrint;
import 'package:flutter_map/flutter_map.dart' show MapController, TileLayer;

import 'package:latlong2/latlong.dart'; // Transitive from flutter_map_smart
import '../../../models/property.dart';
import 'bloc/property_bloc.dart';
import 'bloc/property_event.dart';
import 'bloc/property_state.dart';
import '../../core/auth_bloc.dart'; // Added
// Removed 'add_property_screen.dart' as it's not used in the provided context
import '../property_details/property_detail_screen.dart';
import 'widgets/floating_action_dock.dart';
import 'widgets/map_property_card.dart';
import '../admin/add_edit_property_screen.dart';
import 'package:geocoding/geocoding.dart' as geo;
// import 'package:geolocator/geolocator.dart'; // Handled by package

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Keep _isNearbyActive as _toggleNearby is still called
  bool _isNearbyActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final bloc = context.read<PropertyBloc>();
    if (query.isEmpty) {
      bloc.add(const SearchProperties(''));
      return;
    }
    bloc.add(SearchProperties(query));

    // Try to geocode and move map
    try {
      List<geo.Location> locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _mapController.move(
          LatLng(location.latitude, location.longitude),
          13.0,
        );
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  void _toggleNearby() {
    setState(() {
      _isNearbyActive = !_isNearbyActive;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isNearbyActive
              ? 'Nearby properties visible (5km radius)'
              : 'Showing all properties',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 100,
          left: 20,
          right: 20,
        ), // Above dock
        backgroundColor: _isNearbyActive
            ? const Color(0xFFFF80AB)
            : Colors.grey[800],
      ),
    );
    // PropertyBloc nearby filter removed in favor of UI filtering
  }

  void _onMarkerTap(Property property) {
    // Check if property exists in filtered list
    final state = context.read<PropertyBloc>().state;
    final index = state.filteredProperties.indexWhere(
      (p) => p.id == property.id,
    );
    if (index != -1) {
      _scrollController.animateTo(
        index * 296.0, // 280 width + 16 separator
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _recenterMap() {
    // Reset to default Delphi location
    _mapController.move(const LatLng(28.6139, 77.2090), 13.0);
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restart_alt, color: Color(0xFFFF80AB)),
              title: const Text('Reset Map View'),
              onTap: () {
                Navigator.pop(context);
                _recenterMap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFFFF80AB)),
              title: const Text('About this Map'),
              subtitle: const Text('Using FlutterMapSmart & OpenStreetMap'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<PropertyBloc, PropertyState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  // ... (Existing Map and Overlays)
                  // 1. Full Screen Map
                  Positioned.fill(
                    child: FlutterMapSmart.simple(
                      mapController: _mapController,
                      items: state.filteredProperties,
                      initialCenter: const LatLng(28.6139, 77.2090), // Delhi
                      latitude: (Property prop) => prop.lat,
                      longitude: (Property prop) => prop.lng,
                      markerImage: (Property prop) => prop.imageUrl,
                      onTap: (Property prop) => _onMarkerTap(prop),
                      onMapTap: (_, __) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      showUserLocation: _isNearbyActive, // Or track separately
                      enableNearby: _isNearbyActive,
                      nearbyRadiusKm: 5.0, // Default 5km radius
                      radiusColor: const Color(0xFF6366F1).withOpacity(0.12),
                      //   children: [
                      //     TileLayer(
                      //       urlTemplate:
                      //           'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      //       userAgentPackageName:
                      //           'com.realestate.owner.app.v1', // Fix for OSM policy
                      //     ),
                      //   ],
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
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: state.filteredProperties.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
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
                        onNavigate: _recenterMap,
                        onRefresh: () =>
                            context.read<PropertyBloc>().add(LoadProperties()),
                        onFilter: () =>
                            _toggleNearby(), // Using filter for nearby toggle for now
                        onMore: _showMoreOptions,
                        isNearbyActive: _isNearbyActive,
                      ),

                      // child: FloatingActionDock(
                      //   onExpand: () {
                      //     // Implementation for expand
                      //   },
                      //   onNavigate: () async {
                      //     // Implementation for navigate
                      //   },
                      // ... (removed old implementation)
                    ),
                  ),

                  // 5. Admin Add Property Button
                  if (authState.isOwner)
                    Positioned(
                      bottom: 110,
                      right: 20,
                      child: FloatingActionButton(
                        backgroundColor: const Color(0xFFFF80AB),
                        onPressed: () => _showAddPropertyDialog(context),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
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
        onSubmitted: _performSearch, // Restore search functionality
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }

  void _showAddPropertyDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPropertyScreen()),
    );
  }
}
