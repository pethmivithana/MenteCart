import 'package:equatable/equatable.dart';
import 'package:mobile_new/core/utils/json_parse.dart';
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
    final sid = json['serviceId'];
    String serviceIdStr;
    String serviceName;
    if (sid is Map<String, dynamic>) {
      serviceIdStr = idToString(sid['_id'] ?? sid[r'$oid']);
      serviceName = (sid['title'] ?? sid['name'] ?? 'Service') as String;
    } else {
      serviceIdStr = idToString(sid);
      serviceName = (json['serviceName'] as String?) ?? 'Service';
    }

    final slotDate = json['slotDate'] ?? json['selectedDate'];
    final slotTime = json['slotTime'] ?? json['selectedSlot'];
    DateTime? selectedDate;
    if (slotDate is String && slotDate.isNotEmpty) {
      selectedDate = DateTime.tryParse(slotDate) ??
          DateTime.tryParse('${slotDate}T00:00:00.000Z');
    }

    return CartItemModel(
      id: idToString(json['_id']),
      serviceId: serviceIdStr,
      serviceName: serviceName,
      price: asDouble(json['priceAtAdd'] ?? json['price']) ?? 0,
      quantity: asInt(json['quantity'], 1),
      selectedDate: selectedDate,
      selectedSlot: slotTime as String?,
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
        ((json['items'] as List<dynamic>?) ?? const [])
            .map((x) => CartItemModel.fromJson(x as Map<String, dynamic>)),
      ),
      userId: idToString(json['userId']),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
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
