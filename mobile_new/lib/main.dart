import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/services/presentation/bloc/services_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/bookings/presentation/bloc/bookings_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/services/presentation/screens/home_screen.dart';

final sl = GetIt.instance;

/// API base URL injected via --dart-define at build time.
/// For Android emulator: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
/// For physical device: flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:5000/api
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:5000/api', // default for Android emulator
);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      child: MaterialApp(
        title: 'MenteCart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // IMPORTANT ROUTES FIX
        initialRoute: '/',
        routes: {
          '/': (context) => const _RootNavigator(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

/// Root navigator that listens to AuthBloc and navigates accordingly.
class _RootNavigator extends StatefulWidget {
  const _RootNavigator();

  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  @override
  void initState() {
    super.initState();

    // Check auth on startup
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (_) => false,
          );
        } else if (state is AuthLoggedOut ||
            state is AuthUnauthorized ||
            state is AuthFailure) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (_) => false,
          );
        }
      },
      builder: (context, state) {
        // Show splash while auth state is loading
        return const _SplashPage();
      },
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF4F46E5),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MenteCart',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Mental Health Services',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 80),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}