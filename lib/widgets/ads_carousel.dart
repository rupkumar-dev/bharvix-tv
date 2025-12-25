import 'package:flutter/material.dart';

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  final _page = PageController();
  int _index = 0;

  final ads = const [
    {
      'title': 'Login to Watch Premium TV',
      'subtitle': 'Get access to live sports & movies',
      'cta': 'LOGIN',
    },
    {
      'title': 'Upgrade Your Plan',
      'subtitle': 'Enjoy ad-free streaming',
      'cta': 'UPGRADE',
    },
    {
      'title': 'Watch Anywhere',
      'subtitle': 'Mobile • TV • Web',
      'cta': 'LEARN MORE',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      _index = (_index + 1) % ads.length;
      _page.animateToPage(
        _index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _page,
      itemCount: ads.length,
      itemBuilder: (_, i) {
        final ad = ads[i];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ad['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              ad['subtitle']!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text(ad['cta']!),
            ),
          ],
        );
      },
    );
  }
}
