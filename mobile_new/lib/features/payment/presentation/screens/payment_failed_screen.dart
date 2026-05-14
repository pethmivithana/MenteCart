import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String message;
  final String? reason;
  final String? bookingId;

  const PaymentFailedScreen({
    Key? key,
    required this.message,
    this.reason,
    this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          reason ?? 'Something went wrong with your payment. Please try again.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (bookingId != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your booking is saved as pending. Complete payment to confirm.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.go('/checkout');
                      },
                      child: const Text('Retry Payment'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        context.go('/cart');
                      },
                      child: const Text('Back to Cart'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
