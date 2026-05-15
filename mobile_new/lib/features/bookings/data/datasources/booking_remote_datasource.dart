import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../../../../features/payment/data/models/payment_response_model.dart';

abstract class BookingRemoteDataSource {
  Future<PaymentResponseModel> checkout({
    required String returnUrl,
    required String notifyUrl,
  });
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
  Future<PaymentResponseModel> checkout({
    required String returnUrl,
    required String notifyUrl,
  }) async {
    try {
      final response = await dio.post(
        '/bookings/checkout',
        data: {
          'returnUrl': returnUrl,
          'notifyUrl': notifyUrl,
        },
      );
      // Backend returns: { success: true, message, data: { booking, paymentDetails } }
      final responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>;
      return PaymentResponseModel.fromJson(data);
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
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

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
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingModel.fromJson(data['booking'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<BookingModel> cancelBooking(String id) async {
    try {
      final response = await dio.post(
        '/bookings/$id/cancel',
        data: <String, dynamic>{},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingModel.fromJson(data['booking'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }
}
