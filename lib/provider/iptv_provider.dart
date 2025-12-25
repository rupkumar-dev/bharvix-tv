// import 'package:flutter/material.dart';
// import 'package:bharvix_tv/core/iptv_repository.dart';
// import 'package:bharvix_tv/model/app_channel.dart';

// class IptvProvider extends ChangeNotifier {
//   final IptvRepository _repo = IptvRepository();

//   bool _loading = false;
//   List<AppChannel> _channels = [];

//   // ---------- Public getters ----------
//   bool get loading => _loading;
//   List<AppChannel> get channels => _channels;

//   IptvProvider() {
//     loadChannels();
//   }

//   // ---------- Load channels ----------
//   Future<void> loadChannels() async {
//     _setLoading(true);

//     try {
//       final data = await _repo.loadPlayableChannels();

//       data.sort((a, b) => a.name.compareTo(b.name));
//       _channels = data;

//       debugPrint('IPTV CHANNELS: ${_channels.length}');
//     } catch (e, s) {
//       debugPrint('IPTV ERROR: $e');
//       debugPrintStack(stackTrace: s);
//     }

//     _setLoading(false);
//   }

//   // ---------- UI helpers ----------
//   List<AppChannel> byCountry(String code) =>
//       _channels.where((c) => c.country == code).toList();

//   List<AppChannel> byCategory(String category) =>
//       _channels.where((c) => c.categories.contains(category)).toList();

//   List<AppChannel> byLanguage(String lang) =>
//       _channels.where((c) => c.languages.contains(lang)).toList();

//   // ---------- Internal ----------
//   void _setLoading(bool value) {
//     if (_loading == value) return;
//     _loading = value;
//     notifyListeners();
//   }
// }


import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:bharvix_tv/core/iptv_repository.dart';
import 'package:bharvix_tv/model/app_channel.dart';

class IptvProvider extends ChangeNotifier {
  final IptvRepository _repo;

  IptvProvider(this._repo);

  bool _loading = false;
  String? _error;

  List<AppChannel> _channels = [];

  // ---------- Public state ----------
  bool get loading => _loading;
  String? get error => _error;

  UnmodifiableListView<AppChannel> get channels =>
      UnmodifiableListView(_channels);

  // ---------- Load ----------
  Future<void> loadChannels({bool force = false}) async {
    if (_loading) return;

    _setLoading(true);
    _error = null;

    try {
      final data = await _repo.loadChannels();
      data.sort((a, b) => a.name.compareTo(b.name));
      _channels = data;
    } catch (e) {
      _error = e.toString();
      debugPrint('IPTV ERROR: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Filters ----------
  List<AppChannel> byCountry(String code) =>
      _channels.where((c) => c.country == code).toList(growable: false);

  // List<AppChannel> byCategory(String category) =>
  //     _channels.where((c) => c.categories.contains(category))
  //         .toList(growable: false);

  List<AppChannel> byLanguage(String lang) =>
      _channels.where((c) => c.languages.contains(lang))
          .toList(growable: false);

  // ---------- Internal ----------
  void _setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }
  List<AppChannel> byCategory(String category) {
  final key = category.toLowerCase();

  return _channels.where((c) {
    return c.categories.any(
      (cat) => cat.toLowerCase().contains(key),
    );
  }).toList(growable: false);
}

}
