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
      create: (context) => PropertyBloc(
        firebaseService: context.read<FirebaseService>(),
      )..add(LoadProperties()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

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
      body: BlocBuilder<PropertyBloc, PropertyState>(
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
            // Try using the URL for markers. If it fails due to network lag, 
            // return null to use default pin, and show image in bottom sheet.
            markerImage: (property) => property.imageUrl, 
            
            showUserLocation: true,
            enableNearby: true,
            nearbyRadiusKm: 5.0,
            markerSize: 60,
            onTap: (property) => _showDetails(context, property as Property),
            onLocationPermissionDenied: () =>
                ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location needed for nearby')),
            ),
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows bigger sheet
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40, 
                height: 5, 
                decoration: BoxDecoration(
                  color: Colors.grey[300], 
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                property.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    Container(
                      height: 250, 
                      color: Colors.grey[200], 
                      child: const Center(child: Icon(Icons.broken_image))
                    ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Details
            Text(
              property.title, 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              '₹${property.price.toStringAsFixed(0)}', 
              style: const TextStyle(
                fontSize: 20, 
                color: Colors.green, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            Text(
              property.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text(property.type), 
              backgroundColor: Colors.blue[50],
            ),
            const SizedBox(height: 30), // Padding for bottom
          ],
        ),
      ),
    );
  }
}
