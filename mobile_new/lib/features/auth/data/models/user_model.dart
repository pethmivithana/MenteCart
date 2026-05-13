import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// UserModel - matches actual backend User schema:
/// { _id, name, email, role, isActive, createdAt, updatedAt }
class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id']) as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: (json['role'] ?? 'user') as String,
      isActive: (json['isActive'] ?? true) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, email, name, role, isActive, createdAt];
}