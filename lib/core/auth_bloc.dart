import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginAsOwner extends AuthEvent {
  final String ownerId;
  const LoginAsOwner(this.ownerId);
  @override
  List<Object?> get props => [ownerId];
}

class Logout extends AuthEvent {}

// State
class AuthState extends Equatable {
  final bool isOwner;
  final String? ownerId;

  const AuthState({this.isOwner = false, this.ownerId});

  @override
  List<Object?> get props => [isOwner, ownerId];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String defaultOwnerId = 'OWNER123';

  AuthBloc() : super(const AuthState()) {
    on<LoginAsOwner>((event, emit) {
      if (event.ownerId == defaultOwnerId) {
        emit(AuthState(isOwner: true, ownerId: event.ownerId));
      }
    });

    on<Logout>((event, emit) {
      emit(const AuthState());
    });
  }
}
