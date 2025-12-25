import 'package:bharvix_tv/core/iptv_repository.dart';
import 'package:bharvix_tv/home.dart';
import 'package:bharvix_tv/provider/iptv_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
    create: (_) => IptvProvider(IptvRepository())..loadChannels(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

