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

class SwitchToBuyer extends AuthEvent {}

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
    on<SwitchToBuyer>(_onSwitchToBuyer);
    on<Logout>(_onLogout);

    // Listen to Firebase Auth changes
    _auth.authStateChanges().listen((user) {
      add(CheckAuthStatus());
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      // If no user, reset state completely
      emit(const AuthState());
    } else {
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

      await _auth.signInWithCredential(credential);
      // State updated via stream listener
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

  void _onSwitchToBuyer(SwitchToBuyer event, Emitter<AuthState> emit) {
    print("AuthBloc: _onSwitchToBuyer called");
    emit(state.copyWith(isOwner: false, ownerId: null));
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    print(
      "AuthBloc Change: Current: ${change.currentState.user?.uid} -> Next: ${change.nextState.user?.uid}",
    );
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    print("AuthBloc: Logout initiated");
    // 1. Sign out from providers
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print("Google SignOut error: $e");
    }
    await _auth.signOut();

    // 2. Clear state immediately
    emit(const AuthState(isLoading: false, user: null));
  }
}
