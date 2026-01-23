import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_smart/flutter_map_smart.dart';
import '../../../core/firebase_service.dart';
import '../../../models/property.dart';
import 'widgets/property_detail_sheet.dart';
import '../../../core/widgets/glass_container.dart';
import 'bloc/property_bloc.dart';
import 'bloc/property_event.dart';
import 'bloc/property_state.dart';
import 'add_property_screen.dart';

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
  bool _enableNearby = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. The Map
          BlocBuilder<PropertyBloc, PropertyState>(
            builder: (context, state) {
              if (state.status == PropertyStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == PropertyStatus.error) {
                return const Center(child: Text('Error loading properties'));
              }
              return FlutterMapSmart.simple(
                items: state.filteredProperties,
                latitude: (property) => property.lat,
                longitude: (property) => property.lng,
                markerImage: (property) => property.imageUrl,
                showUserLocation: true,
                enableNearby: _enableNearby,
                nearbyRadiusKm: 5.0,
                markerSize: 60,
                onTap: (property) =>
                    _showDetails(context, property as Property),
                onLocationPermissionDenied: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location needed for nearby'),
                      ),
                    ),
              );
            },
          ),

          // 2. Premium Search Bar (Top)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF673AB7)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          context.read<PropertyBloc>().add(
                            SearchProperties(val),
                          );
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search properties...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context.read<PropertyBloc>().add(
                            const SearchProperties(''),
                          );
                          setState(() {});
                        },
                      ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF673AB7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddPropertyScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Nearby Toggle Control (Bottom Left)
          Positioned(
            left: 20,
            bottom: 30,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nearby',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _enableNearby,
                    activeColor: const Color(0xFF673AB7),
                    onChanged: (val) {
                      setState(() {
                        _enableNearby = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating Zoom Controls or My Location could be here if needed
        ],
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
