import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PaymentSuccessEvent extends PaymentEvent {
  final String bookingRef;
  final String bookingId;

  const PaymentSuccessEvent({
    required this.bookingRef,
    required this.bookingId,
  });

  @override
  List<Object?> get props => [bookingRef, bookingId];
}

class PaymentFailureEvent extends PaymentEvent {
  final String message;
  final String? reason;

  const PaymentFailureEvent({
    required this.message,
    this.reason,
  });

  @override
  List<Object?> get props => [message, reason];
}

class RefreshPaymentStatusEvent extends PaymentEvent {
  final String bookingId;
  final int maxRetries;
  final int intervalSeconds;

  const RefreshPaymentStatusEvent({
    required this.bookingId,
    this.maxRetries = 15,
    this.intervalSeconds = 2,
  });

  @override
  List<Object?> get props => [bookingId, maxRetries, intervalSeconds];
}
