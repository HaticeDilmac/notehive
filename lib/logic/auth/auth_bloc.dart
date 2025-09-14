import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class AuthDeleteAccountRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class SendEmailVerification extends AuthEvent {}

class EmailVerificationSent extends AuthEvent {}

// --- States ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User? user;
  AuthSuccess({this.user});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class EmailVerificationRequired extends AuthState {
  final String email;
  EmailVerificationRequired(this.email);
}

class EmailVerificationSentSuccess extends AuthState {
  final String message;
  EmailVerificationSentSuccess(this.message);
}

class PasswordResetEmailSent extends AuthState {
  final String message;
  PasswordResetEmailSent(this.message);
}

// --- Bloc ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  AuthBloc(this.authService) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.signIn(event.email, event.password);
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthFailure('Login failed'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.register(
          event.email,
          event.password,
          event.name,
        );
        if (user != null) {
          emit(EmailVerificationRequired(event.email));
        } else {
          emit(AuthFailure('Registration failed'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      print("CheckAuthStatus event received");
      final user = authService.currentUser;
      print("Current user: $user");
      if (user != null) {
        // Check if email is verified
        final isVerified = await authService.isEmailVerified();
        print("Email verified: $isVerified");
        if (isVerified) {
          print("Emitting AuthSuccess");
          emit(AuthSuccess(user: user));
        } else {
          print("Emitting EmailVerificationRequired");
          emit(EmailVerificationRequired(user.email ?? ''));
        }
      } else {
        print("No user found, emitting AuthInitial");
        emit(AuthInitial());
      }
    });

    on<AuthResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.resetPassword(event.email);
        emit(PasswordResetEmailSent('Şifre sıfırlama bağlantısı email ile gönderildi.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SendEmailVerification>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.sendEmailVerification();
        emit(
          EmailVerificationSentSuccess('Verification email sent successfully!'),
        );
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await authService.signOut();
      emit(AuthInitial());
    });

    on<AuthDeleteAccountRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.deleteAccount();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
