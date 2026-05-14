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

  /// Get current user info. Pass [accessToken] right after login/signup when
  /// secure storage may not yet be visible to the next request.
  Future<Either<Failure, User>> getMe({String? accessToken});

  /// Clear stored token
  Future<void> logout();
}
