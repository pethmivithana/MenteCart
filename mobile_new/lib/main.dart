import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/services/presentation/bloc/services_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/bookings/presentation/bloc/bookings_bloc.dart';

final sl = GetIt.instance;

/// API base URL injected via --dart-define at build time.
/// For Android emulator: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
/// For physical device: flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:5000/api
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:5000/api',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  final authBloc = sl<AuthBloc>();
  AppRouter.initialize(authBloc);
  authBloc.add(const CheckAuthStatusEvent());
  AppRouter.setupAuthListener(authBloc);

  runApp(const MenteCartApp());
}

class MenteCartApp extends StatelessWidget {
  const MenteCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<ServicesBloc>()),
        BlocProvider.value(value: sl<CartBloc>()),
        BlocProvider.value(value: sl<BookingsBloc>()),
      ],
      child: MaterialApp.router(
        title: 'MenteCart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
