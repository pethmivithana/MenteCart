import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartSuccess extends CartState {
  final Cart cart;
  final Duration? timeRemaining; // Time until cart expires

  const CartSuccess(this.cart, {this.timeRemaining});

  @override
  List<Object?> get props => [cart, timeRemaining];
}

/// Cart has expired - user needs to refresh
class CartExpired extends CartState {
  const CartExpired();
}

class CartFailure extends CartState {
  final String message;
  final String? errorCode;

  const CartFailure({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class CartEmpty extends CartState {
  const CartEmpty();
}
