import 'package:equatable/equatable.dart';
import 'package:mobile_new/features/bookings/domain/entities/booking.dart';
import 'package:mobile_new/features/payment/data/models/payment_response_model.dart';


abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitialState extends PaymentState {
  const PaymentInitialState();
}

class PaymentInitiatedState extends PaymentState {
  final PaymentResponseModel paymentResponse;

  const PaymentInitiatedState(this.paymentResponse);

  @override
  List<Object?> get props => [paymentResponse];
}

class PaymentProcessingState extends PaymentState {
  final String bookingRef;
  final int retryCount;
  final int maxRetries;

  const PaymentProcessingState({
    required this.bookingRef,
    required this.retryCount,
    required this.maxRetries,
  });

  @override
  List<Object?> get props => [bookingRef, retryCount, maxRetries];
}

class PaymentSuccessState extends PaymentState {
  final Booking booking;

  const PaymentSuccessState(this.booking);

  @override
  List<Object?> get props => [booking];
}

class PaymentFailureState extends PaymentState {
  final String message;
  final String? reason;

  const PaymentFailureState({
    required this.message,
    this.reason,
  });

  @override
  List<Object?> get props => [message, reason];
}

class PaymentErrorState extends PaymentState {
  final String error;

  const PaymentErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
