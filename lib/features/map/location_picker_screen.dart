// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:flutter_map_smart/flutter_map_smart.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Default Location: Ghaziabad
  LatLng _pickedLocation = const LatLng(28.6692, 77.4538);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _pickedLocation),
          ),
        ],
      ),
      body: SmartLocationPicker(
        initialCenter: _pickedLocation,
        onLocationChanged: (latLng) {
          setState(() {
            _pickedLocation = latLng;
          });
        },
      ),
    );
  }
}
