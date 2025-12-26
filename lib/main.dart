import 'package:bharvix_tv/Dashboard/dashboard.dart';
import 'package:bharvix_tv/core/iptv_repository.dart';
import 'package:bharvix_tv/provider/iptv_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => IptvProvider(IptvRepository())..loadChannels(),

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}
