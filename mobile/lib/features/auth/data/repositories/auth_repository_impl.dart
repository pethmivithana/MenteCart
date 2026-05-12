import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of AuthRepository
/// Handles API calls and token persistence
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      // Store token securely
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: response.token,
      );
      return Right(response.token);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, String>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await remoteDataSource.signup(
        email: email,
        password: password,
        name: name,
      );
      // Store token securely
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: response.token,
      );
      return Right(response.token);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final userModel = await remoteDataSource.getMe();
      return Right(userModel.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
  }
}
