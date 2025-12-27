class GuideRaw {
  final String channelId;
  final String site;
  final String siteId;
  final String? lang;

  GuideRaw({
    required this.channelId,
    required this.site,
    required this.siteId,
    this.lang,
  });

  factory GuideRaw.fromJson(Map<String, dynamic> json) {
    return GuideRaw(
      channelId: json['channel'],
      site: json['site'],
      siteId: json['site_id'],
      lang: json['lang'],
    );
  }
}
