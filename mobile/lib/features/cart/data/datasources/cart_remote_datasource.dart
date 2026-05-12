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

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl(this.dio);

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await dio.get('/cart');
      return CartModel.fromJson(response.data['data']);
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
    try {
      final response = await dio.post(
        '/cart/items',
        data: {
          'serviceId': serviceId,
          'serviceName': serviceName,
          'price': price,
          'quantity': quantity,
          if (selectedDate != null) 'selectedDate': selectedDate.toIso8601String(),
          if (selectedSlot != null) 'selectedSlot': selectedSlot,
        },
      );
      return CartItemModel.fromJson(response.data['data']);
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
      final response = await dio.patch(
        '/cart/items/$itemId',
        data: {
          'quantity': quantity,
          if (selectedDate != null) 'selectedDate': selectedDate.toIso8601String(),
          if (selectedSlot != null) 'selectedSlot': selectedSlot,
        },
      );
      return CartItemModel.fromJson(response.data['data']);
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
