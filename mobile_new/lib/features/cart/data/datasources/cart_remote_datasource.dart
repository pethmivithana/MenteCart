import 'package:dio/dio.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartItemModel> addItem({
    required String serviceId,
    required String serviceName,
    required double price,
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  });
  Future<CartItemModel> updateItem(
    String itemId, {
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  });
  Future<void> removeItem(String itemId);
}

String _slotDateYmd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

CartItemModel _itemFromCart(CartModel cart, String itemId) {
  for (final i in cart.items) {
    if (i.id == itemId) {
      return i;
    }
  }
  if (cart.items.isEmpty) {
    throw StateError('Cart response had no items');
  }
  return cart.items.last;
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl(this.dio);

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await dio.get('/cart');
      final data = response.data['data'] as Map<String, dynamic>;
      return CartModel.fromJson(data['cart'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<CartItemModel> addItem({
    required String serviceId,
    required String serviceName,
    required double price,
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  }) async {
    if (selectedDate == null ||
        selectedSlot == null ||
        selectedSlot.trim().isEmpty) {
      throw ArgumentError(
        'A slot date (YYYY-MM-DD) and slot time (HH:MM) are required to add this service to the cart.',
      );
    }
    try {
      final response = await dio.post(
        '/cart/items',
        data: {
          'serviceId': serviceId,
          'slotDate': _slotDateYmd(selectedDate),
          'slotTime': selectedSlot.trim(),
          'quantity': quantity,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final cart = CartModel.fromJson(data['cart'] as Map<String, dynamic>);
      if (cart.items.isEmpty) {
        throw StateError('Cart response had no items after add');
      }
      return cart.items.last;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<CartItemModel> updateItem(
    String itemId, {
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  }) async {
    try {
      final body = <String, dynamic>{'quantity': quantity};
      if (selectedDate != null) {
        body['slotDate'] = _slotDateYmd(selectedDate);
      }
      if (selectedSlot != null && selectedSlot.trim().isNotEmpty) {
        body['slotTime'] = selectedSlot.trim();
      }

      final response = await dio.patch(
        '/cart/items/$itemId',
        data: body,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final cart = CartModel.fromJson(data['cart'] as Map<String, dynamic>);
      return _itemFromCart(cart, itemId);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> removeItem(String itemId) async {
    try {
      await dio.delete('/cart/items/$itemId');
    } on DioException {
      rethrow;
    }
  }
}
