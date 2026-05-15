import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_new/features/bookings/domain/repositories/booking_repository.dart';
import 'package:mobile_new/features/payment/presentation/bloc/payment_event.dart';
import 'package:mobile_new/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final BookingRepository bookingRepository;

  PaymentBloc({required this.bookingRepository})
      : super(const PaymentInitialState()) {
    on<RefreshPaymentStatusEvent>(_onRefreshPaymentStatus);
    on<PaymentSuccessEvent>(_onPaymentSuccess);
    on<PaymentFailureEvent>(_onPaymentFailure);
  }

  Future<void> _onRefreshPaymentStatus(
    RefreshPaymentStatusEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      int retryCount = 0;
      const pollIntervalMs = 2000; // 2 seconds

      emit(PaymentProcessingState(
        bookingRef: 'Processing...',
        retryCount: retryCount,
        maxRetries: event.maxRetries,
      ));

      while (retryCount < event.maxRetries) {
        await Future.delayed(Duration(milliseconds: pollIntervalMs));

        try {
          final result = await bookingRepository.getBookingById(event.bookingId);
          
          result.fold(
            (failure) {
              // On error, continue polling
              retryCount++;
              emit(PaymentProcessingState(
                bookingRef: 'Verifying...',
                retryCount: retryCount,
                maxRetries: event.maxRetries,
              ));
            },
            (booking) {
              // Success if booking is confirmed and payment is completed
              if (booking.status.toString().endsWith('confirmed') && 
                  booking.paymentStatus.toString().endsWith('completed')) {
                emit(PaymentSuccessState(booking));
              } else if (booking.paymentStatus.toString().endsWith('failed') ||
                  booking.status.toString().endsWith('failed')) {
                emit(const PaymentFailureState(
                  message: 'Payment Failed',
                  reason: 'Your payment was declined. Please try again.',
                ));
              } else if (booking.paymentStatus.toString().endsWith('cancelled') ||
                  booking.status.toString().endsWith('cancelled')) {
                emit(const PaymentFailureState(
                  message: 'Payment Cancelled',
                  reason: 'Payment was cancelled.',
                ));
              } else {
                retryCount++;
                emit(PaymentProcessingState(
                  bookingRef: booking.bookingRef,
                  retryCount: retryCount,
                  maxRetries: event.maxRetries,
                ));
              }
            },
          );
        } catch (e) {
          retryCount++;
          // Continue polling even if request fails
          emit(PaymentProcessingState(
            bookingRef: 'Verifying...',
            retryCount: retryCount,
            maxRetries: event.maxRetries,
          ));
        }
      }

      // Timeout - show failure
      emit(const PaymentFailureState(
        message: 'Payment verification timeout',
        reason:
            'Could not confirm payment. Your booking is pending verification. Please check your booking history.',
      ));
    } catch (e) {
      emit(PaymentErrorState('Error checking payment status: $e'));
    }
  }

  Future<void> _onPaymentSuccess(
    PaymentSuccessEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final result = await bookingRepository.getBookingById(event.bookingId);
      result.fold(
        (failure) => emit(PaymentErrorState('Failed to load booking: ${failure.message}')),
        (booking) => emit(PaymentSuccessState(booking)),
      );
    } catch (e) {
      emit(PaymentErrorState('Failed to load booking: $e'));
    }
  }

  Future<void> _onPaymentFailure(
    PaymentFailureEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentFailureState(
      message: event.message,
      reason: event.reason,
    ));
  }
}
