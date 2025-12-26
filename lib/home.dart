import 'package:bharvix_tv/model/app_channel.dart';
import 'package:bharvix_tv/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/iptv_provider.dart';


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


const mainTabs = [
  'All',
  'Sports',
  'News',
  'Movies',
  'India Hindi',
  'Popular',
  'India',
];

const indiaTabs = ['All', 'Sports', 'News', 'Movies'];
const indiaHindiTabs = ['All', 'Sports', 'News', 'Movies'];


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: mainTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();

    if (provider.loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Live TV'),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: mainTabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: mainTabs.map((tab) {
          if (tab == 'India Hindi') {
            return IndiaHindiTab(provider: provider);
          }

          if (tab == 'India') {
            return IndiaTab(provider: provider);
          }

          if (tab == 'Popular') {
            return ChannelGrid(
              list: provider.popularChannels(),
            );
          }

          return ChannelGrid(
            list: provider.byCategory(tab),
          );
        }).toList(),
      ),
    );
  }
}

class IndiaHindiTab extends StatefulWidget {
  final IptvProvider provider;
  const IndiaHindiTab({super.key, required this.provider});

  @override
  State<IndiaHindiTab> createState() => _IndiaHindiTabState();
}

class _IndiaHindiTabState extends State<IndiaHindiTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: indiaHindiTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: indiaHindiTabs.map((e) => Tab(text: e)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: indiaHindiTabs.map((tab) {
              return ChannelGrid(
                list: widget.provider.indiaHindiByCategory(tab),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ChannelGrid extends StatelessWidget {
  final List<AppChannel> list;
  const ChannelGrid({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No channels available',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(channel: c),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    c.logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.tv, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class IndiaTab extends StatefulWidget {
  final IptvProvider provider;
  const IndiaTab({super.key, required this.provider});

  @override
  State<IndiaTab> createState() => _IndiaTabState();
}

class _IndiaTabState extends State<IndiaTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: indiaTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: indiaTabs.map((e) => Tab(text: e)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: indiaTabs.map((tab) {
              return ChannelGrid(
                list: widget.provider.indiaByCategory(tab),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}


