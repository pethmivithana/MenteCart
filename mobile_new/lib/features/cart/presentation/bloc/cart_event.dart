import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class GetCartEvent extends CartEvent {
  const GetCartEvent();
}

class AddCartItemEvent extends CartEvent {
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  const AddCartItemEvent({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });

  @override
  List<Object?> get props => [
    serviceId,
    serviceName,
    price,
    quantity,
    selectedDate,
    selectedSlot,
  ];
}

class UpdateCartItemEvent extends CartEvent {
  final String itemId;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  const UpdateCartItemEvent({
    required this.itemId,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });

  @override
  List<Object?> get props => [itemId, quantity, selectedDate, selectedSlot];
}

class RemoveCartItemEvent extends CartEvent {
  final String itemId;

  const RemoveCartItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Start watching cart expiry timer
class StartCartTimerEvent extends CartEvent {
  const StartCartTimerEvent();
}

/// Stop watching cart expiry timer
class StopCartTimerEvent extends CartEvent {
  const StopCartTimerEvent();
}

/// Update cart expiry time (called every second)
class CartTimerTickEvent extends CartEvent {
  final Duration remaining;

  const CartTimerTickEvent(this.remaining);

  @override
  List<Object?> get props => [remaining];
}
