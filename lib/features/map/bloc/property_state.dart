import 'package:equatable/equatable.dart';
import '../../../models/property.dart';

enum PropertyStatus { initial, loading, success, error }

class PropertyState extends Equatable {
  final PropertyStatus status;
  final List<Property> properties;

  const PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
  });

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
  }) {
    return PropertyState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
    );
  }

  @override
  List<Object?> get props => [status, properties];
}
