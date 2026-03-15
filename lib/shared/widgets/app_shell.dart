import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: child,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 48, right: 48, bottom: 24),
        child: SafeArea(
          top: false,
          child: _FloatingPill(location: location, isDark: isDark),
        ),
      ),
    );
  }
}

class _FloatingPill extends StatelessWidget {
  final String location;
  final bool isDark;

  const _FloatingPill({required this.location, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pillBg = isDark ? AppColors.darkSurface : AppColors.white;
    final shadow = isDark ? AppColors.black : const Color(0xFF000000);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: shadow.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: shadow.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _PillTab(
            icon: CupertinoIcons.doc_text,
            isActive: location == '/editor',
            isDark: isDark,
            onTap: () => context.go('/editor'),
          ),
          _PillTab(
            icon: CupertinoIcons.antenna_radiowaves_left_right,
            isActive: location == '/subscription',
            isDark: isDark,
            onTap: () => context.go('/subscription'),
          ),
          _PillTab(
            icon: CupertinoIcons.time,
            isActive: location == '/history',
            isDark: isDark,
            onTap: () => context.go('/history'),
          ),
          _PillTab(
            icon: CupertinoIcons.settings,
            isActive: location == '/settings',
            isDark: isDark,
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final IconData icon;

  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _PillTab({
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.darkText : AppColors.black;
    final inactiveColor = isDark
        ? AppColors.darkText.withOpacity(0.35)
        : AppColors.black.withOpacity(0.3);
    final activeBg = isDark
        ? AppColors.darkText.withOpacity(0.1)
        : AppColors.black.withOpacity(0.06);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  key: ValueKey(isActive),
                  size: isActive ? 25 : 24,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
