import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/services/presentation/screens/home_screen.dart';
import '../../features/services/presentation/screens/service_detail_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/bookings/presentation/screens/booking_history_screen.dart';
import '../../features/bookings/presentation/screens/booking_detail_screen.dart';
import '../../features/payment/presentation/screens/payment_processing_screen.dart';
import '../../features/payment/presentation/screens/payment_success_screen.dart';
import '../../features/payment/presentation/screens/payment_failed_screen.dart';
import '../../features/payment/presentation/screens/payhere_gateway_screen.dart';
import '../../features/bookings/domain/entities/booking.dart';

/// Notifies [GoRouter] when [AuthBloc] emits so redirects re-run.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Centralized GoRouter configuration with proper auth handling.
/// Redirect only reads state; navigation side-effects live in [setupAuthListener].
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static StreamSubscription<AuthState>? _authStateSubscription;
  static GoRouterRefreshStream? _authRefreshListenable;

  static late final GoRouter router;

  /// Call once after [AuthBloc] is available (e.g. from [main]).
  static void initialize(AuthBloc authBloc) {
    _authRefreshListenable?.dispose();
    _authRefreshListenable = GoRouterRefreshStream(authBloc.stream);
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      refreshListenable: _authRefreshListenable,
      initialLocation: '/splash',
      debugLogDiagnostics: false,
      redirect: (context, state) {
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;
        final loc = state.matchedLocation;
        final isOnSplash = loc == '/splash';
        final isOnAuth = loc == '/login' || loc == '/signup';

        if (isOnSplash) {
          if (authState is AuthLoading || authState is AuthInitial) {
            return null;
          }
          if (authState is AuthSuccess) {
            return '/home';
          }
          return '/login';
        }

        if (authState is AuthLoading) {
          return null;
        }

        if (authState is AuthSuccess && isOnAuth) {
          return '/home';
        }

        if (authState is! AuthSuccess && !isOnAuth && !isOnSplash) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/services/:id',
          name: 'service-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ServiceDetailScreen(serviceId: id);
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/payhere-gateway',
          name: 'payhere-gateway',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return PayhereGatewayScreen(
              bookingRef: extra?['bookingRef'] ?? '',
              amount: extra?['amount'] ?? 0.0,
              currency: extra?['currency'] ?? 'LKR',
              customerName: extra?['customerName'] ?? '',
              customerEmail: extra?['customerEmail'] ?? '',
              customerPhone: extra?['customerPhone'] ?? '',
            );
          },
        ),
        GoRoute(
          path: '/bookings',
          name: 'booking-history',
          builder: (context, state) => const BookingHistoryScreen(),
        ),
        GoRoute(
          path: '/bookings/:id',
          name: 'booking-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BookingDetailScreen(bookingId: id);
          },
        ),
        GoRoute(
          path: '/payment-processing',
          name: 'payment-processing',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final bookingRef = extra?['bookingRef'] ?? '';
            final bookingId = extra?['bookingId'] ?? '';
            return PaymentProcessingScreen(
              bookingRef: bookingRef,
              bookingId: bookingId,
            );
          },
        ),
        GoRoute(
          path: '/payment-success',
          name: 'payment-success',
          builder: (context, state) {
            final booking = state.extra as Booking;
            return PaymentSuccessScreen(booking: booking);
          },
        ),
        GoRoute(
          path: '/payment-failed',
          name: 'payment-failed',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return PaymentFailedScreen(
              message: extra?['message'] ?? 'Payment Failed',
              reason: extra?['reason'],
              bookingId: extra?['bookingId'],
            );
          },
        ),
      ],
    );
  }

  /// Secondary navigation for auth transitions (e.g. post-login from any route).
  static void setupAuthListener(AuthBloc authBloc) {
    _authStateSubscription?.cancel();
    _authStateSubscription = authBloc.stream.listen((state) {
      final ctx = _rootNavigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;

      final location = GoRouterState.of(ctx).uri.path;

      if (state is AuthSuccess) {
        if (location == '/login' ||
            location == '/signup' ||
            location == '/splash') {
          ctx.go('/home');
        }
      } else if (state is AuthLoggedOut || state is AuthUnauthorized) {
        ctx.go('/login');
      }
    });
  }
}
