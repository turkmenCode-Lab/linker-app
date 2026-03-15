import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../editor/providers/editor_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final editorCtrl = ref.read(editorControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.white;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.grey100;
    final textColor = isDark ? AppColors.darkText : AppColors.black;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.grey600;
    final divColor = isDark ? AppColors.darkDivider : AppColors.grey200;

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: bg.withOpacity(0.92),
            border: Border(bottom: BorderSide(color: divColor, width: 0.5)),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    const SizedBox(width: 44),
                    const Spacer(),
                    Text(
                      s.settings,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.md,
          top: AppSpacing.lg,
          bottom: 100,
        ),
        children: [
          _SectionLabel(label: s.appearance, color: subColor),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            bg: cardBg,
            divColor: divColor,
            children: [
              _ThemeRow(
                label: s.theme,
                textColor: textColor,
                current: settings.themeMode,
                strings: s,
                onChanged: (m) => notifier.setThemeMode(m),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: s.general, color: subColor),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            bg: cardBg,
            divColor: divColor,
            children: [
              _LanguageRow(
                label: s.language,
                textColor: textColor,
                subColor: subColor,
                current: settings.locale,
                onChanged: (l) => notifier.setLocale(l),
              ),
              _ToggleRow(
                label: s.autoCopy,
                subLabel: s.autoCopySubtitle,
                textColor: textColor,
                subColor: subColor,
                value: settings.autoCopy,
                onChanged: (v) => notifier.setAutoCopy(v),
              ),
              _ToggleRow(
                label: s.formatOnExport,
                subLabel: s.formatOnExportSubtitle,
                textColor: textColor,
                subColor: subColor,
                value: settings.formatOnExport,
                onChanged: (v) => notifier.setFormatOnExport(v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: s.editor, color: subColor),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            bg: cardBg,
            divColor: divColor,
            children: [
              _ActionRow(
                label: s.formatJson,
                icon: CupertinoIcons.textformat,
                textColor: textColor,
                onTap: () {
                  editorCtrl.formatJson();
                  context.pop();
                },
              ),
              _ActionRow(
                label: s.minifyJson,
                icon: CupertinoIcons.minus,
                textColor: textColor,
                onTap: () {
                  editorCtrl.minifyJson();
                  context.pop();
                },
              ),
              _ActionRow(
                label: s.clearEditor,
                icon: CupertinoIcons.trash,
                textColor: AppColors.errorRed,
                onTap: () => _confirmClear(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _Card(
            bg: cardBg,
            divColor: divColor,
            children: [
              _ActionRow(
                label: s.signOut,
                icon: CupertinoIcons.square_arrow_left,
                textColor: AppColors.errorRed,
                onTap: () => _confirmSignOut(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Clear Editor'),
        content: const Text('This will erase everything in the editor.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref.read(editorControllerProvider.notifier).clearEditor();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Color bg;
  final Color divColor;
  final List<Widget> children;
  const _Card({
    required this.bg,
    required this.divColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: divColor,
                indent: AppSpacing.md,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor;
  final VoidCallback onTap;
  const _ActionRow({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: textColor.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final String label;
  final Color textColor;
  final ThemeMode current;
  final AppStrings strings;
  final void Function(ThemeMode) onChanged;
  const _ThemeRow({
    required this.label,
    required this.textColor,
    required this.current,
    required this.strings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = {
      ThemeMode.system: strings.themeSystem,
      ThemeMode.light: strings.themeLight,
      ThemeMode.dark: strings.themeDark,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: options.entries.map((e) {
              final isSelected = current == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.darkText : AppColors.black)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.grey200),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          e.key == ThemeMode.system
                              ? CupertinoIcons.circle_lefthalf_fill
                              : e.key == ThemeMode.light
                              ? CupertinoIcons.sun_max
                              : CupertinoIcons.moon,
                          size: 13,
                          color: isSelected
                              ? (isDark ? AppColors.darkBg : AppColors.white)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.grey600),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          e.value,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? (isDark ? AppColors.darkBg : AppColors.white)
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.grey600),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color subColor;
  final AppLocale current;
  final void Function(AppLocale) onChanged;
  const _LanguageRow({
    required this.label,
    required this.textColor,
    required this.subColor,
    required this.current,
    required this.onChanged,
  });

  static const _labels = {
    AppLocale.en: ('🇬🇧', 'English'),
    AppLocale.ru: ('🇷🇺', 'Русский'),
    AppLocale.tk: ('🇹🇲', 'Türkmençe'),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (flag, name) = _labels[current]!;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showPicker(context, isDark),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$flag  $name',
              style: AppTextStyles.bodyMedium.copyWith(color: subColor),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: subColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, bool isDark) {
    final bg = isDark ? AppColors.darkSurface : AppColors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.black;
    final divColor = isDark ? AppColors.darkDivider : AppColors.grey200;

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Language',
                style: AppTextStyles.titleMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.md),
              ...AppLocale.values.map((l) {
                final (flag, name) = _labels[l]!;
                final isSelected = l == current;
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        onChanged(l);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? textColor.withOpacity(0.06)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: textColor,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                CupertinoIcons.checkmark,
                                size: 16,
                                color: textColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (l != AppLocale.values.last)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: divColor,
                        indent: 56,
                      ),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subLabel;
  final Color textColor;
  final Color subColor;
  final bool value;
  final void Function(bool) onChanged;
  const _ToggleRow({
    required this.label,
    required this.subLabel,
    required this.textColor,
    required this.subColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  style: AppTextStyles.caption.copyWith(color: subColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: isDark ? AppColors.darkText : AppColors.black,
            thumbColor: isDark ? AppColors.darkBg : AppColors.white,
          ),
        ],
      ),
    );
  }
}
