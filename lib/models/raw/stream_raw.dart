class StreamRaw {
  final String channel;
  final String url;
  final String? referrer;
  final String? userAgent;

  StreamRaw({
    required this.channel,
    required this.url,
    this.referrer,
    this.userAgent,
  });

  factory StreamRaw.fromJson(Map<String, dynamic> json) {
    final url = json['url'];
    if (url == null || url is! String || url.isEmpty) {
      throw const FormatException('Invalid stream url');
    }

    return StreamRaw(
      channel: json['channel'],
      url: url,
      referrer: json['referrer'],
      userAgent: json['user_agent'],
    );
  }
}
