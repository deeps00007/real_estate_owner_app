import 'package:bloc/bloc.dart';
import '../../../core/firebase_service.dart';
import '../../../models/property.dart';
import 'property_event.dart';
import 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final FirebaseService firebaseService;

  PropertyBloc({required this.firebaseService}) : super(const PropertyState()) {
    on<LoadProperties>(_onLoadProperties);
  }

  Future<void> _onLoadProperties(
    LoadProperties event,
    Emitter<PropertyState> emit,
  ) async {
    emit(state.copyWith(status: PropertyStatus.loading));
    
    await emit.forEach<List<Property>>(
      firebaseService.getPropertiesStream(firebaseService.currentUserId),
      onData: (properties) => state.copyWith(
        status: PropertyStatus.success,
        properties: properties,
      ),
      onError: (_, __) => state.copyWith(status: PropertyStatus.error),
    );
  }
}
