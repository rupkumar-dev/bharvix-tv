


// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import '../model/app_channel.dart';

// class IptvRepository {
//   static const String _base = 'https://iptv-org.github.io/api';
//   static const Duration _timeout = Duration(seconds: 10);

//   /// MAIN ENTRY — call once, cache result
//   Future<List<AppChannel>> loadPlayableChannels() async {
//     final responses = await Future.wait([
//       _getList('channels.json'),
//       _getList('streams.json'),
//       _getList('logos.json'),
//       _getList('blocklist.json'),
//     ]);

//     final channelsRaw = responses[0];
//     final streamsRaw = responses[1];
//     final logosRaw = responses[2];
//     final blocklistRaw = responses[3];

//     /// Blocked channel IDs
//     final blockedIds = {
//       for (final b in blocklistRaw)
//         if (b['channel'] is String) b['channel'] as String
//     };

//     /// channelId → stream URLs
//     final Map<String, List<String>> streamMap = {};

//     for (final s in streamsRaw) {
//       final id = s['channel'];
//       final url = s['url'];

//       if (id is! String || url is! String) continue;

//       final status = s['status'];
//       if (status != null && status != 'online') continue;

//       (streamMap[id] ??= []).add(url);
//     }

//     /// channelId → logo URL
//     final Map<String, String> logoMap = {
//       for (final l in logosRaw)
//         if (l['channel'] is String && l['url'] is String)
//           l['channel'] as String: l['url'] as String
//     };

//     final List<AppChannel> result = [];

//     for (final ch in channelsRaw) {
//       final id = ch['id'];
//       if (id is! String) continue;
//       if (blockedIds.contains(id)) continue;

//       final streams = streamMap[id];
//       if (streams == null || streams.isEmpty) continue;

//       result.add(
//         AppChannel(
//           id: id,
//           name: ch['name'] ?? '',
//           country: ch['country'] ?? 'Unknown',
//           categories:
//               List<String>.from(ch['categories'] ?? const []),
//           languages:
//               List<String>.from(ch['languages'] ?? const []),
//           logo: logoMap[id] ?? '',
//           streams: streams,
//         ),
//       );
//     }

//     debugPrint('Loaded channels: ${result.length}');
//     return result;
//   }

//   /// ---------- Internal ----------
//   Future<List<Map<String, dynamic>>> _getList(String file) async {
//     final res = await http
//         .get(Uri.parse('$_base/$file'))
//         .timeout(_timeout);

//     if (res.statusCode != 200) {
//       throw Exception('Failed to load $file');
//     }

//     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/app_channel.dart';

class IptvRepository {
  static const _base = 'https://iptv-org.github.io/api';

  Future<List<AppChannel>> loadChannels() async {
    final res = await Future.wait([
      _get('channels.json'),
      _get('streams.json'),
      _get('logos.json'),
      _get('blocklist.json'),
    ]);

    final channels = res[0];
    final streams = res[1];
    final logos = res[2];
    final blocked = res[3]
        .map((e) => e['channel'])
        .whereType<String>()
        .toSet();

    final Map<String, List<String>> streamMap = {};
    for (final s in streams) {
      if (s['status'] != null && s['status'] != 'online') continue;
      final id = s['channel'];
      final url = s['url'];
      if (id is String && url is String) {
        (streamMap[id] ??= []).add(url);
      }
    }

    final Map<String, String> logoMap = {
      for (final l in logos)
        if (l['channel'] is String && l['url'] is String)
          l['channel']: l['url']
    };

    final List<AppChannel> result = [];

    for (final ch in channels) {
      final id = ch['id'];
      if (id is! String) continue;
      if (blocked.contains(id)) continue;

      final streams = streamMap[id];
      if (streams == null || streams.isEmpty) continue;

      final logo = logoMap[id] ?? '';

      result.add(
        AppChannel(
          id: id,
          name: ch['name'] ?? '',
          country: ch['country'] ?? 'Unknown',
          categories: List<String>.from(ch['categories'] ?? const []),
          languages: List<String>.from(ch['languages'] ?? const []),
          logo: logo,
          poster: logo.isNotEmpty ? logo : null,
          streams: streams,
        ),
      );
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> _get(String file) async {
    final res = await http.get(Uri.parse('$_base/$file'));
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }
}
