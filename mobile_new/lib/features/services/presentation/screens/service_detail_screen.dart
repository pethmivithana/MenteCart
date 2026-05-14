import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_detail_bloc.dart';

/// Service detail: browse slots and add to cart (requires date + time + qty).
class ServiceDetailScreen extends StatelessWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ServiceDetailBloc>()..add(LoadServiceDetailEvent(serviceId)),
      child: _ServiceDetailBody(serviceId: serviceId),
    );
  }
}

class _ServiceDetailBody extends StatefulWidget {
  final String serviceId;

  const _ServiceDetailBody({required this.serviceId});

  @override
  State<_ServiceDetailBody> createState() => _ServiceDetailBodyState();
}

class _ServiceDetailBodyState extends State<_ServiceDetailBody> {
  String? _selectedDate;
  String? _selectedTime;
  int _quantity = 1;
  String? _lastLoadedServiceId;

  List<String> _bookableDates(Service s) {
    final dates = <String>{};
    for (final sl in s.availableSlots) {
      if (sl.remaining > 0) {
        dates.add(sl.date);
      }
    }
    final list = dates.toList()..sort();
    return list;
  }

  List<ServiceSlot> _slotsForDate(Service s, String date) {
    return s.availableSlots
        .where((e) => e.date == date && e.remaining > 0)
        .toList();
  }

  ServiceSlot? _resolvedSlot(Service s) {
    if (_selectedDate == null || _selectedTime == null) {
      return null;
    }
    for (final sl in s.availableSlots) {
      if (sl.date == _selectedDate && sl.time == _selectedTime) {
        return sl;
      }
    }
    return null;
  }

  void _syncSlotDefaults(Service service) {
    if (_lastLoadedServiceId == service.id) {
      return;
    }
    _lastLoadedServiceId = service.id;
    final dates = _bookableDates(service);
    _selectedDate = dates.isNotEmpty ? dates.first : null;
    final times =
        _selectedDate != null ? _slotsForDate(service, _selectedDate!) : [];
    _selectedTime = times.isNotEmpty ? times.first.time : null;
    _quantity = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: BlocListener<ServiceDetailBloc, ServiceDetailState>(
        listenWhen: (prev, curr) => curr is ServiceDetailLoaded,
        listener: (context, state) {
          if (state is ServiceDetailLoaded) {
            setState(() => _syncSlotDefaults(state.service));
          }
        },
        child: BlocBuilder<ServiceDetailBloc, ServiceDetailState>(
          builder: (context, state) {
            if (state is ServiceDetailLoading ||
                state is ServiceDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ServiceDetailFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.read<ServiceDetailBloc>().add(
                              LoadServiceDetailEvent(widget.serviceId),
                            ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is! ServiceDetailLoaded) {
              return const SizedBox.shrink();
            }
            final service = state.service;
            final dates = _bookableDates(service);
            final times = _selectedDate != null
                ? _slotsForDate(service, _selectedDate!)
                : <ServiceSlot>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (service.imageUrl != null &&
                      service.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          service.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported, size: 48),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    service.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${service.price.toStringAsFixed(2)} · ${service.duration} min · ${service.category}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(service.description),
                  const SizedBox(height: 24),
                  Text(
                    'Book a slot',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (dates.isEmpty)
                    const Text(
                      'No open slots right now. Try another service or check back later.',
                    )
                  else ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedDate != null && dates.contains(_selectedDate)
                          ? _selectedDate
                          : null,
                      items: dates
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedDate = v;
                        final nt =
                            v != null ? _slotsForDate(service, v) : <ServiceSlot>[];
                        _selectedTime =
                            nt.isNotEmpty ? nt.first.time : null;
                        _quantity = 1;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedTime != null &&
                              times.any((t) => t.time == _selectedTime)
                          ? _selectedTime
                          : null,
                      items: times
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.time,
                              child: Text(
                                '${t.time} (${t.remaining} left)',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedTime = v;
                        _quantity = 1;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Quantity'),
                        const Spacer(),
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_quantity'),
                        IconButton(
                          onPressed: () {
                            final slot = _resolvedSlot(service);
                            final max = slot?.remaining ?? 1;
                            if (_quantity < max) {
                              setState(() => _quantity++);
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        final slot = _resolvedSlot(service);
                        if (slot == null ||
                            _selectedDate == null ||
                            _selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pick a date and time first.'),
                            ),
                          );
                          return;
                        }
                        final date = DateTime.tryParse(_selectedDate!) ??
                            DateTime.tryParse(
                              '${_selectedDate!}T00:00:00.000Z',
                            );
                        if (date == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid date.')),
                          );
                          return;
                        }
                        context.read<CartBloc>().add(
                              AddCartItemEvent(
                                serviceId: service.id,
                                serviceName: service.name,
                                price: service.price,
                                quantity: _quantity,
                                selectedDate: date,
                                selectedSlot: _selectedTime,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                        context.push('/cart');
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to cart'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
