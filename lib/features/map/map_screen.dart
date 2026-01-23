import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_smart/flutter_map_smart.dart';
import '../../../core/firebase_service.dart';
import '../../../models/property.dart';
import 'bloc/property_bloc.dart';
import 'bloc/property_event.dart';
import 'bloc/property_state.dart';

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
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state.status == PropertyStatus.initial ||
              state.status == PropertyStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == PropertyStatus.error) {
            return const Center(child: Text('Error loading properties'));
          }
          if (state.properties.isEmpty) {
            return const Center(child: Text('No properties found. Add one!'));
          }
          return FlutterMapSmart.simple(
            items: state.properties,
            latitude: (property) => property.lat,
            longitude: (property) => property.lng,
            markerImage: (property) => property.imageUrl,
            showUserLocation: false,
            enableNearby: false,
            markerSize: 70,
            onTap: (property) => _showDetails(context, property as Property),
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              property.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('₹${property.price.toStringAsFixed(0)}'),
            Text(property.description),
            Text('Type: ${property.type}'),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // Coming up next
  }
}
