class FeedRaw {
  final String channel;
  final List<String> languages;

  FeedRaw({required this.channel, required this.languages});

  factory FeedRaw.fromJson(Map<String, dynamic> json) {
    return FeedRaw(
      channel: json['channel'],
      languages: List<String>.from(json['languages'] ?? const []),
    );
  }
}
