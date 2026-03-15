import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/config/app_config.dart';

enum EditorOperation { idle, converting, importing, exporting }

enum EditorTab { editor, linkConverter, bulkImport }

class ImportResult {
  final List<Map<String, dynamic>> imported;
  final List<Map<String, dynamic>> failed;
  const ImportResult({required this.imported, required this.failed});
}

class EditorState {
  final String rawJson;
  final Map<String, dynamic>? parsedConfig;
  final String? jsonError;
  final String? link;
  final String? apiError;
  final EditorOperation operation;
  final EditorTab activeTab;
  final ImportResult? lastImportResult;
  final bool isDirty;
  final List<String> history;
  final int historyIndex;

  const EditorState({
    this.rawJson = '',
    this.parsedConfig,
    this.jsonError,
    this.link,
    this.apiError,
    this.operation = EditorOperation.idle,
    this.activeTab = EditorTab.editor,
    this.lastImportResult,
    this.isDirty = false,
    this.history = const [],
    this.historyIndex = -1,
  });

  bool get isValid => jsonError == null && rawJson.isNotEmpty;
  bool get isBusy => operation != EditorOperation.idle;
  bool get canUndo => historyIndex > 0;
  bool get canRedo => historyIndex < history.length - 1;

  EditorState copyWith({
    String? rawJson,
    Map<String, dynamic>? parsedConfig,
    String? jsonError,
    String? link,
    String? apiError,
    EditorOperation? operation,
    EditorTab? activeTab,
    ImportResult? lastImportResult,
    bool? isDirty,
    List<String>? history,
    int? historyIndex,
    bool clearJsonError = false,
    bool clearApiError = false,
    bool clearParsed = false,
    bool clearLink = false,
    bool clearImport = false,
  }) {
    return EditorState(
      rawJson: rawJson ?? this.rawJson,
      parsedConfig: clearParsed ? null : parsedConfig ?? this.parsedConfig,
      jsonError: clearJsonError ? null : jsonError ?? this.jsonError,
      link: clearLink ? null : link ?? this.link,
      apiError: clearApiError ? null : apiError ?? this.apiError,
      operation: operation ?? this.operation,
      activeTab: activeTab ?? this.activeTab,
      lastImportResult: clearImport
          ? null
          : lastImportResult ?? this.lastImportResult,
      isDirty: isDirty ?? this.isDirty,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
    );
  }
}

class EditorController extends StateNotifier<EditorState> {
  final Dio _dio;

  EditorController(this._dio) : super(const EditorState());

  void updateJson(String raw) {
    Map<String, dynamic>? parsed;
    String? error;

    if (raw.trim().isEmpty) {
      state = state.copyWith(
        rawJson: raw,
        clearParsed: true,
        clearJsonError: true,
        isDirty: false,
      );
      return;
    }

    try {
      parsed = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      error = _friendlyJsonError(e.toString());
    }

    final newHistory = [
      ...state.history.sublist(0, state.historyIndex + 1),
      raw,
    ];

    state = state.copyWith(
      rawJson: raw,
      parsedConfig: parsed,
      jsonError: error,
      clearJsonError: error == null,
      isDirty: true,
      history: newHistory,
      historyIndex: newHistory.length - 1,
    );
  }

  void loadJson(Map<String, dynamic> json) {
    final raw = const JsonEncoder.withIndent('  ').convert(json);
    updateJson(raw);
  }

  void formatJson() {
    if (state.parsedConfig == null) return;
    final formatted = const JsonEncoder.withIndent(
      '  ',
    ).convert(state.parsedConfig);
    state = state.copyWith(rawJson: formatted);
  }

  void minifyJson() {
    if (state.parsedConfig == null) return;
    final minified = jsonEncode(state.parsedConfig);
    state = state.copyWith(rawJson: minified);
  }

  void clearEditor() {
    state = const EditorState();
  }

  void undo() {
    if (!state.canUndo) return;
    final newIndex = state.historyIndex - 1;
    final raw = state.history[newIndex];
    Map<String, dynamic>? parsed;
    try {
      parsed = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {}
    state = state.copyWith(
      rawJson: raw,
      parsedConfig: parsed,
      historyIndex: newIndex,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final newIndex = state.historyIndex + 1;
    final raw = state.history[newIndex];
    Map<String, dynamic>? parsed;
    try {
      parsed = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {}
    state = state.copyWith(
      rawJson: raw,
      parsedConfig: parsed,
      historyIndex: newIndex,
    );
  }

  void switchTab(EditorTab tab) {
    state = state.copyWith(activeTab: tab, clearApiError: true);
  }

  Future<void> convertLinkToConfig(String link, {bool autoCopy = true}) async {
    state = state.copyWith(
      operation: EditorOperation.converting,
      clearApiError: true,
    );
    try {
      final res = await _dio.post(
        AppConfig.proxyLinkToConfig,
        data: {'link': link.trim()},
      );
      loadJson(res.data as Map<String, dynamic>);
      if (autoCopy) {
        final formatted = const JsonEncoder.withIndent(
          '  ',
        ).convert(res.data as Map<String, dynamic>);
        await Clipboard.setData(ClipboardData(text: formatted));
      }
      state = state.copyWith(
        operation: EditorOperation.idle,
        activeTab: EditorTab.editor,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        operation: EditorOperation.idle,
        apiError: _parseDioError(e),
      );
    }
  }

  Future<void> convertConfigToLink() async {
    if (state.parsedConfig == null) return;
    state = state.copyWith(
      operation: EditorOperation.converting,
      clearApiError: true,
      clearLink: true,
    );
    try {
      final res = await _dio.post(
        AppConfig.proxyConfigToLink,
        data: {'config': state.parsedConfig},
      );
      state = state.copyWith(
        operation: EditorOperation.idle,
        link: res.data['link'] as String,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        operation: EditorOperation.idle,
        apiError: _parseDioError(e),
      );
    }
  }

  Future<void> bulkImportLinks(List<String> links) async {
    if (links.isEmpty) return;
    state = state.copyWith(
      operation: EditorOperation.importing,
      clearApiError: true,
      clearImport: true,
    );
    try {
      final res = await _dio.post(
        AppConfig.proxyBulkImport,
        data: {'links': links},
      );
      final data = res.data as Map<String, dynamic>;
      final imported = (data['imported'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final failed = (data['failed'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      if (imported.isNotEmpty) loadJson(imported.first);

      state = state.copyWith(
        operation: EditorOperation.idle,
        lastImportResult: ImportResult(imported: imported, failed: failed),
      );
    } on DioException catch (e) {
      state = state.copyWith(
        operation: EditorOperation.idle,
        apiError: _parseDioError(e),
      );
    }
  }

  String _parseDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Server said no (${e.response?.statusCode}) 💀';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out — is the server even on?';
    }
    return 'Network error — check your wifi bestie';
  }

  String _friendlyJsonError(String raw) {
    if (raw.contains('Unexpected character')) return 'Unexpected character 😬';
    if (raw.contains('Unexpected end')) return 'JSON is incomplete fam';
    if (raw.contains('FormatException')) return 'Invalid JSON format';
    return 'JSON parse error';
  }
}

final editorControllerProvider =
    StateNotifierProvider<EditorController, EditorState>((ref) {
      final dio = ref.watch(dioProvider);
      return EditorController(dio);
    });
