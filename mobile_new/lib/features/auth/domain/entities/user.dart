import 'package:equatable/equatable.dart';

/// User entity in the domain layer
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, createdAt];
}