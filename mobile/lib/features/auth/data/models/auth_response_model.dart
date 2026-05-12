import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// AuthResponseModel - backend response containing token and user
class AuthResponseModel extends Equatable {
  final String token;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    required this.user,
  });

  /// Convert JSON to model
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [token, user];
}
