class AppStream {
  final String url;
  final String? quality;
  final String? title;
  final String? referrer;
  final String? userAgent;

  AppStream({
    required this.url,
    this.quality,
    this.title,
    this.referrer,
    this.userAgent,
  });
}
