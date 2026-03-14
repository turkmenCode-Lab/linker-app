import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.loading,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    bool? isLoading,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuth = await _authService.isAuthenticated();
    state = state.copyWith(
      status: isAuth ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        error: e.message,
        isLoading: false,
        status: AuthStatus.unauthenticated,
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    int? age,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.register(email: email, password: password, age: age);
      return await login(email: email, password: password);
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
