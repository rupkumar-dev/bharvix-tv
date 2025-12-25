// import 'package:bharvix_tv/screens/video_player_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';
// import '../provider/iptv_provider.dart';
// import '../model/app_channel.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   final tabs = const ['All', 'Sports', 'News', 'Movies'];
//   late TabController _tab;

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: tabs.length, vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<IptvProvider>();

//     if (provider.loading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Live TV'),
//         backgroundColor: Colors.black,
//         bottom: TabBar(
//           controller: _tab,
//           isScrollable: true,
//           tabs: tabs.map((e) => Tab(text: e)).toList(),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tab,
//         children: tabs.map((tab) {
//           final list = tab == 'All'
//               ? provider.channels
//               : provider.channels.where((c) =>
//                   c.categories.any((e) =>
//                       e.toLowerCase().contains(tab.toLowerCase()))).toList();

//           return GridView.builder(
//             padding: const EdgeInsets.all(12),
//             gridDelegate:
//                 const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               childAspectRatio: 0.75,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//             ),
//             itemCount: list.length,
//             itemBuilder: (_, i) {
//               final c = list[i];
//               return InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => VideoPlayerScreen(channel: c),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade900,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.all(8),
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: Image.network(
//                           c.logo,
//                           fit: BoxFit.contain,
//                           errorBuilder: (_, __, ___) =>
//                               const Icon(Icons.tv, color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         c.name,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

import 'package:bharvix_tv/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/iptv_provider.dart';
import '../model/app_channel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();

    if (provider.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.channels.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: Text(
            'No content available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          _HeroSliver(channel: provider.channels.first),

          _SliverSection(
            title: 'Trending Now',
            channels: provider.channels.take(10).toList(),
          ),
          _SliverSection(
            title: 'Latest News',
            channels: provider.byCategory('news'),
          ),
          _SliverSection(
            title: 'Sports Live',
            channels: provider.byCategory('sports'),
          ),
        ],
      ),
    );
  }
}

//
// ================= HERO =================
//

class _HeroSliver extends StatelessWidget {
  final AppChannel channel;

  const _HeroSliver({required this.channel});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(channel: channel),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                channel.poster ?? channel.logo,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: Colors.black54),
              ),

              // Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // LIVE badge
              Positioned(
                top: 16,
                left: 16,
                child: _LiveBadge(),
              ),

              // Channel logo
              Positioned(
                bottom: 24,
                left: 16,
                child: _LogoBadge(logoUrl: channel.logo),
              ),

              // Title
              Positioned(
                left: 16,
                bottom: 24,
                right: 16,
                child: Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    channel.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ================= SECTION =================
//

class _SliverSection extends StatelessWidget {
  final String title;
  final List<AppChannel> channels;

  const _SliverSection({
    required this.title,
    required this.channels,
  });

  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) return const SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: channels.length,
              itemBuilder: (_, i) {
                return _Poster(channel: channels[i]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

//
// ================= POSTER CARD =================
//

class _Poster extends StatelessWidget {
  final AppChannel channel;

  const _Poster({required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(channel: channel),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(channel.poster ?? channel.logo),
            fit: BoxFit.cover,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // LIVE badge
            const Positioned(
              top: 8,
              left: 8,
              child: _LiveBadge(),
            ),

            // Logo badge
            Positioned(
              bottom: 8,
              left: 8,
              child: _LogoBadge(logoUrl: channel.logo),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ================= REUSABLE WIDGETS =================
//

class _LogoBadge extends StatelessWidget {
  final String logoUrl;

  const _LogoBadge({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        logoUrl,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.tv, size: 20, color: Colors.white),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
