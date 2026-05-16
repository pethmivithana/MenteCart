import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
/// Keeps business logic decoupled from Dio/HTTP error details.
abstract class Failure extends Equatable {
  final String message;
  final String? errorCode;

  const Failure({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({
    required super.message,
    super.errorCode,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, errorCode, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please log in again.',
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local storage error'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});
}

/// Cart has expired - user needs to refresh or re-add items
class CartExpiredFailure extends Failure {
  const CartExpiredFailure({
    super.message = 'Cart session expired. Please add items again.',
  });
}

/// Selected slot is fully booked
class SlotFullFailure extends Failure {
  const SlotFullFailure({super.message = 'Selected slot is fully booked'});
}

/// User has reached their daily booking limit
class DailyLimitFailure extends Failure {
  const DailyLimitFailure({
    super.message = 'You have reached your daily booking limit',
  });
}

/// Booking cannot be cancelled (e.g., already completed or cutoff passed)
class BookingNotCancellableFailure extends Failure {
  const BookingNotCancellableFailure({
    super.message = 'This booking cannot be cancelled',
  });
}
