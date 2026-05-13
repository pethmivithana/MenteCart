import 'package:dio/dio.dart';
import 'failures.dart';

/// Converts Dio exceptions into domain-layer Failure objects.
/// All data sources should use this to normalize errors.
Failure handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkFailure(message: 'Request timed out. Check your connection.');

    case DioExceptionType.connectionError:
      return const NetworkFailure();

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final message = _extractMessage(data);
      final errorCode = _extractErrorCode(data);

      if (statusCode == 401) {
        return const UnauthorizedFailure();
      }
      if (statusCode == 404) {
        return NotFoundFailure(message: message);
      }
      if (statusCode == 422) {
        return ValidationFailure(message: message);
      }
      return ServerFailure(
        message: message,
        errorCode: errorCode,
        statusCode: statusCode,
      );

    default:
      return const UnknownFailure();
  }
}

String _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message']?.toString() ?? 'An error occurred';
  }
  return 'An error occurred';
}

String? _extractErrorCode(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['errorCode']?.toString();
  }
  return null;
}
