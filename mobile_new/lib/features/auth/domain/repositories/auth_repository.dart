import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Auth repository contract - defines all auth operations
abstract class AuthRepository {
  /// Login with email and password
  /// Returns token on success
  Future<Either<Failure, String>> login(String email, String password);

  /// Sign up new user
  /// Returns token on success
  Future<Either<Failure, String>> signup({
    required String email,
    required String password,
    required String name,
  });

  /// Get current user info
  Future<Either<Failure, User>> getMe();

  /// Clear stored token
  Future<void> logout();
}
