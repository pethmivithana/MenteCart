import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Cart>> getCart() async {
    try {
      final model = await remoteDataSource.getCart();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, CartItem>> addItem({
    required String serviceId,
    required String serviceName,
    required double price,
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  }) async {
    try {
      final model = await remoteDataSource.addItem(
        serviceId: serviceId,
        serviceName: serviceName,
        price: price,
        quantity: quantity,
        selectedDate: selectedDate,
        selectedSlot: selectedSlot,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, CartItem>> updateItem(
    String itemId, {
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  }) async {
    try {
      final model = await remoteDataSource.updateItem(
        itemId,
        quantity: quantity,
        selectedDate: selectedDate,
        selectedSlot: selectedSlot,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(String itemId) async {
    try {
      await remoteDataSource.removeItem(itemId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }
}
