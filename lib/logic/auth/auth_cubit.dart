import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> checkAuth() async {
    // TODO: FirebaseAuth.instance.currentUser kontrolü burada olacak
    await Future.delayed(const Duration(seconds: 2));
    emit(Unauthenticated());
  }

  Future<void> login() async {
    // TODO: Firebase login işlemi burada olacak
    emit(Authenticated());
  }

  Future<void> logout() async {
    // TODO: Firebase logout işlemi burada olacak
    emit(Unauthenticated());
  }
}
