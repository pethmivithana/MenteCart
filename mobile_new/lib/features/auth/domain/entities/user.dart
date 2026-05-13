import 'package:equatable/equatable.dart';

/// User entity in the domain layer - business logic representation
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, phone, address, createdAt];
}
