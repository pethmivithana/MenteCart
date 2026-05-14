import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> signup({
    required String email,
    required String password,
    required String name,
  });
  Future<UserModel> getMe({String? accessToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password, 'name': name},
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getMe({String? accessToken}) async {
    final response = await dio.get(
      '/auth/me',
      options: accessToken != null && accessToken.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $accessToken'})
          : null,
    );
    // Backend returns: { success, message, data: { user } }
    final data = response.data as Map<String, dynamic>;
    final userJson = data['data']['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }
}