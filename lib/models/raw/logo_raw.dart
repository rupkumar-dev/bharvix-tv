class LogoRaw {
  final String channel;
  final String url;

  LogoRaw({required this.channel, required this.url});

  factory LogoRaw.fromJson(Map<String, dynamic> json) {
    return LogoRaw(
      channel: json['channel'],
      url: json['url'] ?? '',
    );
  }
}
