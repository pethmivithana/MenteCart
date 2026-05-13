# MenteCart Flutter Mobile App

Production-ready Flutter mobile application for MenteCart mental health services booking platform.

## Architecture

This project follows **Clean Architecture** with separation of concerns:

- **Domain Layer**: Business logic (entities, repositories, use cases)
- **Data Layer**: API integration and data mapping (models, data sources, repository implementations)
- **Presentation Layer**: UI components (screens, widgets, BLoCs)

## Project Structure

```
lib/
├── core/              # Shared infrastructure
│   ├── api/           # HTTP client with JWT auth
│   ├── di/            # Dependency injection setup
│   ├── error/         # Exception handling & failures
│   ├── router/        # Navigation configuration
│   ├── theme/         # Design system
│   ├── validators/    # Input validation
│   └── usecases/      # Base use case class
├── features/          # Feature modules
│   ├── auth/          # Authentication (login, signup, logout)
│   ├── services/      # Service browsing & filtering
│   ├── cart/          # Shopping cart management
│   └── bookings/      # Booking management & history
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites

- Flutter 3.0+
- Dart 3.0+
- Backend API running (see backend README)

### Installation

1. Navigate to the mobile directory:
```bash
cd mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# Default (localhost)
flutter run

# With custom API URL
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:5000/api

# For Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
```

## Features Implemented

### ✅ Authentication
- Login with email/password
- Sign up with validation
- JWT token persistence in secure storage
- Auto-login on app restart
- Automatic logout on 401 responses
- Auth-guard navigation

### ✅ State Management
- flutter_bloc for state management
- Clear event/state separation
- Global BLoC providers
- Error handling at bloc level

### ✅ API Integration
- Dio HTTP client
- Automatic JWT token injection
- Centralized error handling
- Pagination support
- Request/response logging

### ✅ Navigation
- GoRouter with auth guards
- Splash screen on startup
- Deep linking ready
- Named routes

### ✅ Data Persistence
- flutter_secure_storage for JWT tokens
- Automatic token refresh on app startup
- Clean logout clearing stored data

## Key Dependencies

```yaml
flutter_bloc: ^8.1.0          # State management
bloc: ^8.1.0                  # Core bloc library
dio: ^5.0.0                   # HTTP client
flutter_secure_storage: ^9.0.0 # Secure storage
go_router: ^11.0.0            # Navigation
dartz: ^0.10.0                # Functional programming
get_it: ^7.5.0                # Dependency injection
equatable: ^2.0.0             # Value equality
```

## Environment Variables

Set the API base URL using `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://your.api.com/api
```

Default: `http://localhost:5000/api`

## Building for Release

### Android
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your.api.com/api
```

### iOS
```bash
flutter build ios --release --dart-define=API_BASE_URL=https://your.api.com/api
```

## Testing

Run tests with:
```bash
flutter test
```

## Code Style

Uses Flutter/Dart conventions:
- CamelCase for classes
- camelCase for variables and methods
- Single quotes for strings
- 2-space indentation

## Troubleshooting

### Build issues
```bash
# Clean everything
flutter clean
flutter pub get
flutter pub upgrade
```

### API Connection Issues
- Verify backend is running on correct port
- Check --dart-define API_BASE_URL is correct
- For Android emulator use `10.0.2.2` instead of `localhost`

### State Management Issues
- Ensure all BLoCs are registered in DI
- Check that MultiBlocProvider is used correctly
- Verify event handlers are wired in BLoC constructor

## Next Steps

Complete the UI screens:

1. **HomeScreen**: Service grid with filtering and search
2. **ServiceDetailScreen**: Full service information with add to cart
3. **CartScreen**: Manage cart items with quantity controls
4. **CheckoutScreen**: Order confirmation and payment
5. **BookingHistoryScreen**: List of past bookings
6. **BookingDetailScreen**: Full booking details with cancel option

See `FLUTTER_IMPLEMENTATION.md` for detailed architecture documentation.

## License

flutter run --dart-define=API_BASE_URL=http://192.168.56.1:5000/api