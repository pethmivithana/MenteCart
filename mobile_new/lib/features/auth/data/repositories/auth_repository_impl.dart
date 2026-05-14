import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: response.token,
      );
      return Right(response.token);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
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
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: response.token,
      );
      return Right(response.token);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getMe({String? accessToken}) async {
    try {
      final token = accessToken ??
          await secureStorage.read(key: AppConstants.accessTokenKey);
      if (token == null || token.isEmpty) {
        return const Left(UnauthorizedFailure());
      }
      final userModel = await remoteDataSource.getMe(accessToken: token);
      return Right(userModel.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
  }
}