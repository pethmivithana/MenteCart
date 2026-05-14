import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../main.dart' show apiBaseUrl;
import '../constants/app_constants.dart';

/// Singleton Dio HTTP client with JWT auth interceptor.
/// Reads the token from secure storage and attaches it to every request.
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient._(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    ]);
  }

  factory ApiClient(FlutterSecureStorage storage) {
    _instance ??= ApiClient._(storage);
    return _instance!;
  }

  Dio get dio => _dio;
}

/// Injects Authorization header from secure storage before each request.
/// On 401 responses, clears the stored token (session expired).
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final existing = options.headers['Authorization'];
    final hasAuth = existing != null &&
        existing.toString().trim().isNotEmpty;
    if (!hasAuth) {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear stale token — UI layer will redirect to login via BLoC
      _storage.delete(key: AppConstants.accessTokenKey);
    }
    handler.next(err);
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print('[MenteCart] $message');
}
