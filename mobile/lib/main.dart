import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/services/presentation/bloc/services_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/bookings/presentation/bloc/bookings_bloc.dart';

final sl = GetIt.instance;

/// Entry point. API base URL is injected via --dart-define at build time.
/// Example: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5000/api',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const MenteCartApp());
}

class MenteCartApp extends StatelessWidget {
  const MenteCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ServicesBloc>()),
        BlocProvider(create: (_) => sl<CartBloc>()),
        BlocProvider(create: (_) => sl<BookingsBloc>()),
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
