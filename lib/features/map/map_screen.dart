import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_smart/flutter_map_smart.dart';
import '../../../core/firebase_service.dart';
import '../../../models/property.dart';
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
  // State to toggle nearby filter
  bool _enableNearby = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
            ),
          ),
        ],
      ),
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
                items: state.properties,
                latitude: (property) => property.lat,
                longitude: (property) => property.lng,
                markerImage: (property) => property.imageUrl,

                showUserLocation: true,
                // Pass the toggle state here
                enableNearby: _enableNearby,
                nearbyRadiusKm: 5.0, // 5 km radius

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

          // 2. Toggle Control (Bottom Left)
          Positioned(
            left: 20,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nearby (5km)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _enableNearby,
                    activeColor: Colors.blue,
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
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                property.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              property.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            Text(
              '₹${property.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(property.description),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
