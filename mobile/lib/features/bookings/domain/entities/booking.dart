import 'package:equatable/equatable.dart';

/// Booking status enum
enum BookingStatus { pending, confirmed, completed, cancelled }

/// BookingItem in a booking
class BookingItem extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  const BookingItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });

  @override
  List<Object?> get props => [
    id,
    serviceId,
    serviceName,
    price,
    quantity,
    selectedDate,
    selectedSlot,
  ];
}

/// Booking entity
class Booking extends Equatable {
  final String id;
  final String userId;
  final List<BookingItem> items;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    items,
    totalAmount,
    status,
    createdAt,
    completedAt,
  ];
}

/// Paginated booking response
class BookingListResponse extends Equatable {
  final List<Booking> bookings;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const BookingListResponse({
    required this.bookings,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [bookings, total, page, limit, totalPages];
}
