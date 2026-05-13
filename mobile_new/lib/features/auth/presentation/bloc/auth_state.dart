import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final User user;
  final String token;

  const AuthSuccess({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

class AuthFailure extends AuthState {
  final String message;
  final String? errorCode;

  const AuthFailure({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthUnauthorized extends AuthState {
  const AuthUnauthorized();
}
