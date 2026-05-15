import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_new/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:mobile_new/features/payment/presentation/bloc/payment_state.dart';

class PaymentProcessingScreen extends StatelessWidget {
  final String bookingRef;
  final String bookingId;

  const PaymentProcessingScreen({
    super.key,
    required this.bookingRef,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentSuccessState) {
                context.go(
                  '/payment-success',
                  extra: state.booking,
                );
              } else if (state is PaymentFailureState) {
                context.go(
                  '/payment-failed',
                  extra: {
                    'message': state.message,
                    'reason': state.reason,
                    'bookingId': bookingId,
                  },
                );
              } else if (state is PaymentErrorState) {
                context.go(
                  '/payment-failed',
                  extra: {
                    'message': 'Error',
                    'reason': state.error,
                    'bookingId': bookingId,
                  },
                );
              }
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 32),
                  Text(
                    'Verifying Payment',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Please wait while we verify your payment. This usually takes a few seconds.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      if (state is PaymentProcessingState) {
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Attempt ${state.retryCount}/${state.maxRetries}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
