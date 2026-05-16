import 'package:dio/dio.dart';
import 'dio_error_mapper.dart';
import 'failures.dart';

/// Converts Dio exceptions into domain-layer Failure objects.
/// All data sources should use this to normalize errors.
Failure handleDioException(DioException e) {
  return DioErrorMapper.mapDioException(e);
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
