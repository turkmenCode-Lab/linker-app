import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).load();
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(historyProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final s = ref.watch(stringsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(child: SizedBox()),
                    Text(
                      s.history,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: state.items.isNotEmpty
                            ? CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _confirmClearAll(context),
                                child: Icon(
                                  CupertinoIcons.trash,
                                  color: AppColors.errorRed,
                                  size: 20,
                                ),
                              )
                            : const SizedBox(width: 44),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(
            current: state.filterAction,
            onFilter: (a) => ref.read(historyProvider.notifier).setFilter(a),
            onSurface: onSurface,
            divColor: divColor,
            isDark: isDark,
          ),
          Expanded(
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: onSurface,
                      strokeWidth: 2,
                    ),
                  )
                : state.items.isEmpty
                ? _EmptyState(onSurface: onSurface)
                : RefreshIndicator(
                    color: onSurface,
                    onRefresh: () => ref
                        .read(historyProvider.notifier)
                        .load(action: state.filterAction),
                    child: ListView.separated(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        100,
                      ),
                      itemCount:
                          state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        if (i == state.items.length) {
                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: onSurface,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                        final item = state.items[i];
                        return _HistoryCard(
                          item: item,
                          isDark: isDark,
                          onDelete: () => ref
                              .read(historyProvider.notifier)
                              .deleteOne(item.id),
                          onUse: () => _onUse(context, item),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _onUse(BuildContext context, HistoryItem item) {
    String text = '';
    switch (item.action) {
      case kActionLinkToConfig:
        text = item.input['link'] as String? ?? '';
        break;
      case kActionConfigToLink:
        text = item.output['link'] as String? ?? '';
        break;
      case kActionBulkImport:
        final configs = item.output['imported'] as List? ?? [];
        text = configs
            .map((c) {
              final config = c as Map?;
              return config?['link'] as String? ??
                  config?['remarks'] as String? ??
                  '';
            })
            .where((s) => s.isNotEmpty)
            .join('\n');
        break;
      case kActionSubscription:
        text = item.input['url'] as String? ?? '';
        break;
    }
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard ✓'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmClearAll(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all history? This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).deleteAll();
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String? current;
  final void Function(String?) onFilter;
  final Color onSurface;
  final Color divColor;
  final bool isDark;

  const _FilterBar({
    required this.current,
    required this.onFilter,
    required this.onSurface,
    required this.divColor,
    required this.isDark,
  });

  static const _filters = [
    (null, 'All'),
    (kActionLinkToConfig, 'L→C'),
    (kActionConfigToLink, 'C→L'),
    (kActionBulkImport, 'Bulk'),
    (kActionSubscription, 'Sub'),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : AppColors.grey100;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divColor, width: 0.5)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        children: _filters.map((f) {
          final (action, label) = f;
          final isActive = current == action;
          return GestureDetector(
            onTap: () => onFilter(action),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? onSurface : bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? (isDark ? AppColors.darkBg : AppColors.white)
                        : onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color onSurface;
  const _EmptyState({required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.clock,
            size: 48,
            color: onSurface.withOpacity(0.15),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No history yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback onUse;

  const _HistoryCard({
    required this.item,
    required this.isDark,
    required this.onDelete,
    required this.onUse,
  });

  static const _actionColors = {
    kActionLinkToConfig: Color(0xFF6366F1),
    kActionConfigToLink: Color(0xFF0EA5E9),
    kActionBulkImport: Color(0xFF10B981),
    kActionSubscription: Color(0xFFF59E0B),
  };

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withOpacity(0.4);
    final divColor = Theme.of(context).dividerColor;
    final actionColor = _actionColors[item.action] ?? onSurface;

    final now = DateTime.now();
    final diff = now.difference(item.createdAt);
    final timeLabel = diff.inMinutes < 1
        ? 'just now'
        : diff.inHours < 1
        ? '${diff.inMinutes}m ago'
        : diff.inDays < 1
        ? '${diff.inHours}h ago'
        : diff.inDays < 7
        ? '${diff.inDays}d ago'
        : item.createdAt.toString().substring(0, 10);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          CupertinoIcons.trash,
          color: AppColors.errorRed,
          size: 20,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: divColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.actionLabel,
                    style: AppTextStyles.mono.copyWith(
                      fontSize: 10,
                      color: actionColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (!item.success)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'failed',
                      style: AppTextStyles.mono.copyWith(
                        fontSize: 10,
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  timeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: onSurface.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (item.preview.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.preview,
                style: AppTextStyles.mono.copyWith(
                  fontSize: 11,
                  color: onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 28,
                  onPressed: onUse,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 13,
                        color: onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
