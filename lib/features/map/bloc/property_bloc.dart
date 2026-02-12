import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart'; // Added
import 'package:geolocator/geolocator.dart'; // Added
import '../../../core/firebase_service.dart';
import '../../../models/property.dart';
import 'property_event.dart';
import 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final FirebaseService firebaseService;

  PropertyBloc({required this.firebaseService}) : super(const PropertyState()) {
    on<LoadProperties>(_onLoadProperties);
    on<SearchProperties>((event, emit) {
      emit(state.copyWith(searchQuery: event.query));
    });
    on<DeleteProperty>((event, emit) async {
      await firebaseService.deleteProperty(event.propertyId);
    });
    on<ToggleViewMode>((event, emit) {
      emit(state.copyWith(isListView: !state.isListView));
    });
    on<ToggleNearbyFilter>((event, emit) {
      emit(state.copyWith(isNearbyActive: !state.isNearbyActive));
    });
    on<UpdateUserLocation>((event, emit) {
      emit(
        state.copyWith(
          userLatitude: event.latitude,
          userLongitude: event.longitude,
        ),
      );
    });
    on<FetchUserLocation>(_onFetchUserLocation); // Added
    on<AddProperty>((event, emit) async {
      await firebaseService.addProperty(event.property);
    });
    on<UpdateProperty>((event, emit) async {
      await firebaseService.updateProperty(event.property);
    });
  }

  Future<void> _onFetchUserLocation(
    FetchUserLocation event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();

      String address = 'Unknown Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Format: "City, State" (e.g., "Brisbane, Queensland")
          // fallback to locality or subLocality
          final city = place.locality?.isNotEmpty == true
              ? place.locality
              : place.subLocality;
          final state = place.administrativeArea;

          if (city != null && state != null) {
            address = '$city, $state';
          } else {
            address = city ?? state ?? 'Unknown Location';
          }
        }
      } catch (e) {
        print('Error reverse geocoding: $e');
      }

      emit(
        state.copyWith(
          userLatitude: position.latitude,
          userLongitude: position.longitude,
          currentAddress: address,
        ),
      );
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> _onLoadProperties(
    LoadProperties event,
    Emitter<PropertyState> emit,
  ) async {
    emit(state.copyWith(status: PropertyStatus.loading));

    await emit.forEach<List<Property>>(
      // Pass null to fetch ALL properties (marketplace mode), not just the current user's
      firebaseService.getPropertiesStream(null),
      onData: (properties) {
        print('Loaded ${properties.length} properties');
        return state.copyWith(
          status: PropertyStatus.success,
          properties: properties,
        );
      },
      onError: (error, stack) {
        print('Error loading properties: $error');
        return state.copyWith(status: PropertyStatus.error);
      },
    );
  }
}
