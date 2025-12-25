// class AppChannel {
//   final String id;
//   final String name;
//   final String country;
//   final List<String> categories;
//   final List<String> languages;
//   final String logo;
//   final List<String> streams;
  

//   AppChannel({
//     required this.id,
//     required this.name,
//     required this.country,
//     required this.categories,
//     required this.languages,
//     required this.logo,
//     required this.streams,
//   });

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'country': country,
//         'categories': categories,
//         'languages': languages,
//         'logo': logo,
//         'streams': streams,
//       };

//   factory AppChannel.fromJson(Map<String, dynamic> json) {
//     return AppChannel(
//       id: json['id'],
//       name: json['name'],
//       country: json['country'],
//       categories: List<String>.from(json['categories']),
//       languages: List<String>.from(json['languages']),
//       logo: json['logo'],
//       streams: List<String>.from(json['streams']),
//     );
//   }
// }


class AppChannel {
  final String id;
  final String name;
  final String country;
  final List<String> categories;
  final List<String> languages;

  /// Small channel logo (badge / overlay)
  final String logo;

  /// Big poster / thumbnail (OTT UI)
  /// Agar null ho → logo fallback
  final String? poster;

  /// Stream URLs
  final List<String> streams;

  const AppChannel({
    required this.id,
    required this.name,
    required this.country,
    required this.categories,
    required this.languages,
    required this.logo,
    required this.streams,
    this.poster,
  });

  /// UI helper (single source of truth)
  String get posterOrLogo => poster ?? logo;

  // ---------------- JSON ----------------

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'categories': categories,
        'languages': languages,
        'logo': logo,
        'poster': poster,
        'streams': streams,
      };

  factory AppChannel.fromJson(Map<String, dynamic> json) {
    return AppChannel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? 'Unknown',
      categories:
          List<String>.from(json['categories'] ?? const <String>[]),
      languages:
          List<String>.from(json['languages'] ?? const <String>[]),
      logo: json['logo'] ?? '',
      poster: json['poster'], // optional
      streams:
          List<String>.from(json['streams'] ?? const <String>[]),
    );
  }
}

