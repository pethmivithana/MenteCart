import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bookings/presentation/bloc/bookings_bloc.dart';
import '../../../bookings/presentation/bloc/bookings_event.dart';
import '../../../bookings/presentation/bloc/bookings_state.dart';
import '../../../payment/data/models/payment_response_model.dart';
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
  ) async {
    try {
      final model = PaymentDetailsModel.fromJson(rawDetails);

      // PayHere sandbox checkout endpoint
      const payhereUrl = 'https://sandbox.payhere.lk/pay/checkout';

      final params = <String, String>{
        'merchant_id': model.merchantId,
        'return_url': model.returnUrl,
        'cancel_url': model.cancelUrl.isNotEmpty ? model.cancelUrl : model.returnUrl,
        'notify_url': model.notifyUrl,
        'order_id': model.orderId,
        'items': model.items,
        'amount': model.amount,
        'currency': model.currency,
        'first_name': model.firstName,
        'last_name': model.lastName,
        'email': model.email,
        'phone': model.phone,
        'address': model.address,
        'city': model.city,
        'country': model.country,
        'merchant_key': model.merchantKey,
      };

      // Remove empty values
      params.removeWhere((_, v) => v.isEmpty);

      final uri = Uri.parse(payhereUrl).replace(queryParameters: params);

      debugPrint('Launching PayHere URL: $uri');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open PayHere. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('PayHere launch error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment launch failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<BookingsBloc, BookingsState>(
        listener: (context, bookingState) {
          if (bookingState is CheckoutSuccess) {
            if (bookingState.paymentResponse != null) {
              // Launch PayHere payment in browser
              _launchPayHerePayment(context, bookingState.paymentResponse!);

              // Navigate to payment processing screen to poll for status
              context.go(
                '/payment-processing',
                extra: {
                  'bookingRef': bookingState.booking.bookingRef,
                  'bookingId': bookingState.booking.id,
                },
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