import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// UserModel - data layer representation with JSON serialization
class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    required this.createdAt,
  });

  /// Convert JSON to model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert model to entity (domain layer)
  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        phone: phone,
        address: address,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, email, name, phone, address, createdAt];
}
