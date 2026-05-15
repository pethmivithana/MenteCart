import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bookings/presentation/bloc/bookings_bloc.dart';
import '../../../bookings/presentation/bloc/bookings_event.dart';
import '../../../bookings/presentation/bloc/bookings_state.dart';
import '../../../payment/data/models/payment_response_model.dart';
import '../../domain/entities/cart.dart';
import '../../presentation/bloc/cart_bloc.dart';
import '../../presentation/bloc/cart_event.dart';
import '../../presentation/bloc/cart_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const GetCartEvent());
  }

  Future<void> _launchPayHerePayment(
    BuildContext context,
    Map<String, dynamic> rawDetails,
    Cart cart,
  ) async {
    try {
      final model = PaymentDetailsModel.fromJson(rawDetails);
      
      // Navigate to PayHere gateway screen for card entry
      context.push(
        '/payhere-gateway',
        extra: {
          'bookingRef': model.orderId,
          'amount': double.parse(model.amount),
          'currency': model.currency,
          'customerName': '${model.firstName} ${model.lastName}'.trim(),
          'customerEmail': model.email,
          'customerPhone': model.phone,
        },
      );
    } catch (e) {
      debugPrint('PayHere setup error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment setup failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<BookingsBloc, BookingsState>(
        listener: (context, bookingState) async {
          if (bookingState is CheckoutSuccess) {
            if (bookingState.paymentResponse != null) {
              final cartState = context.read<CartBloc>().state;
              final cart = cartState is CartSuccess ? cartState.cart : null;
              
              // Launch PayHere gateway screen for card entry
              await _launchPayHerePayment(
                context,
                bookingState.paymentResponse!,
                cart!,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking placed successfully')),
              );
              context.go('/bookings/${bookingState.booking.id}');
            }
          }
          if (bookingState is BookingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(bookingState.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, bookingState) {
          final busy = bookingState is BookingsLoading;
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is CartLoading || cartState is CartInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (cartState is CartEmpty ||
                  (cartState is CartSuccess && cartState.cart.items.isEmpty)) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 64),
                      const SizedBox(height: 16),
                      const Text('Your cart is empty.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Browse services'),
                      ),
                    ],
                  ),
                );
              }
              if (cartState is! CartSuccess) {
                return const SizedBox.shrink();
              }
              final cart = cartState.cart;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Order summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...cart.items.map(
                    (e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.serviceName),
                      subtitle: Text(
                        '${DateFormat.yMMMd().format((e.selectedDate ?? DateTime.now()).toLocal())} · ${e.selectedSlot ?? ''} × ${e.quantity}',
                      ),
                      trailing: Text(
                        'LKR ${(e.price * e.quantity).toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'LKR ${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You will be redirected to PayHere sandbox to complete payment.',
                            style: TextStyle(fontSize: 13, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy
                        ? null
                        : () {
                            context
                                .read<BookingsBloc>()
                                .add(const CheckoutEvent());
                          },
                    child: busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm & Pay'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
