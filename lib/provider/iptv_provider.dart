import 'dart:convert';
import 'package:bharvix_tv/core/errors/api_exception.dart';
import 'package:bharvix_tv/models/raw/block_raw.dart';
import 'package:bharvix_tv/models/raw/channel_raw.dart';
import 'package:bharvix_tv/models/raw/feed_raw.dart';
import 'package:bharvix_tv/models/raw/logo_raw.dart';
import 'package:bharvix_tv/models/raw/stream_raw.dart';
import 'package:http/http.dart' as http;
import '../models/app_channel.dart';
import 'dart:collection';
import 'package:flutter/foundation.dart';

class IptvRepository {
  static const _base = 'https://iptv-org.github.io/api';
  static const _timeout = Duration(seconds: 10);

  Future<List<AppChannel>> loadChannels() async {
    final res = await Future.wait([
      _get('channels.json'), // 0
      _get('feeds.json'), // 1
      _get('streams.json'), // 2
      _get('logos.json'), // 3
      _get('blocklist.json'), // 4
    ]);

    final channels = res[0].map(ChannelRaw.fromJson).toList();
    final feeds = res[1].map(FeedRaw.fromJson).toList();
    final logos = res[3].map(LogoRaw.fromJson).toList();
    final blocked = res[4].map(BlockRaw.fromJson).map((e) => e.channel).toSet();

    // ---------- channel → streams ----------
    final Map<String, List<StreamRaw>> streamMap = {};

    for (final m in res[2]) {
      StreamRaw s;
      try {
        s = StreamRaw.fromJson(m);
      } catch (_) {
        continue;
      }

      if (s.channel.isEmpty || s.url.isEmpty) continue;
      (streamMap[s.channel] ??= []).add(s);
    }

    // ---------- channel → language (from feeds) ----------
    final Map<String, String> languageMap = {};
    for (final f in feeds) {
      if (f.channel.isEmpty || f.languages.isEmpty) continue;
      languageMap.putIfAbsent(f.channel, () => f.languages.first);
    }

    // ---------- channel → logo ----------
    final Map<String, String> logoMap = {
      for (final l in logos)
        if (l.channel.isNotEmpty && l.url.isNotEmpty) l.channel: l.url,
    };

    // ---------- build ----------
    final List<AppChannel> result = [];

    for (final ch in channels) {
      if (blocked.contains(ch.id)) continue;

      final chStreams = streamMap[ch.id];
      if (chStreams == null || chStreams.isEmpty) continue;

      final first = chStreams.first;

      final headers = <String, String>{
        if (first.referrer != null) 'Referer': first.referrer!,
        if (first.userAgent != null) 'User-Agent': first.userAgent!,
      };

      result.add(
        AppChannel(
          id: ch.id,
          name: ch.name,
          country: ch.country,
          categories: ch.categories,
          languages: languageMap[ch.id] != null
              ? [languageMap[ch.id]!]
              : const [],
          logo: logoMap[ch.id] ?? '',
          streams: chStreams.map((e) => e.url).toList(growable: false),
          headers: headers.isEmpty ? null : headers,
        ),
      );
    }

    return result;
  }

  // ---------- HTTP ----------
  Future<List<Map<String, dynamic>>> _get(String file) async {
    final res = await http.get(Uri.parse('$_base/$file')).timeout(_timeout);

    if (res.statusCode != 200) {
      throw ApiException('Request failed', statusCode: res.statusCode);
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw ApiException('Invalid response format');
    }

    return decoded.cast<Map<String, dynamic>>();
  }
}

class IptvRepository3 {
  static const _base = 'https://iptv-org.github.io/api';
  static const _timeout = Duration(seconds: 10);

