import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/services/auth_service.dart';

class SubEntry {
  final String link;
  final String name;
  final String protocol;

  const SubEntry({
    required this.link,
    required this.name,
    required this.protocol,
  });
}

enum SubStatus { idle, fetching, converting, done, error }

class SubscriptionState {
  final SubStatus status;
  final String? error;
  final List<SubEntry> entries;
  final int total;
  final int converted;
  final String url;
  final String lastFetchedUrl;

  const SubscriptionState({
    this.status = SubStatus.idle,
    this.error,
    this.entries = const [],
    this.total = 0,
    this.converted = 0,
    this.url = '',
    this.lastFetchedUrl = '',
  });

  bool get isBusy =>
      status == SubStatus.fetching || status == SubStatus.converting;

  double get progress => total == 0 ? 0 : converted / total;

  SubscriptionState copyWith({
    SubStatus? status,
    String? error,
    List<SubEntry>? entries,
    int? total,
    int? converted,
    String? url,
    String? lastFetchedUrl,
    bool clearError = false,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      entries: entries ?? this.entries,
      total: total ?? this.total,
      converted: converted ?? this.converted,
      url: url ?? this.url,
      lastFetchedUrl: lastFetchedUrl ?? this.lastFetchedUrl,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final Dio _dio;

  SubscriptionNotifier(this._dio) : super(const SubscriptionState());

  void setUrl(String url) => state = state.copyWith(url: url);

  void clearError() => state = state.copyWith(clearError: true);

  void clear() => state = const SubscriptionState();

  Future<void> fetchAndConvert() async {
    final url = state.url.trim();
    if (url.isEmpty) return;
    if (url == state.lastFetchedUrl && state.status == SubStatus.done) return;

    state = state.copyWith(
      status: SubStatus.fetching,
      entries: [],
      total: 0,
      converted: 0,
      clearError: true,
    );

    try {
      final res = await Dio().get(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      final raw = res.data as String;
      final links = _decodeSubscription(raw);

      if (links.isEmpty) {
        state = state.copyWith(
          status: SubStatus.error,
          error: 'No valid proxy links found in subscription',
        );
        return;
      }

      final entries = links.map((link) {
        final name = _nameFromLink(link);
        final protocol = _extractProtocol(link);
        return SubEntry(link: link, name: name, protocol: protocol);
      }).toList();

      state = state.copyWith(
        status: SubStatus.done,
        entries: entries,
        total: entries.length,
        converted: entries.length,
        lastFetchedUrl: url,
      );
    } on DioException catch (e) {
      state = state.copyWith(status: SubStatus.error, error: _parseDioError(e));
    } catch (e) {
      state = state.copyWith(status: SubStatus.error, error: e.toString());
    }
  }

  List<String> _decodeSubscription(String raw) {
    final trimmed = raw.trim();
    List<String> lines;

    try {
      final decoded = utf8.decode(base64.decode(trimmed));
      lines = decoded.split(RegExp(r'\r?\n'));
    } catch (_) {
      lines = trimmed.split(RegExp(r'\r?\n'));
    }

    final protocols = [
      'vless://',
      'vmess://',
      'trojan://',
      'ss://',
      'hysteria2://',
    ];
    return lines
        .map((l) => l.trim())
        .where((l) => protocols.any((p) => l.startsWith(p)))
        .toList();
  }

  String _nameFromLink(String link) {
    final hashIndex = link.lastIndexOf('#');
    if (hashIndex != -1 && hashIndex < link.length - 1) {
      try {
        return Uri.decodeComponent(link.substring(hashIndex + 1)).trim();
      } catch (_) {}
    }
    final uri = Uri.tryParse(link.split('#').first);
    if (uri?.host.isNotEmpty == true) return uri!.host;
    return link.split('://').first.toUpperCase();
  }

  String _extractProtocol(String link) {
    return link.split('://').first.toLowerCase();
  }

  String _parseDioError(DioException e) {
    if (e.response != null) return 'Server error ${e.response?.statusCode}';
    if (e.type == DioExceptionType.connectionTimeout)
      return 'Connection timed out';
    return 'Network error — check the URL fam';
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      final dio = ref.watch(dioProvider);
      return SubscriptionNotifier(dio);
    });
