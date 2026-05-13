import 'package:equatable/equatable.dart';
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
  });

  /// Convert JSON to model
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as int,
      tags: List<String>.from(json['tags'] as List),
      rating: json['rating'] as double?,
      reviewCount: json['reviewCount'] as int?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
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

  /// Convert JSON to model
  factory ServiceListResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceListResponseModel(
      data: List<ServiceModel>.from(
        (json['data'] as List).map((x) => ServiceModel.fromJson(x)),
      ),
      total: json['meta']['total'] as int,
      page: json['meta']['page'] as int,
      limit: json['meta']['limit'] as int,
      totalPages: json['meta']['totalPages'] as int,
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
