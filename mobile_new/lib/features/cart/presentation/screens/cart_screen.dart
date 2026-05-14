import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const GetCartEvent());
  }

  String _formatDate(DateTime? d) {
    if (d == null) {
      return '—';
    }
    return DateFormat.yMMMd().format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          TextButton(
            onPressed: () => context.push('/checkout'),
            child: const Text('Checkout'),
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading || state is CartInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Browse services'),
                  ),
                ],
              ),
            );
          }
          if (state is CartSuccess) {
            final cart = state.cart;
            if (cart.items.isEmpty) {
              return Center(
                child: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Browse services'),
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cart.itemCount} item(s)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Total \$${cart.totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.serviceName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            RemoveCartItemEvent(item.id),
                                          );
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                '${_formatDate(item.selectedDate)} · ${item.selectedSlot ?? '—'}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)} each',
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: item.quantity > 1
                                        ? () {
                                            context.read<CartBloc>().add(
                                                  UpdateCartItemEvent(
                                                    itemId: item.id,
                                                    quantity: item.quantity - 1,
                                                    selectedDate:
                                                        item.selectedDate,
                                                    selectedSlot:
                                                        item.selectedSlot,
                                                  ),
                                                );
                                          }
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            UpdateCartItemEvent(
                                              itemId: item.id,
                                              quantity: item.quantity + 1,
                                              selectedDate: item.selectedDate,
                                              selectedSlot: item.selectedSlot,
                                            ),
                                          );
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push('/checkout'),
                      child: const Text('Proceed to checkout'),
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is CartFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<CartBloc>().add(
                          const GetCartEvent(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
