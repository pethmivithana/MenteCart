import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bookings/presentation/bloc/bookings_bloc.dart';
import '../../../bookings/presentation/bloc/bookings_event.dart';
import '../../../bookings/presentation/bloc/bookings_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<BookingsBloc, BookingsState>(
        listener: (context, bookingState) {
          if (bookingState is CheckoutSuccess) {
            context.read<CartBloc>().add(const GetCartEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking confirmed')),
            );
            context.go('/bookings/${bookingState.booking.id}');
          }
          if (bookingState is BookingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(bookingState.message)),
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
                        '\$${(e.price * e.quantity).toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '\$${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy
                        ? null
                        : () {
                            context.read<BookingsBloc>().add(const CheckoutEvent());
                          },
                    child: busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm booking'),
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
