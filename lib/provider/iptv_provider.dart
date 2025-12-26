

import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../core/iptv_repository.dart';
import '../model/app_channel.dart';


class IptvProvider extends ChangeNotifier {
  final IptvRepository _repo;

  IptvProvider(this._repo);

  // ---------------- Internal state ----------------
  bool _loading = false;
  String? _error;

  List<AppChannel> _channels = [];

  late final List<AppChannel> _indiaHindiCache;
  late final List<AppChannel> _popularCache;

  // ---------------- Public state ----------------
  bool get loading => _loading;
  String? get error => _error;

  UnmodifiableListView<AppChannel> get channels =>
      UnmodifiableListView(_channels);

  // ---------------- Load ----------------
  Future<void> loadChannels() async {
    if (_loading) return;

    _setLoading(true);
    _error = null;

    try {
      final data = await _repo.loadChannels()
        ..sort((a, b) => a.name.compareTo(b.name));

      _channels = data;
      _buildCaches();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- Cache builder ----------------
  void _buildCaches() {
    _indiaHindiCache = _channels.where(_isIndiaHindi).toList(growable: false);
    _popularCache = _channels.where(_isPopular).toList(growable: false);
  }

  // ---------------- Filters ----------------

  /// All / Sports / News / Movies
  List<AppChannel> byCategory(String category) {
    if (category == 'All') {
      return List.unmodifiable(_channels);
    }

    final key = category.toLowerCase();
    return _channels.where((c) => _hasCategory(c, key))
        .toList(growable: false);
  }

  /// India (all languages)
  List<AppChannel> indiaByCategory(String category) {
    if (category == 'All') {
      return _channels.where(_isIndia).toList(growable: false);
    }

    final key = category.toLowerCase();
    return _channels.where(
      (c) => _isIndia(c) && _hasCategory(c, key),
    ).toList(growable: false);
  }

  /// India Hindi
  List<AppChannel> indiaHindiByCategory(String category) {
    if (category == 'All') {
      return List.unmodifiable(_indiaHindiCache);
    }

    final key = category.toLowerCase();
    return _indiaHindiCache.where(
      (c) => _hasCategory(c, key),
    ).toList(growable: false);
  }

  /// Popular
  List<AppChannel> popularChannels() =>
      List.unmodifiable(_popularCache);

  // ---------------- Helpers ----------------
  bool _hasCategory(AppChannel c, String key) {
    return c.categories.any(
      (cat) => cat.toLowerCase().contains(key),
    );
  }

  bool _isIndia(AppChannel c) {
    final country = c.country.toLowerCase();
    return country.contains('india') ||
        country.contains('ind') ||
        country == 'in';
  }

  bool _isIndiaHindi(AppChannel c) {
    final isIndia = _isIndia(c);

    final isHindi =
        c.languages.any((l) => l.toLowerCase().contains('hin')) ||
        c.name.toLowerCase().contains('zee') ||
        c.name.toLowerCase().contains('star') ||
        c.name.toLowerCase().contains('sony');

    return isIndia && isHindi;
  }

  bool _isPopular(AppChannel c) {
    final name = c.name.toLowerCase();
    return name.contains('star') ||
        name.contains('zee') ||
        name.contains('sony') ||
        name.contains('colors');
  }

  // ---------------- Internal ----------------
  void _setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }
}
