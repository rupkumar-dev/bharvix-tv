class StreamRaw {
  final String channelId;
  final String? feedId;
  final String? title;
  final String url;
  final String? referrer;
  final String? userAgent;
  final String? quality;

  StreamRaw({
    required this.channelId,
    this.feedId,
    this.title,
    required this.url,
    this.referrer,
    this.userAgent,
    this.quality,
  });

  factory StreamRaw.fromJson(Map<String, dynamic> json) {
    return StreamRaw(
      channelId: json['channel'],
      feedId: json['feed'],
      title: json['title'],
      url: json['url'],
      referrer: json['referrer'],
      userAgent: json['user_agent'],
      quality: json['quality'],
    );
  }
}
