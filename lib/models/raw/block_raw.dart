class BlockRaw {
  final String channel;

  BlockRaw({required this.channel});

  factory BlockRaw.fromJson(Map<String, dynamic> json) {
    return BlockRaw(channel: json['channel']);
  }
}
