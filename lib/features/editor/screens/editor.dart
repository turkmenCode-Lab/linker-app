import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/editor_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';

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
    if (selection.start <= raw.length) _jsonCtrl.selection = selection;
    _syncingController = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorControllerProvider);
    final ctrl = ref.read(editorControllerProvider.notifier);
    final s = ref.watch(stringsProvider);

    ref.listen(
      editorControllerProvider,
      (_, next) => _syncFromState(next.rawJson),
    );

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divColor = isDark ? AppColors.darkDivider : AppColors.grey200;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusIndicator(
                          isValid: state.isValid,
                          isDirty: state.isDirty,
                        ),
                      ),
                    ),
                    Text(
                      'linker',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
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
    );
  }
}

class _TabBar extends ConsumerWidget {
  final EditorTab activeTab;
  final void Function(EditorTab) onTabChanged;
  const _TabBar({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            _Tab(
              label: s.editor,
              icon: CupertinoIcons.doc_text,
              isActive: activeTab == EditorTab.editor,
              onTap: () => onTabChanged(EditorTab.editor),
            ),
            _Tab(
              label: s.convert,
              icon: CupertinoIcons.arrow_right_arrow_left,
              isActive: activeTab == EditorTab.linkConverter,
              onTap: () => onTabChanged(EditorTab.linkConverter),
            ),
            _Tab(
              label: s.bulk,
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
    final c = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: c.onSurface.withOpacity(0.08),
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
                color: isActive ? c.onSurface : c.onSurface.withOpacity(0.35),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? c.onSurface : c.onSurface.withOpacity(0.35),
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
        _ConvertToLinkBar(state: state, editorCtrl: editorCtrl),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.jsonError != null
                    ? AppColors.errorRed.withOpacity(0.3)
                    : Theme.of(context).dividerColor,
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
                style: AppTextStyles.mono.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.35),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditorToolbar extends ConsumerWidget {
  final EditorState state;
  final EditorController editorCtrl;
  const _EditorToolbar({required this.state, required this.editorCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToolBtn(
              icon: CupertinoIcons.arrow_uturn_left,
              label: s.undo,
              enabled: state.canUndo,
              onTap: editorCtrl.undo,
            ),
          ),
          Expanded(
            child: _ToolBtn(
              icon: CupertinoIcons.arrow_uturn_right,
              label: s.redo,
              enabled: state.canRedo,
              onTap: editorCtrl.redo,
            ),
          ),
          Expanded(
            child: _ToolBtn(
              icon: CupertinoIcons.textformat,
              label: s.formatJson,
              enabled: state.isValid,
              onTap: editorCtrl.formatJson,
            ),
          ),
          Expanded(
            child: _ToolBtn(
              icon: CupertinoIcons.minus,
              label: s.minifyJson,
              enabled: state.isValid,
              onTap: editorCtrl.minifyJson,
            ),
          ),
          Expanded(
            child: _ToolBtn(
              icon: CupertinoIcons.doc_on_clipboard,
              label: s.copy,
              enabled: state.rawJson.isNotEmpty,
              onTap: () {
                Clipboard.setData(ClipboardData(text: state.rawJson));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.copied),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _ToolBtn(
              icon: CupertinoIcons.doc_plaintext,
              label: s.paste,
              enabled: true,
              onTap: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) editorCtrl.updateJson(data!.text!);
              },
            ),
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
    final color = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        height: double.infinity,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.25,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: color,
                    letterSpacing: 0.1,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
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

class _ConvertToLinkBar extends ConsumerWidget {
  final EditorState state;
  final EditorController editorCtrl;
  const _ConvertToLinkBar({required this.state, required this.editorCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          if (state.link != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.link!,
                      style: AppTextStyles.mono.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: state.link!)),
                    child: Icon(
                      CupertinoIcons.doc_on_clipboard,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AnimatedOpacity(
            opacity: state.isValid ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (state.isBusy || !state.isValid)
                    ? null
                    : editorCtrl.convertConfigToLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  disabledBackgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  disabledForegroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                ),
                icon: state.operation == EditorOperation.converting
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        ),
                      )
                    : const Icon(CupertinoIcons.link, size: 16),
                label: Text(s.exportAsLink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkConverterPanel extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.pasteLink,
            style: AppTextStyles.titleMedium.copyWith(color: c.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            s.supportedProtocols,
            style: AppTextStyles.caption.copyWith(
              color: c.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: linkCtrl,
            style: AppTextStyles.mono.copyWith(
              fontSize: 13,
              color: c.onSurface,
            ),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'vless://uuid@host:443?...',
              hintStyle: AppTextStyles.mono.copyWith(
                fontSize: 13,
                color: c.onSurface.withOpacity(0.35),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isBusy
                  ? null
                  : () {
                      final autoCopy = ref.read(autoCopyProvider);
                      editorCtrl.convertLinkToConfig(
                        linkCtrl.text,
                        autoCopy: autoCopy,
                      );
                    },
              icon: state.operation == EditorOperation.converting
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.onPrimary,
                      ),
                    )
                  : const Icon(CupertinoIcons.arrow_right, size: 16),
              label: Text(s.convertToConfig),
            ),
          ),
          const Spacer(),
          const _SupportedProtocols(),
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
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                p,
                style: AppTextStyles.mono.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BulkImportPanel extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.bulkImportTitle,
            style: AppTextStyles.titleMedium.copyWith(color: c.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            s.bulkImportSubtitle,
            style: AppTextStyles.caption.copyWith(
              color: c.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: bulkCtrl,
              style: AppTextStyles.mono.copyWith(
                fontSize: 12,
                color: c.onSurface,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'vless://...\nvmess://...\ntrojan://...',
                hintStyle: AppTextStyles.mono.copyWith(
                  fontSize: 12,
                  color: c.onSurface.withOpacity(0.35),
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
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.onPrimary,
                      ),
                    )
                  : const Icon(CupertinoIcons.square_stack, size: 16),
              label: Text(s.importAll),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportResultCard extends ConsumerWidget {
  final ImportResult result;
  const _ImportResultCard({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _StatChip(
            label: s.imported,
            count: result.imported.length,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatChip(
            label: s.failed,
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
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.35)
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
