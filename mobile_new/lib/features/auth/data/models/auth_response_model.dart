import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// AuthResponseModel - maps the backend envelope:
/// { success, message, data: { user, accessToken } }
class AuthResponseModel extends Equatable {
  final String token;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend wraps in data: { user, accessToken }
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponseModel(
      token: data['accessToken'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [token, user];
}