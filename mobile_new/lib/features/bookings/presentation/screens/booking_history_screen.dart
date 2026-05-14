import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(const GetBookingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BookingsBloc>().add(
                  const GetBookingsEvent(),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: BlocBuilder<BookingsBloc, BookingsState>(
        builder: (context, state) {
          if (state is BookingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<BookingsBloc>().add(
                          const GetBookingsEvent(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is BookingsSuccess) {
            if (state.bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_note, size: 56),
                    const SizedBox(height: 12),
                    const Text('No bookings yet'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Browse services'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final b = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      '${b.items.length} service(s) · ${b.status.name}',
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd()
                          .add_jm()
                          .format(b.createdAt.toLocal()),
                    ),
                    trailing: Text('\$${b.totalAmount.toStringAsFixed(2)}'),
                    onTap: () async {
                      await context.push('/bookings/${b.id}');
                      if (context.mounted) {
                        context.read<BookingsBloc>().add(
                              const GetBookingsEvent(),
                            );
                      }
                    },
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text('Loading bookings…'),
          );
        },
      ),
    );
  }
}
