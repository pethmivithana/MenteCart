import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

/// BookingItemModel
class BookingItemModel extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  const BookingItemModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });

  factory BookingItemModel.fromJson(Map<String, dynamic> json) {
    return BookingItemModel(
      id: json['_id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'] as String)
          : null,
      selectedSlot: json['selectedSlot'] as String?,
    );
  }

  BookingItem toEntity() => BookingItem(
        id: id,
        serviceId: serviceId,
        serviceName: serviceName,
        price: price,
        quantity: quantity,
        selectedDate: selectedDate,
        selectedSlot: selectedSlot,
      );

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

/// BookingModel
class BookingModel extends Equatable {
  final String id;
  final String userId;
  final List<BookingItemModel> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      items: List<BookingItemModel>.from(
        (json['items'] as List).map((x) => BookingItemModel.fromJson(x)),
      ),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Booking toEntity() => Booking(
        id: id,
        userId: userId,
        items: items.map((m) => m.toEntity()).toList(),
        totalAmount: totalAmount,
        status: _parseStatus(status),
        createdAt: createdAt,
        completedAt: completedAt,
      );

  static BookingStatus _parseStatus(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => BookingStatus.pending,
    );
  }

  @override
  List<Object?> get props => [id, userId, items, totalAmount, status, createdAt, completedAt];
}

/// BookingListResponseModel
class BookingListResponseModel extends Equatable {
  final List<BookingModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const BookingListResponseModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory BookingListResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingListResponseModel(
      data: List<BookingModel>.from(
        (json['data'] as List).map((x) => BookingModel.fromJson(x)),
      ),
      total: json['meta']['total'] as int,
      page: json['meta']['page'] as int,
      limit: json['meta']['limit'] as int,
      totalPages: json['meta']['totalPages'] as int,
    );
  }

  BookingListResponse toEntity() => BookingListResponse(
        bookings: data.map((m) => m.toEntity()).toList(),
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages,
      );

  @override
  List<Object?> get props => [data, total, page, limit, totalPages];
}
