import 'package:equatable/equatable.dart';
import 'package:mobile_new/core/utils/json_parse.dart';
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
    final sid = json['serviceId'];
    final serviceIdStr = sid is Map<String, dynamic>
        ? idToString(sid['_id'] ?? sid[r'$oid'])
        : idToString(sid);
    final qty = asInt(json['quantity'], 1);
    final pricePerUnit = asDouble(json['pricePerUnit']) ?? 0;
    final subtotal = asDouble(json['subtotal']) ?? pricePerUnit * qty;

    return BookingItemModel(
      id: idToString(json['_id']),
      serviceId: serviceIdStr,
      serviceName: (json['serviceName'] ?? json['serviceTitle']) as String? ??
          'Service',
      price: subtotal,
      quantity: qty,
      selectedDate: _parseSlotDate(json['selectedDate'] ?? json['slotDate']),
      selectedSlot:
          (json['selectedSlot'] ?? json['slotTime']) as String?,
    );
  }

  static DateTime? _parseSlotDate(dynamic v) {
    if (v == null) {
      return null;
    }
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v) ?? DateTime.tryParse('${v}T00:00:00.000Z');
    }
    return null;
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
    final completedRaw = json['completedAt'] ?? json['cancelledAt'];
    return BookingModel(
      id: idToString(json['_id']),
      userId: idToString(json['userId']),
      items: List<BookingItemModel>.from(
        ((json['items'] as List<dynamic>?) ?? const [])
            .map((x) => BookingItemModel.fromJson(x as Map<String, dynamic>)),
      ),
      totalAmount: asDouble(json['totalAmount']) ?? 0,
      status: json['status'] as String? ?? 'pending',
      createdAt: _parseDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      completedAt: completedRaw != null
          ? DateTime.tryParse(completedRaw.toString())
          : null,
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) {
      return null;
    }
    if (v is String) {
      return DateTime.tryParse(v);
    }
    if (v is Map<String, dynamic>) {
      final d = v[r'$date'];
      if (d != null) {
        return DateTime.tryParse(d.toString());
      }
    }
    return DateTime.tryParse(v.toString());
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
    final list = json['data'] as List<dynamic>? ?? [];
    final meta = (json['pagination'] ?? json['meta']) as Map<String, dynamic>?;
    final m = meta ?? <String, dynamic>{};
    return BookingListResponseModel(
      data: List<BookingModel>.from(
        list.map((x) => BookingModel.fromJson(x as Map<String, dynamic>)),
      ),
      total: asInt(m['total'], 0),
      page: asInt(m['page'], 1),
      limit: asInt(m['limit'], 10),
      totalPages: asInt(m['totalPages'], 1),
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
