import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_new/core/error/failures.dart';
import '../../domain/usecases/get_me_usecase.dart' show GetMeParams, GetMeUseCase;
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../bloc/auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final GetMeUseCase getMeUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc(
    this.loginUseCase,
    this.signupUseCase,
    this.getMeUseCase,
    this.logoutUseCase,
  ) : super(const AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<SignupEvent>(_onSignupEvent);
    on<GetMeEvent>(_onGetMeEvent);
    on<CheckAuthStatusEvent>(_onCheckAuthStatusEvent);
    on<LogoutEvent>(_onLogoutEvent);
  }

  /// Handle login
  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    await result.fold<Future<void>>(
      (failure) async {
        emit(
          AuthFailure(
            message: failure.message,
            errorCode: failure.errorCode,
          ),
        );
      },
      (token) async {
        final userResult = await getMeUseCase(
          GetMeParams(accessToken: token),
        );
        await userResult.fold<Future<void>>(
          (failure) async {
            emit(
              AuthFailure(
                message: failure.message,
                errorCode: failure.errorCode,
              ),
            );
          },
          (user) async {
            emit(AuthSuccess(user: user, token: token));
          },
        );
      },
    );
  }

  /// Handle signup
  Future<void> _onSignupEvent(
    SignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signupUseCase(
      SignupParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    await result.fold<Future<void>>(
      (failure) async {
        emit(
          AuthFailure(
            message: failure.message,
            errorCode: failure.errorCode,
          ),
        );
      },
      (_) async {
        // Account exists; require explicit login (clear signup token from storage).
        await logoutUseCase();
        emit(
          const AuthLoggedOut(
            bannerMessage:
                'Account created successfully. Please sign in with your email and password.',
          ),
        );
      },
    );
  }

  /// Handle get me
  Future<void> _onGetMeEvent(GetMeEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await getMeUseCase(const GetMeParams());
    result.fold(
      (failure) {
        // If getMe fails, user is not authenticated
        if (failure is UnauthorizedFailure) {
          emit(const AuthUnauthorized());
        } else {
          emit(AuthFailure(message: failure.message));
        }
      },
      (user) => emit(AuthSuccess(user: user, token: '')),
    );
  }

  /// Check auth status on app startup
  Future<void> _onCheckAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getMeUseCase(const GetMeParams());
    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) {
          emit(const AuthLoggedOut());
        } else {
          emit(AuthFailure(message: failure.message));
        }
      },
      (user) => emit(AuthSuccess(user: user, token: '')),
    );
  }

  /// Handle logout
  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUseCase();
    emit(const AuthLoggedOut());
  }
}
