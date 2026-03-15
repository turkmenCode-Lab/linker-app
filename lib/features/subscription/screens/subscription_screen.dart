import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/subscription_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final url = ref.read(subscriptionProvider).url;
    if (url.isNotEmpty) _urlCtrl.text = url;
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);
    final s = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final divColor = isDark ? AppColors.darkDivider : AppColors.grey200;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: scaffoldBg.withOpacity(0.92),
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
                      s.subscription,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (state.entries.isNotEmpty)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _copyAll(context, state),
                        child: Icon(
                          CupertinoIcons.doc_on_clipboard,
                          color: onSurface,
                          size: 22,
                        ),
                      )
                    else
                      const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _UrlBar(
            controller: _urlCtrl,
            state: state,
            onChanged: (v) => ref.read(subscriptionProvider.notifier).setUrl(v),
            onFetch: () =>
                ref.read(subscriptionProvider.notifier).fetchAndConvert(),
            onClear: () {
              _urlCtrl.clear();
              ref.read(subscriptionProvider.notifier).clear();
            },
          ),
          if (state.status == SubStatus.converting)
            _ProgressBar(
              progress: state.progress,
              converted: state.converted,
              total: state.total,
            ),
          if (state.error != null)
            _ErrorBanner(
              error: state.error!,
              onDismiss: () =>
                  ref.read(subscriptionProvider.notifier).clearError(),
            ),
          Expanded(
            child: state.entries.isEmpty
                ? _EmptyState(status: state.status, s: s)
                : _EntryList(entries: state.entries, isDark: isDark),
          ),
        ],
      ),
    );
  }

  void _copyAll(BuildContext context, SubscriptionState state) {
    final all = state.entries.map((e) => e.link).join('\n');
    Clipboard.setData(ClipboardData(text: all));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${state.entries.length} links ✓'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _UrlBar extends StatelessWidget {
  final TextEditingController controller;
  final SubscriptionState state;
  final void Function(String) onChanged;
  final VoidCallback onFetch;
  final VoidCallback onClear;

  const _UrlBar({
    required this.controller,
    required this.state,
    required this.onChanged,
    required this.onFetch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: surfaceHigh.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    CupertinoIcons.link,
                    size: 16,
                    color: onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'https://your-sub-url...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          color: onSurface.withOpacity(0.35),
                        ),
                        fillColor: Colors.transparent,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 36,
                      onPressed: onClear,
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 16,
                        color: onSurface.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: state.isBusy ? null : onFetch,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: state.isBusy ? onSurface.withOpacity(0.1) : onSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: state.status == SubStatus.fetching
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        CupertinoIcons.arrow_down_circle,
                        size: 20,
                        color: state.isBusy
                            ? onSurface.withOpacity(0.3)
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final int converted;
  final int total;

  const _ProgressBar({
    required this.progress,
    required this.converted,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Converting...',
                style: AppTextStyles.caption.copyWith(
                  color: onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Text(
                '$converted / $total',
                style: AppTextStyles.caption.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: onSurface.withOpacity(0.1),
              color: onSurface,
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.errorRed.withOpacity(AppOpacity.subtle),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 14,
            color: AppColors.errorRed,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.caption.copyWith(color: AppColors.errorRed),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 24,
            onPressed: onDismiss,
            child: Icon(
              CupertinoIcons.xmark,
              size: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final SubStatus status;
  final dynamic s;

  const _EmptyState({required this.status, required this.s});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (status == SubStatus.fetching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: onSurface, strokeWidth: 2),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Fetching subscription...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.antenna_radiowaves_left_right,
              size: 48,
              color: onSurface.withOpacity(0.15),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              s.subscriptionHint,
              style: AppTextStyles.bodyMedium.copyWith(
                color: onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  final List<SubEntry> entries;
  final bool isDark;

  const _EntryList({required this.entries, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withOpacity(0.4);
    final divColor = Theme.of(context).dividerColor;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        100,
      ),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final entry = entries[i];
        return _EntryCard(
          entry: entry,
          cardBg: cardBg,
          onSurface: onSurface,
          divColor: divColor,
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  final SubEntry entry;
  final Color cardBg;
  final Color onSurface;
  final Color divColor;

  const _EntryCard({
    required this.entry,
    required this.cardBg,
    required this.onSurface,
    required this.divColor,
  });

  static const _protocolColors = {
    'vless': Color(0xFF6366F1),
    'vmess': Color(0xFF0EA5E9),
    'trojan': Color(0xFF10B981),
    'ss': Color(0xFFF59E0B),
    'shadowsocks': Color(0xFFF59E0B),
    'hysteria2': Color(0xFFEC4899),
  };

  @override
  Widget build(BuildContext context) {
    final protoColor = _protocolColors[entry.protocol] ?? onSurface;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: protoColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.protocol,
              style: AppTextStyles.mono.copyWith(
                fontSize: 10,
                color: protoColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  entry.link,
                  style: AppTextStyles.mono.copyWith(
                    fontSize: 10,
                    color: onSurface.withOpacity(0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: entry.link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied ✓'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Icon(
              CupertinoIcons.doc_on_clipboard,
              size: 16,
              color: onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
