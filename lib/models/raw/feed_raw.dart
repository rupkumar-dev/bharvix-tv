class FeedRaw {
  final String channelId;
  final String id;
  final String name;
  final List<String> altNames;
  final bool isMain;
  final List<String> broadcastArea;
  final List<String> timezones;
  final List<String> languages;
  final String? format;

  FeedRaw({
    required this.channelId,
    required this.id,
    required this.name,
    required this.altNames,
    required this.isMain,
    required this.broadcastArea,
    required this.timezones,
    required this.languages,
    this.format,
  });

  factory FeedRaw.fromJson(Map<String, dynamic> json) {
    return FeedRaw(
      channelId: json['channel'],
      id: json['id'],
      name: json['name'],
      altNames: List<String>.from(json['alt_names'] ?? const []),
      isMain: json['is_main'] ?? false,
      broadcastArea: List<String>.from(json['broadcast_area'] ?? const []),
      timezones: List<String>.from(json['timezones'] ?? const []),
      languages: List<String>.from(json['languages'] ?? const []),
      format: json['format'],
    );
  }
}
