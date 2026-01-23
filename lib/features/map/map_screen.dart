import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/firebase_service.dart';
import '../../../models/property.dart';
import '../../../core/auth_bloc.dart';
import 'bloc/property_bloc.dart';
import 'bloc/property_event.dart';
import 'bloc/property_state.dart';
import 'add_property_screen.dart';
import 'widgets/property_detail_sheet.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PropertyBloc(firebaseService: context.read<FirebaseService>())
            ..add(LoadProperties()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isNearbyActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final bloc = context.read<PropertyBloc>();
    if (query.isEmpty) {
      bloc.add(const SearchProperties(''));
      return;
    }

    // Filter properties locally
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // 1. Map or List View
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state.isListView
                    ? _buildListView(state.filteredProperties)
                    : _buildMapView(state.filteredProperties),
              ),

              // 2. Clear Search Bar (Top)
              _buildSearchBar(context),

              // 3. View Toggle (Bottom Right)
              _buildViewToggle(context, state.isListView),

              // 4. Nearby Toggle (Bottom Left - if on map)
              if (!state.isListView) _buildNearbyToggle(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<Property> properties) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(28.6692, 77.4549), // Default to Ghaziabad
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: properties.map((prop) {
            return Marker(
              point: LatLng(prop.lat, prop.lng),
              width: 80,
              height: 40,
              child: GestureDetector(
                onTap: () => _showDetails(context, prop),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    prop.formattedPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListView(List<Property> properties) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: properties.isEmpty
            ? const Center(child: Text('No properties found'))
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: properties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  return _buildPropertyCard(prop);
                },
              ),
      ),
    );
  }

  Widget _buildPropertyCard(Property prop) {
    return GestureDetector(
      onTap: () => _showDetails(context, prop),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              prop.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prop.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        prop.formattedPrice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prop.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: Color(0xFF673AB7)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<PropertyBloc>().add(SearchProperties(val));
                  },
                  onSubmitted: _performSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search properties or locations...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return IconButton(
                    icon: Icon(
                      authState.isOwner ? Icons.settings : Icons.login,
                      color: const Color(0xFF673AB7),
                    ),
                    onPressed: () => _showAuthDialog(context, authState),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, bool isListView) {
    return Positioned(
      right: 20,
      bottom: 30,
      child: FloatingActionButton.extended(
        onPressed: () => context.read<PropertyBloc>().add(ToggleViewMode()),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        icon: Icon(isListView ? Icons.map : Icons.list),
        label: Text(isListView ? 'Map View' : 'List View'),
      ),
    );
  }

  Widget _buildNearbyToggle() {
    return Positioned(
      left: 20,
      bottom: 30,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(30),
        color: _isNearbyActive ? const Color(0xFF673AB7) : Colors.white,
        child: InkWell(
          onTap: _toggleNearby,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.my_location,
                  size: 20,
                  color: _isNearbyActive
                      ? Colors.white
                      : const Color(0xFF673AB7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Nearby',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isNearbyActive
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAuthDialog(BuildContext context, AuthState authState) {
    if (authState.isOwner) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Owner Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('You are logged in as owner.'),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.add_business),
                title: const Text('Add New Property'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddPropertyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(Logout());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      final controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Owner Login'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Owner ID'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(LoginAsOwner(controller.text));
                Navigator.pop(context);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }
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
