import 'package:bharvix_tv/Dashboard/dashboard.dart';
import 'package:bharvix_tv/core/iptv_repository.dart';
import 'package:bharvix_tv/provider/iptv_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => IptvProvider(IptvRepository())..load(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}
