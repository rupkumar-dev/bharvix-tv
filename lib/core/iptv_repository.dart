
import 'package:bharvix_tv/core/errors/api_exception.dart';
import 'dart:convert';

import 'package:bharvix_tv/models/raw/block_raw.dart';
import 'package:bharvix_tv/models/raw/channel_raw.dart';
import 'package:bharvix_tv/models/raw/feed_raw.dart';
import 'package:bharvix_tv/models/raw/logo_raw.dart';
import 'package:bharvix_tv/models/raw/stream_raw.dart';
import 'package:http/http.dart' as http;
import '../models/app_channel.dart';


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
