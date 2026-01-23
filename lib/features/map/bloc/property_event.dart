import 'package:equatable/equatable.dart';

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
