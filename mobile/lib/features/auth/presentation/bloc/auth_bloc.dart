import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_event.dart';
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
    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          errorCode: failure.errorCode,
        ),
      ),
      (token) async {
        // After successful login, get user info
        final userResult = await getMeUseCase(const NoParams());
        userResult.fold(
          (failure) => emit(
            AuthFailure(
              message: failure.message,
              errorCode: failure.errorCode,
            ),
          ),
          (user) => emit(AuthSuccess(user: user, token: token)),
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
    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          errorCode: failure.errorCode,
        ),
      ),
      (token) async {
        // After successful signup, get user info
        final userResult = await getMeUseCase(const NoParams());
        userResult.fold(
          (failure) => emit(
            AuthFailure(
              message: failure.message,
              errorCode: failure.errorCode,
            ),
          ),
          (user) => emit(AuthSuccess(user: user, token: token)),
        );
      },
    );
  }

  /// Handle get me
  Future<void> _onGetMeEvent(GetMeEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await getMeUseCase(const NoParams());
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
    final result = await getMeUseCase(const NoParams());
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
    await logoutUseCase(const NoParams());
    emit(const AuthLoggedOut());
  }
}
