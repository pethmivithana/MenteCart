import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(GetBookingByIdEvent(widget.bookingId));
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking'),
        content: const Text(
          'Cancel this booking? Capacity for your slots will be released.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      context.read<BookingsBloc>().add(CancelBookingEvent(widget.bookingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            onPressed: () => context.go('/bookings'),
          ),
        ],
      ),
      body: BlocConsumer<BookingsBloc, BookingsState>(
        listener: (context, state) {
          if (state is BookingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                  FilledButton(
                    onPressed: () => context.read<BookingsBloc>().add(
                          GetBookingByIdEvent(widget.bookingId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is! BookingDetailSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          final b = state.booking;
          final canCancel = b.status != BookingStatus.cancelled &&
              b.status != BookingStatus.completed;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Status: ${b.status.name}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Placed ${DateFormat.yMMMd().add_jm().format(b.createdAt.toLocal())}',
              ),
              const SizedBox(height: 8),
              Text('Total \$${b.totalAmount.toStringAsFixed(2)}'),
              const Divider(height: 32),
              Text('Items', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...b.items.map(
                (i) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(i.serviceName),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format((i.selectedDate ?? DateTime.now()).toLocal())} · ${i.selectedSlot ?? ''} × ${i.quantity}',
                    ),
                    trailing: Text('\$${i.price.toStringAsFixed(2)}'),
                  ),
                ),
              ),
              if (canCancel) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel booking'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
