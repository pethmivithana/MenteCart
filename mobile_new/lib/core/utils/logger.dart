import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = '[MenteCart]';

  static void logDebug(String context, String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      final output = data != null ? '$message | $data' : message;
      debugPrint('$_tag [DEBUG] [$context] $output');
    }
  }

  static void logInfo(String context, String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      final output = data != null ? '$message | $data' : message;
      debugPrint('$_tag [INFO] [$context] $output');
    }
  }

  static void logWarning(String context, String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      final output = data != null ? '$message | $data' : message;
      debugPrint('$_tag [WARN] [$context] $output');
    }
  }

  static void logError(
    String context,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  ]) {
    if (kDebugMode) {
      final errorStr = error != null ? '\nError: $error' : '';
      final stackStr = stackTrace != null ? '\nStackTrace: $stackTrace' : '';
      final dataStr = data != null ? '\nData: $data' : '';
      debugPrint(
        '$_tag [ERROR] [$context] $message$errorStr$dataStr$stackStr',
      );
    }
  }

  static void logCheckoutError(
    String message,
    Map<String, dynamic>? details,
  ) {
    logError('CheckoutFlow', message, null, null, details);
  }

  static void logPaymentError(
    String message,
    Map<String, dynamic>? details,
  ) {
    logError('PaymentGateway', message, null, null, details);
  }

  static void logCartError(
    String message,
    Map<String, dynamic>? details,
  ) {
    logError('CartBloc', message, null, null, details);
  }
}
