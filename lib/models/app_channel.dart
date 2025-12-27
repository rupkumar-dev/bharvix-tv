class AppChannel {
  final String id;
  final String name;
  final String country;
  final List<String> categories;
  final List<String> languages;

  /// HTTP headers required for playback (optional)
  final Map<String, String>? headers;

  /// Small channel logo
  final String logo;

  /// Big poster / thumbnail
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
    this.headers,
  });

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
        'headers': headers,
      };

  factory AppChannel.fromJson(Map<String, dynamic> json) {
    return AppChannel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      categories:
          List<String>.from(json['categories'] ?? const <String>[]),
      languages:
          List<String>.from(json['languages'] ?? const <String>[]),
      logo: json['logo'] ?? '',
      poster: json['poster'],
      streams:
          List<String>.from(json['streams'] ?? const <String>[]),
      headers: json['headers'] == null
          ? null
          : Map<String, String>.from(json['headers']),
    );
  }
}

