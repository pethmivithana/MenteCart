import 'package:equatable/equatable.dart';

/// Bookable slot on a service (matches backend `availableSlots`).
class ServiceSlot extends Equatable {
  final String date;
  final String time;
  final int capacity;
  final int bookedCount;
  final String? startTime; // ISO time like 09:00
  final String? endTime; // ISO time like 10:00

  const ServiceSlot({
    required this.date,
    required this.time,
    required this.capacity,
    required this.bookedCount,
    this.startTime,
    this.endTime,
  });

  int get remaining => (capacity - bookedCount).clamp(0, capacity);

  bool get isFullyBooked => remaining <= 0;

  bool get hasLimitedSlots => remaining > 0 && remaining <= 2;

  bool get isAvailable => remaining > 0;

  @override
  List<Object?> get props => [
    date,
    time,
    capacity,
    bookedCount,
    startTime,
    endTime,
  ];
}

/// Service entity - domain layer representation
class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int duration; // in minutes
  final List<String> tags;
  final double? rating;
  final int? reviewCount;
  final String? imageUrl;
  final DateTime createdAt;
  final int capacityPerSlot;
  final List<ServiceSlot> availableSlots;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.tags,
    this.rating,
    this.reviewCount,
    this.imageUrl,
    required this.createdAt,
    this.capacityPerSlot = 1,
    this.availableSlots = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    price,
    duration,
    tags,
    rating,
    reviewCount,
    imageUrl,
    createdAt,
    capacityPerSlot,
    availableSlots,
  ];
}

/// Paginated response for services list
class ServiceListResponse extends Equatable {
  final List<Service> services;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ServiceListResponse({
    required this.services,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [services, total, page, limit, totalPages];
}
