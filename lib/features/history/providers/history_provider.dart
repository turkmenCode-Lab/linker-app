import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/config/app_config.dart';

typedef HistoryAction = String;
const kActionLinkToConfig = 'link_to_config';
const kActionConfigToLink = 'config_to_link';
const kActionBulkImport = 'bulk_import';
const kActionSubscription = 'subscription';

class HistoryItem {
  final String id;
  final HistoryAction action;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final bool success;
  final String? error;
  final DateTime createdAt;

  const HistoryItem({
    required this.id,
    required this.action,
    required this.input,
    required this.output,
    required this.success,
    this.error,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
    id: j['_id'] as String,
    action: j['action'] as String,
    input: Map<String, dynamic>.from(j['input'] as Map? ?? {}),
    output: Map<String, dynamic>.from(j['output'] as Map? ?? {}),
    success: j['success'] as bool? ?? true,
    error: j['error'] as String?,
    createdAt:
        DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  String get actionLabel => switch (action) {
    kActionLinkToConfig => 'Link → Config',
    kActionConfigToLink => 'Config → Link',
    kActionBulkImport => 'Bulk Import',
    kActionSubscription => 'Subscription',
    _ => action,
  };

  String get preview {
    switch (action) {
      case kActionLinkToConfig:
        return input['link'] as String? ?? '';
      case kActionConfigToLink:
        final link = output['link'] as String?;
        return link ?? (input['config'] as Map?)?['remarks'] as String? ?? '';
      case kActionBulkImport:
        final count = (output['imported'] as List?)?.length ?? 0;
        return '$count configs imported';
      case kActionSubscription:
        return input['url'] as String? ?? '';
      default:
        return '';
    }
  }
}

class HistoryState {
  final List<HistoryItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final int total;
  final int pages;
  final String? filterAction;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.total = 0,
    this.pages = 1,
    this.filterAction,
  });

  bool get hasMore => page < pages;

  HistoryState copyWith({
    List<HistoryItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? total,
    int? pages,
    String? filterAction,
    bool clearError = false,
    bool clearFilter = false,
  }) => HistoryState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: clearError ? null : error ?? this.error,
    page: page ?? this.page,
    total: total ?? this.total,
    pages: pages ?? this.pages,
    filterAction: clearFilter ? null : filterAction ?? this.filterAction,
  );
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Dio _dio;

  HistoryNotifier(this._dio) : super(const HistoryState());

  Future<void> load({String? action}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      filterAction: action,
      clearFilter: action == null,
    );
    try {
      final res = await _dio.get(
        AppConfig.history,
        queryParameters: {
          'page': 1,
          'limit': 20,
          if (action != null) 'action': action,
        },
      );
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        items: (data['items'] as List)
            .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: 1,
        total: data['total'] as int,
        pages: data['pages'] as int,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final res = await _dio.get(
        AppConfig.history,
        queryParameters: {
          'page': nextPage,
          'limit': 20,
          if (state.filterAction != null) 'action': state.filterAction,
        },
      );
      final data = res.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoadingMore: false,
        items: [
          ...state.items,
          ...(data['items'] as List).map(
            (e) => HistoryItem.fromJson(e as Map<String, dynamic>),
          ),
        ],
        page: nextPage,
        pages: data['pages'] as int,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: _parseError(e));
    }
  }

  Future<void> deleteOne(String id) async {
    try {
      await _dio.delete('${AppConfig.history}/$id');
      state = state.copyWith(
        items: state.items.where((i) => i.id != id).toList(),
        total: state.total - 1,
      );
    } on DioException catch (e) {
      state = state.copyWith(error: _parseError(e));
    }
  }

  Future<void> deleteAll() async {
    try {
      await _dio.delete(AppConfig.history);
      state = state.copyWith(items: [], total: 0, page: 1, pages: 1);
    } on DioException catch (e) {
      state = state.copyWith(error: _parseError(e));
    }
  }

  void setFilter(String? action) => load(action: action);

  String _parseError(DioException e) {
    if (e.response != null) return 'Server error ${e.response?.statusCode}';
    return 'Network error';
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return HistoryNotifier(dio);
});
