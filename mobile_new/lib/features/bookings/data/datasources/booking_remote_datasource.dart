import 'package:dio/dio.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> checkout();
  Future<BookingListResponseModel> getBookings({
    int page = 1,
    int limit = 10,
    String? status,
  });
  Future<BookingModel> getBookingById(String id);
  Future<BookingModel> cancelBooking(String id);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl(this.dio);

  @override
  Future<BookingModel> checkout() async {
    try {
      final response = await dio.post('/bookings/checkout');
      return BookingModel.fromJson(response.data['data']);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<BookingListResponseModel> getBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'status': ?status,
      };

      final response = await dio.get(
        '/bookings',
        queryParameters: queryParams,
      );
      return BookingListResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    try {
      final response = await dio.get('/bookings/$id');
      return BookingModel.fromJson(response.data['data']);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<BookingModel> cancelBooking(String id) async {
    try {
      final response = await dio.patch('/bookings/$id/cancel');
      return BookingModel.fromJson(response.data['data']);
    } on DioException {
      rethrow;
    }
  }
}
