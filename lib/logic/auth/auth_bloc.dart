import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notehive/core/auth_service.dart';

// --- Events ---
abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email, password;
  AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String email, password, name;
  AuthRegisterRequested(this.email, this.password, this.name);
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  AuthResetPasswordRequested(this.email);
}

class AuthLogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

// --- States ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// --- Bloc ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  AuthBloc(this.authService) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.signIn(event.email, event.password);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      final user = authService.currentUser;
      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthInitial());
      }
    });

    on<AuthResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.resetPassword(event.email);
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await authService.signOut();
      emit(AuthInitial());
    });
  }
}
