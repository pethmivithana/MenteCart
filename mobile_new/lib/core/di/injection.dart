import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

// Features
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/services/data/datasources/service_remote_datasource.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/domain/usecases/get_services_usecase.dart';
import '../../features/services/domain/usecases/get_service_by_id_usecase.dart';
import '../../features/services/presentation/bloc/service_detail_bloc.dart';
import '../../features/services/presentation/bloc/services_bloc.dart';

import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/get_cart_usecase.dart';
import '../../features/cart/domain/usecases/add_cart_item_usecase.dart';
import '../../features/cart/domain/usecases/update_cart_item_usecase.dart';
import '../../features/cart/domain/usecases/remove_cart_item_usecase.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

import '../../features/bookings/data/datasources/booking_remote_datasource.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/domain/usecases/checkout_usecase.dart';
import '../../features/bookings/domain/usecases/get_bookings_usecase.dart';
import '../../features/bookings/domain/usecases/get_booking_by_id_usecase.dart';
import '../../features/bookings/domain/usecases/cancel_booking_usecase.dart';
import '../../features/bookings/presentation/bloc/bookings_bloc.dart';

final GetIt sl = GetIt.instance;

/// Manual dependency injection setup using GetIt.
/// Call this once at app startup before runApp().
Future<void> configureDependencies() async {
  // ─── Core ──────────────────────────────────────────────────────────────
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  sl.registerSingleton<FlutterSecureStorage>(storage);
  sl.registerSingleton<ApiClient>(ApiClient(storage));

  // ─── Auth ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(sl(), sl(), sl(), sl()),
  );

  // ─── Services ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetServicesUseCase(sl()));
  sl.registerLazySingleton(() => GetServiceByIdUseCase(sl()));
  sl.registerFactory(() => ServicesBloc(sl(), sl()));
  sl.registerFactory(() => ServiceDetailBloc(sl<GetServiceByIdUseCase>()));

  // ─── Cart ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddCartItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCartItemUseCase(sl()));
  sl.registerFactory(() => CartBloc(sl(), sl(), sl(), sl()));

  // ─── Bookings ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => CheckoutUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingByIdUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerFactory(() => BookingsBloc(sl(), sl(), sl(), sl()));
}
