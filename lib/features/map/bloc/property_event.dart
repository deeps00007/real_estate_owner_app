import 'package:equatable/equatable.dart';
import '../../../models/property.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class LoadProperties extends PropertyEvent {}

class SearchProperties extends PropertyEvent {
  final String query;
  const SearchProperties(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteProperty extends PropertyEvent {
  final String propertyId;
  const DeleteProperty(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class ToggleViewMode extends PropertyEvent {}

class ToggleNearbyFilter extends PropertyEvent {}

class UpdateUserLocation extends PropertyEvent {
  final double latitude;
  final double longitude;

  const UpdateUserLocation(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class FetchUserLocation extends PropertyEvent {}

class LoadUserActivity extends PropertyEvent {}

class ToggleSaved extends PropertyEvent {
  final String propertyId;
  const ToggleSaved(this.propertyId);
  @override
  List<Object> get props => [propertyId];
}

class AddToRecent extends PropertyEvent {
  final String propertyId;
  const AddToRecent(this.propertyId);
  @override
  List<Object> get props => [propertyId];
}

class AddProperty extends PropertyEvent {
  final Property property;
  const AddProperty(this.property);

  @override
  List<Object?> get props => [property];
}

class UpdateProperty extends PropertyEvent {
  final Property property;
  const UpdateProperty(this.property);

  @override
  List<Object?> get props => [property];
}
