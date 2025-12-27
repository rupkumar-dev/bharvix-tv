class LogoRaw {
  final String channelId;
  final String? feedId;
  final List<String> tags;
  final int? width;
  final int? height;
  final String? format;
  final String url;

  LogoRaw({
    required this.channelId,
    this.feedId,
    required this.tags,
    this.width,
    this.height,
    this.format,
    required this.url,
  });

  factory LogoRaw.fromJson(Map<String, dynamic> json) {
    return LogoRaw(
      channelId: json['channel'],
      feedId: json['feed'],
      tags: List<String>.from(json['tags'] ?? const []),
      width: json['width'],
      height: json['height'],
      format: json['format'],
      url: json['url'],
    );
  }
}