  Future<List<AppChannel>> loadChannels() async {
    debugPrint('IPTV: Loading data from iptv-org API');

    final res = await Future.wait([
      _get('channels.json'),
      _get('streams.json'),
      _get('logos.json'),
      _get('blocklist.json'),
    ]);

    debugPrint('IPTV: Raw data loaded');
    debugPrint('Channels: ${res[0].length}');
    debugPrint('Streams: ${res[1].length}');
    debugPrint('Logos: ${res[2].length}');
    debugPrint('Blocked: ${res[3].length}');

    final channels = res[0];
    final streams = res[1];
    final logos = res[2];
    final blocked = res[3].map((e) => e['channel']).whereType<String>().toSet();

    // channel → streams
    final Map<String, List<String>> streamMap = {};
    for (final s in streams) {
      if (s['status'] != null && s['status'] != 'online') continue;
      final id = s['channel'];
      final url = s['url'];
      if (id is String && url is String) {
        (streamMap[id] ??= []).add(url);
      }
    }
    debugPrint('IPTV: Streams mapped for ${streamMap.length} channels');

    // channel → logo
    final Map<String, String> logoMap = {
      for (final l in logos)
        if (l['channel'] is String && l['url'] is String)
          l['channel']: l['url'],
    };

    debugPrint('IPTV: Logos mapped for ${logoMap.length} channels');

    final List<AppChannel> result = [];

    for (final ch in channels) {
      final id = ch['id'];
      if (id is! String) continue;
      if (blocked.contains(id)) continue;

      final streams = streamMap[id];
      if (streams == null || streams.isEmpty) continue;
      Map<String, String>? headers;

      final name = (ch['name'] ?? '').toString().toLowerCase();

      // Example: ABP News
      if (name.contains('abp')) {
        headers = {
          'Referer': 'https://cdn.abplive.com',
          'User-Agent': 'Mozilla/5.0',
        };
      }

      result.add(
        AppChannel(
          id: id,
          name: ch['name'] ?? '',
          country: ch['country'] ?? '',
          languages: List<String>.from(ch['languages'] ?? const []),
          categories: List<String>.from(ch['categories'] ?? const []),
          logo: logoMap[id] ?? '',
          streams: streams,
          headers: headers,
        ),
      );
    }
    debugPrint('IPTV: Final playable channels = ${result.length}');
    return result;
  }

  Future<List<Map<String, dynamic>>> _get(String file) async {
    try {
      final res = await http.get(Uri.parse('$_base/$file')).timeout(_timeout);

      if (res.statusCode != 200) {
        throw ApiException('Request failed', statusCode: res.statusCode);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List) {
        throw ApiException('Invalid response format');
      }

      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}

class IptvProvider extends ChangeNotifier {
  final IptvRepository _repo;

  IptvProvider(this._repo);

  bool _loading = false;
  String? _error;
  List<AppChannel> _channels = [];

  bool get loading => _loading;
  String? get error => _error;

  UnmodifiableListView<AppChannel> get channels =>
      UnmodifiableListView(_channels);

  // ---------------- Load ----------------
  Future<void> load() async {
    if (_loading) {
      debugPrint('PROVIDER: Already loading, skip');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      _channels = await _repo.loadChannels()
        ..sort((a, b) => a.name.compareTo(b.name));

      debugPrint('PROVIDER: Channels stored = ${_channels.length}');
    } catch (e) {
      _error = e.toString();
      debugPrint('PROVIDER ERROR: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Filters ----------





  List<AppChannel> filterChannels({
    String? country,
    String? language,
    String? category,
    int? limit,
  }) {
    Iterable<AppChannel> result = _channels.where((c) {
      if (country != null && c.country != country) return false;
      if (language != null && !c.languages.contains(language)) return false;
      if (category != null && !c.categories.contains(category)) return false;
      return true;
    });

    if (limit != null && limit > 0) {
      result = result.take(limit);
    }

    return result.toList(growable: false);
  }

  List<AppChannel> search(String query) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) return const [];

  return _channels
      .where(
        (c) =>
            c.name.toLowerCase().contains(q) ||
            c.categories.any((e) => e.toLowerCase().contains(q)) ||
            c.languages.any((e) => e.toLowerCase().contains(q)) ||
            c.country.toLowerCase() == q,
      )
      .toList(growable: false);
}



  // ---------------- Search ----------------


  // ---------------- Internal ----------------
  void _setLoading(bool v) {
    if (_loading == v) return;
    _loading = v;
    notifyListeners();
  }


  List<AppChannel> popularChannels({int limit = 40}) {
    final popularCats = {'news', 'movies', 'sports'};

    return _channels
        .where(
          (c) =>
              c.logo.isNotEmpty &&
              c.streams.isNotEmpty &&
              c.categories.any((e) => popularCats.contains(e)),
        )
        .take(limit)
        .toList(growable: false);
  }
}
