import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import 'booking_status_widget.dart';

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
          if (state is CancellationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Booking cancelled successfully'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                context.go('/bookings');
              }
            });
          }
          if (state is BookingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingsLoading || state is CancellationLoading) {
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

          Booking? booking;
          if (state is BookingDetailSuccess) {
            booking = state.booking;
          } else if (state is CancellationSuccess) {
            booking = state.cancelledBooking;
          }

          if (booking == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Status chip
              Align(
                alignment: Alignment.topLeft,
                child: BookingStatusChip(
                  status: booking.status,
                  paymentStatus: booking.paymentStatus,
                ),
              ),
              const SizedBox(height: 16),
              // Booking header info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booking ID',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              Text(
                                booking.bookingRef,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Amount',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              Text(
                                'LKR ${booking.totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.blue.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Placed on ${DateFormat.yMMMd().add_jm().format(booking.createdAt.toLocal())}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Status timeline
              BookingStatusTimeline(
                status: booking.status,
                createdAt: booking.createdAt,
                completedAt: booking.completedAt,
              ),
              const Divider(height: 32),
              // Items section
              Text('Items', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...booking.items.map(
                (i) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(i.serviceName),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format((i.selectedDate ?? DateTime.now()).toLocal())} · ${i.selectedSlot ?? '—'} × ${i.quantity}',
                    ),
                    trailing: Text('LKR ${i.price.toStringAsFixed(2)}'),
                  ),
                ),
              ),
              // Payment info
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Status',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.paymentStatus.name.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color:
                                  booking.paymentStatus ==
                                      PaymentStatus.completed
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                      ),
                      if (booking.paymentFailureReason != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reason: ${booking.paymentFailureReason}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Cancel button
              if (booking.canBeCancelled) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel booking'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ] else if (booking.status == BookingStatus.cancelled) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'This booking has been cancelled and cannot be modified.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
