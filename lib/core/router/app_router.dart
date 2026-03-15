import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/editor/screens/editor.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/editor',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.status == AuthStatus.loading;
      final isAuthed = authState.status == AuthStatus.authenticated;
      final isOnAuth = state.matchedLocation == '/auth';

      if (isLoading) return null;
      if (!isAuthed && !isOnAuth) return '/auth';
      if (isAuthed && isOnAuth) return '/editor';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (_, __) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/editor',
            name: 'editor',
            builder: (_, __) => const EditorScreen(),
          ),
          GoRoute(
            path: '/subscription',
            name: 'subscription',
            builder: (_, __) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('404 — ${state.error}'))),
  );
});

class _AuthListenable extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  _AuthListenable(this._ref) {
    _subscription = _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
