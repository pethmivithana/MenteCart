import 'package:dio/dio.dart';
import 'failures.dart';

/// Maps Dio exceptions to typed Failure objects.
/// Handles specific backend error codes and HTTP status codes.
class DioErrorMapper {
  static Failure mapDioException(DioException dioException) {
    if (dioException.type == DioExceptionType.connectionTimeout ||
        dioException.type == DioExceptionType.receiveTimeout ||
        dioException.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure();
    }

    if (dioException.type == DioExceptionType.unknown) {
      if (dioException.error is SocketException) {
        return const NetworkFailure();
      }
      return UnknownFailure(
        message: dioException.message ?? 'An unexpected error occurred',
      );
    }

    final statusCode = dioException.response?.statusCode;
    final responseData = dioException.response?.data;

    // Handle different status codes
    if (statusCode == 401) {
      return const UnauthorizedFailure();
    }

    if (statusCode == 404) {
      final message =
          _extractErrorMessage(responseData) ?? 'Resource not found';
      return NotFoundFailure(message: message);
    }

    if (statusCode == 400) {
      return _handleBadRequest(responseData);
    }

    if (statusCode == 409) {
      return _handleConflict(responseData);
    }

    if (statusCode == 403) {
      final message = _extractErrorMessage(responseData) ?? 'Access denied';
      return BookingNotCancellableFailure(message: message);
    }

    if (statusCode != null && statusCode >= 500) {
      final message = _extractErrorMessage(responseData) ?? 'Server error';
      return ServerFailure(message: message, statusCode: statusCode);
    }

    final message =
        _extractErrorMessage(responseData) ??
        dioException.message ??
        'Unknown error';
    return ServerFailure(message: message, statusCode: statusCode);
  }

  /// Handle 400 Bad Request - could be validation or cart expiry
  static Failure _handleBadRequest(dynamic responseData) {
    final message = _extractErrorMessage(responseData);

    // Check for cart expiry
    if (message?.toLowerCase().contains('expired') ?? false) {
      return CartExpiredFailure(message: message ?? 'Cart session expired');
    }

    return ValidationFailure(message: message ?? 'Invalid request');
  }

  /// Handle 409 Conflict - could be slot full, daily limit, or transition conflict
  static Failure _handleConflict(dynamic responseData) {
    final message = _extractErrorMessage(responseData);

    // Check for slot fully booked
    if (message?.toLowerCase().contains('fully booked') ?? false) {
      return SlotFullFailure(
        message: message ?? 'Selected slot is fully booked',
      );
    }

    // Check for daily limit
    if (message?.toLowerCase().contains('daily booking limit') ??
        false || message?.toLowerCase().contains('daily limit') ??
        false) {
      return DailyLimitFailure(
        message: message ?? 'You have reached your daily booking limit',
      );
    }

    return ServerFailure(message: message ?? 'Conflict error', statusCode: 409);
  }

  /// Extract error message from various response formats
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map<String, dynamic>) {
      // Try common error message fields
      final message =
          responseData['message'] ??
          responseData['error'] ??
          responseData['msg'] ??
          responseData['errors']?.toString();

      if (message is String) {
        return message.isNotEmpty ? message : null;
      }
    }

    if (responseData is String) {
      return responseData.isNotEmpty ? responseData : null;
    }

    return null;
  }
}

// Socket exception is from dart:io
class SocketException implements Exception {
  SocketException(this.message);
  final String message;
}
