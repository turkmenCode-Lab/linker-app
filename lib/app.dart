import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linker/core/router/app_router.dart';
import 'package:linker/core/theme/app_theme.dart';

Widget buildApp() {
  return const ProviderScope(child: _AppRoot());
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Linker',
      debugShowCheckedModeBanner: false,
      theme: materialTheme,
      routerConfig: router,
      builder: (context, child) {
        return CupertinoTheme(
          data: cupertinoTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
