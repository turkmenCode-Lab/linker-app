import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/editor_controller.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _jsonCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _bulkCtrl = TextEditingController();
  bool _syncingController = false;

  @override
  void dispose() {
    _jsonCtrl.dispose();
    _linkCtrl.dispose();
    _bulkCtrl.dispose();
    super.dispose();
  }

  void _syncFromState(String raw) {
    if (_syncingController) return;
    if (_jsonCtrl.text == raw) return;
    _syncingController = true;
    final selection = _jsonCtrl.selection;
    _jsonCtrl.text = raw;
    if (selection.start <= raw.length) {
      _jsonCtrl.selection = selection;
    }
    _syncingController = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorControllerProvider);
    final ctrl = ref.read(editorControllerProvider.notifier);

    ref.listen(editorControllerProvider, (_, next) {
      _syncFromState(next.rawJson);
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.white.withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: AppColors.grey200, width: 0.5),
        ),
        middle: Text('linker', style: AppTextStyles.titleMedium),
        leading: _StatusIndicator(
          isValid: state.isValid,
          isDirty: state.isDirty,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showSettings(context),
              child: const Icon(
                CupertinoIcons.ellipsis_circle,
                color: AppColors.black,
                size: 22,
              ),
            ),
          ],
        ),
      ),
      child: Material(
        color: AppColors.white,
        child: SafeArea(
          child: Column(
            children: [
              _TabBar(activeTab: state.activeTab, onTabChanged: ctrl.switchTab),
              if (state.apiError != null)
                _ApiErrorBanner(
                  error: state.apiError!,
                  onDismiss: () => ctrl.switchTab(state.activeTab),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: switch (state.activeTab) {
                    EditorTab.editor => _EditorPanel(
                      key: const ValueKey('editor'),
                      controller: _jsonCtrl,
                      state: state,
                      editorCtrl: ctrl,
                    ),
                    EditorTab.linkConverter => _LinkConverterPanel(
                      key: const ValueKey('converter'),
                      linkCtrl: _linkCtrl,
                      state: state,
                      editorCtrl: ctrl,
                    ),
                    EditorTab.bulkImport => _BulkImportPanel(
                      key: const ValueKey('bulk'),
                      bulkCtrl: _bulkCtrl,
                      state: state,
                      editorCtrl: ctrl,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('Options', style: AppTextStyles.titleMedium),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(editorControllerProvider.notifier).formatJson();
            },
            child: const Text('Format JSON'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(editorControllerProvider.notifier).minifyJson();
            },
            child: const Text('Minify JSON'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(editorControllerProvider.notifier).clearEditor();
            },
            isDestructiveAction: true,
            child: const Text('Clear Editor'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go('/auth');
            },
            isDestructiveAction: true,
            child: const Text('Sign Out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final EditorTab activeTab;
  final void Function(EditorTab) onTabChanged;

  const _TabBar({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            _Tab(
              label: 'Editor',
              icon: CupertinoIcons.doc_text,
              isActive: activeTab == EditorTab.editor,
              onTap: () => onTabChanged(EditorTab.editor),
            ),
            _Tab(
              label: 'Convert',
              icon: CupertinoIcons.arrow_right_arrow_left,
              isActive: activeTab == EditorTab.linkConverter,
              onTap: () => onTabChanged(EditorTab.linkConverter),
            ),
            _Tab(
              label: 'Bulk',
              icon: CupertinoIcons.square_stack,
              isActive: activeTab == EditorTab.bulkImport,
              onTap: () => onTabChanged(EditorTab.bulkImport),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? AppColors.black : AppColors.grey400,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? AppColors.black : AppColors.grey400,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorPanel extends ConsumerWidget {
  final TextEditingController controller;
  final EditorState state;
  final EditorController editorCtrl;

  const _EditorPanel({
    super.key,
    required this.controller,
    required this.state,
    required this.editorCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _EditorToolbar(state: state, editorCtrl: editorCtrl),
        if (state.jsonError != null) _JsonErrorBar(error: state.jsonError!),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.jsonError != null
                    ? AppColors.errorRed.withOpacity(0.3)
                    : AppColors.grey200,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: controller,
                onChanged: editorCtrl.updateJson,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTextStyles.mono,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  hintText:
                      '{\n  "remarks": "My Server",\n  "outbounds": []\n}',
                  hintStyle: AppTextStyles.mono.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (state.isValid)
          _ConvertToLinkBar(state: state, editorCtrl: editorCtrl),
      ],
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  final EditorState state;
  final EditorController editorCtrl;

  const _EditorToolbar({required this.state, required this.editorCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _ToolBtn(
            icon: CupertinoIcons.arrow_uturn_left,
            label: 'Undo',
            enabled: state.canUndo,
            onTap: editorCtrl.undo,
          ),
          const SizedBox(width: AppSpacing.xs),
          _ToolBtn(
            icon: CupertinoIcons.arrow_uturn_right,
            label: 'Redo',
            enabled: state.canRedo,
            onTap: editorCtrl.redo,
          ),
          const Spacer(),
          _ToolBtn(
            icon: CupertinoIcons.textformat,
            label: 'Format',
            enabled: state.isValid,
            onTap: editorCtrl.formatJson,
          ),
          const SizedBox(width: AppSpacing.xs),
          _ToolBtn(
            icon: CupertinoIcons.minus,
            label: 'Minify',
            enabled: state.isValid,
            onTap: editorCtrl.minifyJson,
          ),
          const SizedBox(width: AppSpacing.xs),
          _ToolBtn(
            icon: CupertinoIcons.doc_on_clipboard,
            label: 'Copy',
            enabled: state.rawJson.isNotEmpty,
            onTap: () {
              Clipboard.setData(ClipboardData(text: state.rawJson));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard ✓'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _ToolBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: CupertinoButton(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onPressed: enabled ? onTap : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 150),
          child: Icon(icon, size: 18, color: AppColors.black),
        ),
      ),
    );
  }
}

class _JsonErrorBar extends StatelessWidget {
  final String error;
  const _JsonErrorBar({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.errorRed.withOpacity(AppOpacity.subtle),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.xmark_circle_fill,
            size: 14,
            color: AppColors.errorRed,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            error,
            style: AppTextStyles.caption.copyWith(color: AppColors.errorRed),
          ),
        ],
      ),
    );
  }
}

class _ConvertToLinkBar extends StatelessWidget {
  final EditorState state;
  final EditorController editorCtrl;

  const _ConvertToLinkBar({required this.state, required this.editorCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grey200, width: 0.5)),
      ),
      child: Column(
        children: [
          if (state.link != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.link!,
                      style: AppTextStyles.mono.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.link!));
                    },
                    child: const Icon(
                      CupertinoIcons.doc_on_clipboard,
                      size: 18,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isBusy ? null : editorCtrl.convertConfigToLink,
              icon: state.operation == EditorOperation.converting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.link, size: 16),
              label: const Text('Export as Share Link'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkConverterPanel extends StatelessWidget {
  final TextEditingController linkCtrl;
  final EditorState state;
  final EditorController editorCtrl;

  const _LinkConverterPanel({
    super.key,
    required this.linkCtrl,
    required this.state,
    required this.editorCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paste a share link', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Supports vless://, vmess://, trojan://, ss://, hysteria2://',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: linkCtrl,
            style: AppTextStyles.mono.copyWith(fontSize: 13),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'vless://uuid@host:443?...',
              hintStyle: AppTextStyles.mono.copyWith(
                fontSize: 13,
                color: AppColors.grey400,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isBusy
                  ? null
                  : () => editorCtrl.convertLinkToConfig(linkCtrl.text),
              icon: state.operation == EditorOperation.converting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.arrow_right, size: 16),
              label: const Text('Convert to Config'),
            ),
          ),
          const Spacer(),
          _SupportedProtocols(),
        ],
      ),
    );
  }
}

class _SupportedProtocols extends StatelessWidget {
  const _SupportedProtocols();

  @override
  Widget build(BuildContext context) {
    const protocols = ['vless', 'vmess', 'trojan', 'shadowsocks', 'hysteria2'];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: protocols
          .map(
            (p) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Text(p, style: AppTextStyles.mono.copyWith(fontSize: 11)),
            ),
          )
          .toList(),
    );
  }
}

class _BulkImportPanel extends StatelessWidget {
  final TextEditingController bulkCtrl;
  final EditorState state;
  final EditorController editorCtrl;

  const _BulkImportPanel({
    super.key,
    required this.bulkCtrl,
    required this.state,
    required this.editorCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bulk import links', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'One link per line — bad ones get flagged, no drama',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: bulkCtrl,
              style: AppTextStyles.mono.copyWith(fontSize: 12),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'vless://...\nvmess://...\ntrojan://...',
                hintStyle: AppTextStyles.mono.copyWith(
                  fontSize: 12,
                  color: AppColors.grey400,
                ),
              ),
            ),
          ),
          if (state.lastImportResult != null)
            _ImportResultCard(result: state.lastImportResult!),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isBusy
                  ? null
                  : () {
                      final links = bulkCtrl.text
                          .split('\n')
                          .map((l) => l.trim())
                          .where((l) => l.isNotEmpty)
                          .toList();
                      editorCtrl.bulkImportLinks(links);
                    },
              icon: state.operation == EditorOperation.importing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.square_stack, size: 16),
              label: const Text('Import All'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportResultCard extends StatelessWidget {
  final ImportResult result;
  const _ImportResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Imported',
            count: result.imported.length,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatChip(
            label: 'Failed',
            count: result.failed.length,
            color: AppColors.errorRed,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$count $label',
          style: AppTextStyles.caption.copyWith(color: AppColors.black),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool isValid;
  final bool isDirty;

  const _StatusIndicator({required this.isValid, required this.isDirty});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: !isDirty
            ? Colors.transparent
            : isValid
            ? AppColors.successGreen.withOpacity(AppOpacity.light)
            : AppColors.errorRed.withOpacity(AppOpacity.light),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !isDirty
                  ? AppColors.grey400
                  : isValid
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
          ),
          if (isDirty) ...[
            const SizedBox(width: 4),
            Text(
              isValid ? 'valid' : 'error',
              style: AppTextStyles.caption.copyWith(
                color: isValid ? AppColors.successGreen : AppColors.errorRed,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApiErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ApiErrorBanner({required this.error, required this.onDismiss});

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
            child: const Icon(
              CupertinoIcons.xmark,
              size: 12,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
