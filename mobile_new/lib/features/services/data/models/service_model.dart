import 'package:equatable/equatable.dart';
import 'package:mobile_new/core/utils/json_parse.dart';
import 'package:mobile_new/features/services/domain/entities/service.dart'
    as Service;

/// ServiceModel - data layer representation
class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int duration;
  final List<String> tags;
  final double? rating;
  final int? reviewCount;
  final String? imageUrl;
  final DateTime createdAt;
  final int capacityPerSlot;
  final List<Service.ServiceSlot> availableSlots;

  const ServiceModel({
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

  /// Convert JSON to model (matches backend [Service] schema).
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((e) => e.toString()).toList()
        : <String>[];
    final createdRaw = json['createdAt'];
    DateTime createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.parse(createdRaw);
    } else if (createdRaw is Map<String, dynamic>) {
      createdAt =
          DateTime.tryParse(createdRaw[r'$date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    final slotsRaw = json['availableSlots'];
    final slots = <Service.ServiceSlot>[];
    if (slotsRaw is List) {
      for (final e in slotsRaw) {
        if (e is! Map<String, dynamic>) {
          continue;
        }
        slots.add(
          Service.ServiceSlot(
            date: e['date'] as String? ?? '',
            time: e['time'] as String? ?? '',
            capacity: asInt(e['capacity'], 1),
            bookedCount: asInt(e['bookedCount'], 0),
            startTime: e['startTime'] as String?,
            endTime: e['endTime'] as String?,
          ),
        );
      }
    }

    return ServiceModel(
      id: idToString(json['_id']),
      name: (json['name'] ?? json['title']) as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      price: asDouble(json['price']) ?? 0,
      duration: asInt(json['duration'], 30),
      tags: tags,
      rating: asDouble(json['rating']),
      reviewCount: asInt(json['reviewCount'], 0),
      imageUrl: (json['imageUrl'] ?? json['image']) as String?,
      createdAt: createdAt,
      capacityPerSlot: asInt(json['capacityPerSlot'], 1),
      availableSlots: slots,
    );
  }

  /// Convert model to entity
  Service.Service toEntity() => Service.Service(
    id: id,
    name: name,
    description: description,
    category: category,
    price: price,
    duration: duration,
    tags: tags,
    rating: rating,
    reviewCount: reviewCount,
    imageUrl: imageUrl,
    createdAt: createdAt,
    capacityPerSlot: capacityPerSlot,
    availableSlots: availableSlots,
  );

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

/// ServiceListResponseModel
class ServiceListResponseModel extends Equatable {
  final List<ServiceModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ServiceListResponseModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  /// Convert JSON to model (backend uses [pagination]; legacy [meta] supported).
  factory ServiceListResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    final meta = (json['pagination'] ?? json['meta']) as Map<String, dynamic>?;
    final m = meta ?? <String, dynamic>{};
    return ServiceListResponseModel(
      data: List<ServiceModel>.from(
        list.map((x) => ServiceModel.fromJson(x as Map<String, dynamic>)),
      ),
      total: asInt(m['total'], 0),
      page: asInt(m['page'], 1),
      limit: asInt(m['limit'], 10),
      totalPages: asInt(m['totalPages'], 1),
    );
  }

  /// Convert model to entity
  Service.ServiceListResponse toEntity() => Service.ServiceListResponse(
    services: data.map<Service.Service>((m) => m.toEntity()).toList(),
    total: total,
    page: page,
    limit: limit,
    totalPages: totalPages,
  );

  @override
  List<Object?> get props => [data, total, page, limit, totalPages];
}
