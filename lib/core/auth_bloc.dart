import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginWithGoogle extends AuthEvent {}

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
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isOwner = false,
    this.ownerId,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isOwner,
    String? ownerId,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isOwner: isOwner ?? this.isOwner,
      ownerId: ownerId ?? this.ownerId,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isOwner, ownerId, user, isLoading, error];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String defaultOwnerId = 'OWNER123';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginAsOwner>(_onLoginAsOwner);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(state.copyWith(user: user));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(state.copyWith(isLoading: false)); // User canceled
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      emit(state.copyWith(user: userCredential.user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onLoginAsOwner(LoginAsOwner event, Emitter<AuthState> emit) {
    if (event.ownerId == defaultOwnerId) {
      emit(state.copyWith(isOwner: true, ownerId: event.ownerId));
    } else {
      emit(state.copyWith(error: "Invalid Owner ID"));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    emit(const AuthState());
  }
}
