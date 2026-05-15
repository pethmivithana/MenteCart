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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 My Bookings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh bookings',
            onPressed: () => context.read<BookingsBloc>().add(
                  const GetBookingsEvent(),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Back to home',
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
                  const Text('❌', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Error loading bookings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFEF4444),
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => context.read<BookingsBloc>().add(
                          const GetBookingsEvent(),
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
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
                    const Text('✨', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 12),
                    Text(
                      'No bookings yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start booking wellness services!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.explore),
                      label: const Text('Browse Services'),
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
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
