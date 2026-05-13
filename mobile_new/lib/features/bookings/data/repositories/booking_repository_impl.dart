import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Booking>> checkout() async {
    try {
      final model = await remoteDataSource.checkout();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, BookingListResponse>> getBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await remoteDataSource.getBookings(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String id) async {
    try {
      final model = await remoteDataSource.getBookingById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(String id) async {
    try {
      final model = await remoteDataSource.cancelBooking(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }
}
