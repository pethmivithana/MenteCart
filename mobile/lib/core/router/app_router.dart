import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/services/presentation/screens/home_screen.dart';
import '../../features/services/presentation/screens/service_detail_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/bookings/presentation/screens/booking_history_screen.dart';
import '../../features/bookings/presentation/screens/booking_detail_screen.dart';
import '../../features/services/presentation/bloc/services_bloc.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/bookings/presentation/bloc/bookings_bloc.dart';

/// Centralized GoRouter configuration with auth-guard redirects.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ServicesBloc>()),
            BlocProvider(create: (_) => sl<CartBloc>()),
          ],
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/services/:id',
        name: 'service-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<ServicesBloc>()),
              BlocProvider(create: (_) => sl<CartBloc>()),
            ],
            child: ServiceDetailScreen(serviceId: id),
          );
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CartBloc>(),
          child: const CartScreen(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<CartBloc>()),
            BlocProvider(create: (_) => sl<BookingsBloc>()),
          ],
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: '/bookings',
        name: 'booking-history',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<BookingsBloc>(),
          child: const BookingHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/bookings/:id',
        name: 'booking-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<BookingsBloc>(),
            child: BookingDetailScreen(bookingId: id),
          );
        },
      ),
    ],
  );
}
