import 'package:bloc/bloc.dart';
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
  }

  Future<void> _onLoadProperties(
    LoadProperties event,
    Emitter<PropertyState> emit,
  ) async {
    emit(state.copyWith(status: PropertyStatus.loading));

    await emit.forEach<List<Property>>(
      firebaseService.getPropertiesStream(firebaseService.currentUserId),
      onData: (properties) {
        print('Loaded ${properties.length} properties');
        if (properties.isEmpty) {
          return state.copyWith(
            status: PropertyStatus.success,
            properties: [
              const Property(
                id: 'dummy',
                title: 'Test Property',
                description: 'Test Description',
                price: 100000,
                lat: 28.6692,
                lng: 77.4549,
                imageUrl: 'https://placeholder.com/150',
                type: 'House',
              ),
            ],
          );
        }
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
