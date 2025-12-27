class BlockRaw {
  final String channelId;
  final String? reason;
  final String? ref;

  BlockRaw({
    required this.channelId,
    this.reason,
    this.ref,
  });

  factory BlockRaw.fromJson(Map<String, dynamic> json) {
    return BlockRaw(
      channelId: json['channel'],
      reason: json['reason'],
      ref: json['ref'],
    );
  }
}
