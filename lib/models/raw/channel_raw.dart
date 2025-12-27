class ChannelRaw {
  final String id;
  final String name;
  final List<String> altNames;
  final String? network;
  final List<String> owners;
  final String country;
  final List<String> categories;
  final bool isNsfw;
  final String? launched;
  final String? closed;
  final String? replacedBy;
  final String? website;

  ChannelRaw({
    required this.id,
    required this.name,
    required this.altNames,
    this.network,
    required this.owners,
    required this.country,
    required this.categories,
    required this.isNsfw,
    this.launched,
    this.closed,
    this.replacedBy,
    this.website,
  });

  factory ChannelRaw.fromJson(Map<String, dynamic> json) {
    return ChannelRaw(
      id: json['id'],
      name: json['name'],
      altNames: List<String>.from(json['alt_names'] ?? const []),
      network: json['network'],
      owners: List<String>.from(json['owners'] ?? const []),
      country: json['country'] ?? '',
      categories: List<String>.from(json['categories'] ?? const []),
      isNsfw: json['is_nsfw'] ?? false,
      launched: json['launched'],
      closed: json['closed'],
      replacedBy: json['replaced_by'],
      website: json['website'],
    );
  }
}
