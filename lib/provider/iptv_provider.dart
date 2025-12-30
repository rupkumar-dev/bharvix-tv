import 'package:bharvix_tv/core/iptv_repository.dart';
import '../models/app_channel.dart';
import 'dart:collection';
import 'package:flutter/foundation.dart';

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
