import '../../model/rawModel/app_stream.dart';

class AppChannel {
  final String id;
  final String name;

  final List<String> altNames;
  final String country;
  final List<String> categories;

  final String? network;
  final List<String> owners;

  final String? language;
  final String? region;
  final List<String> timezones;

  final String? website;
  final bool isNsfw;

  final String? launched;
  final String? closed;
  final String? replacedBy;

  final String? logo;
  final List<AppStream> streams;

  final bool isBlocked;
  final String? blockReason;

  AppChannel({
    required this.id,
    required this.name,
    required this.altNames,
    required this.country,
    required this.categories,
    this.network,
    required this.owners,
    this.language,
    this.region,
    required this.timezones,
    this.website,
    required this.isNsfw,
    this.launched,
    this.closed,
    this.replacedBy,
    this.logo,
    required this.streams,
    required this.isBlocked,
    this.blockReason,
  });

  bool get isPlayable => !isBlocked && streams.isNotEmpty;
}
