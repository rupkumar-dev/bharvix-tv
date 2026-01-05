import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';


class UpdateService {
  static const String _versionUrl =
          'https://raw.githubusercontent.com/rupkumar-dev/bharvix-tv/main/version.json';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 1️⃣ current app version
      final info = await PackageInfo.fromPlatform();
      final int currentVersion = int.parse(info.buildNumber);

      // 2️⃣ server version
      final res = await http.get(Uri.parse(_versionUrl));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      final int serverVersion = data['versionCode'];
      final String apkUrl = data['apkUrl'];

      // 3️⃣ no update → do nothing
      if (serverVersion <= currentVersion) return;
      if (!context.mounted) return;

      // 4️⃣ FORCE UPDATE DIALOG
      await showDialog(
        context: context,
        barrierDismissible: false, // ❌ outside tap disabled
        builder: (_) => WillPopScope(
          onWillPop: () async => false, // ❌ back button disabled
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
              'A new version is available.\nYou must update to continue.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await _openUpdateUrl(apkUrl);

                  // 5️⃣ app ko background / close
                  await Future.delayed(const Duration(milliseconds: 400));
                  SystemNavigator.pop();
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      // intentionally silent
    }
  }

  static Future<void> _openUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
