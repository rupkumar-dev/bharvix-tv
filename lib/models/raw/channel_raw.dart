class ChannelRaw {
  final String id;
  final String name;
  final String country;
  final List<String> categories;

  ChannelRaw({
    required this.id,
    required this.name,
    required this.country,
    required this.categories,
  });

  factory ChannelRaw.fromJson(Map<String, dynamic> json) {
    return ChannelRaw(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      categories: List<String>.from(json['categories'] ?? const []),
    );
  }
}
