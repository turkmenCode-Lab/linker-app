import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:linker/features/settings/providers/settings_provider.dart';

Future<Widget> buildApp() async {
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const _AppRoot(),
  );
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Linker',
      debugShowCheckedModeBanner: false,
      theme: materialTheme,
      darkTheme: materialThemeDark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        return CupertinoTheme(
          data: cupertinoThemeFor(brightness),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
