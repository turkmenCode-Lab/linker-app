import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linker/core/config/app_config.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthService(this._dio, this._storage);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConfig.authLogin,
        data: {'email': email, 'password': password},
      );
      final token = response.data['access_token'] as String;
      await _saveToken(token);
      return token;
    } on DioException catch (e) {
      throw AuthException(_parseDioError(e));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    int? age,
  }) async {
    try {
      await _dio.post(
        AppConfig.authRegister,
        data: {
          'email': email,
          'password': password,
          if (age != null) 'age': age,
        },
      );
    } on DioException catch (e) {
      throw AuthException(_parseDioError(e));
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConfig.tokenKey);
  }

  Future<String?> getToken() async {
    return _storage.read(key: AppConfig.tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: AppConfig.tokenKey, value: token);
  }

  String _parseDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Server error ${e.response?.statusCode}';
    }
    return 'Network error — check your connection fam';
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return AuthService(dio, storage);
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: AppConfig.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
