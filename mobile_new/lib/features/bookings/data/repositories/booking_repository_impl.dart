import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CheckoutResponse>> checkout({
    required String returnUrl,
    required String notifyUrl,
  }) async {
    try {
      final model = await remoteDataSource.checkout(
        returnUrl: returnUrl,
        notifyUrl: notifyUrl,
      );
      return Right(CheckoutResponse(
        booking: model.booking.toEntity(),
        paymentDetails: model.paymentDetails.toJson(),
      ));
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
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
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String id) async {
    try {
      final model = await remoteDataSource.getBookingById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(String id) async {
    try {
      final model = await remoteDataSource.cancelBooking(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
