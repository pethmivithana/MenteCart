import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';

/// CartItemModel
class CartItemModel extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  const CartItemModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'] as String)
          : null,
      selectedSlot: json['selectedSlot'] as String?,
    );
  }

  CartItem toEntity() => CartItem(
        id: id,
        serviceId: serviceId,
        serviceName: serviceName,
        price: price,
        quantity: quantity,
        selectedDate: selectedDate,
        selectedSlot: selectedSlot,
      );

  @override
  List<Object?> get props => [
    id,
    serviceId,
    serviceName,
    price,
    quantity,
    selectedDate,
    selectedSlot,
  ];
}

/// CartModel
class CartModel extends Equatable {
  final List<CartItemModel> items;
  final String userId;
  final DateTime? expiresAt;

  const CartModel({
    required this.items,
    required this.userId,
    this.expiresAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: List<CartItemModel>.from(
        (json['items'] as List).map((x) => CartItemModel.fromJson(x)),
      ),
      userId: json['userId'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Cart toEntity() => Cart(
        items: items.map((m) => m.toEntity()).toList(),
        userId: userId,
        expiresAt: expiresAt,
      );

  @override
  List<Object?> get props => [items, userId, expiresAt];
}
