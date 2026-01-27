import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart'; // Changed from flutter_map_smart
import 'package:latlong2/latlong.dart'; // Added for LatLng
import '../../../models/property.dart';
import 'bloc/property_bloc.dart';
import 'bloc/property_event.dart';
import 'bloc/property_state.dart';
import '../../core/auth_bloc.dart'; // Added
// Removed 'add_property_screen.dart' as it's not used in the provided context
import '../property_details/property_detail_screen.dart';
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
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // Keep _isNearbyActive as _toggleNearby is still called
  bool _isNearbyActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
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

  Future<void> _toggleNearby() async {
    final bloc = context.read<PropertyBloc>();

    if (!_isNearbyActive) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      bloc.add(UpdateUserLocation(position.latitude, position.longitude));

      _mapController.move(LatLng(position.latitude, position.longitude), 14.0);
    }

    setState(() {
      _isNearbyActive = !_isNearbyActive;
    });
    bloc.add(ToggleNearbyFilter());
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
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(
                          28.6692,
                          77.4549,
                        ), // Ghaziabad default
                        initialZoom: 13.0,
                        onTap: (_, __) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.realestate.owner.app.v1',
                        ),
                        MarkerLayer(
                          markers: state.filteredProperties.map((prop) {
                            return Marker(
                              point: LatLng(prop.lat, prop.lng),
                              width: 100,
                              height: 60,
                              child: GestureDetector(
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
                              ),
                            );
                          }).toList(),
                        ),
                      ],
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
                        onExpand: () {
                          // Implementation for expand
                        },
                        onNavigate: () async {
                          // Implementation for navigate
                        },
                        onRefresh: () =>
                            context.read<PropertyBloc>().add(LoadProperties()),
                        onFilter: () =>
                            _toggleNearby(), // Using filter for nearby toggle for now
                      ),
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
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Property'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price (e.g., 50000)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Location Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final double price = double.tryParse(priceController.text) ?? 0.0;
              // Using a simple ID generation strategy for demo
              final newProperty = Property(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: addressController.text.isNotEmpty
                    ? addressController.text
                    : 'New Listing',
                price: price,
                lat: _mapController.camera.center.latitude,
                lng: _mapController.camera.center.longitude,
                imageUrl: 'https://picsum.photos/400/300',
                type: 'apartment',
                ownerId: context.read<AuthBloc>().state.ownerId, // Set Owner ID
              );

              context.read<PropertyBloc>().add(AddProperty(newProperty));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Property Added!')));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
