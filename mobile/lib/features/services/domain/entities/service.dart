import 'package:equatable/equatable.dart';

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
