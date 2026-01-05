import 'package:bharvix_tv/core/app_colors.dart';
import 'package:bharvix_tv/screens/VideoPlayer/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_channel.dart';
import 'provider/iptv_provider.dart';

// ---------------- TAB CONFIG ----------------
const mainTabs = [
  'India Hindi',
  'Popular',
  'India',
  'Sports',
  'News',
  'Movies',

  'All',
];

const indiaHindiTabs = ['All', 'Sports', 'News', 'Movies'];

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2>
    with SingleTickerProviderStateMixin {
  late final TabController _mainTab;

  @override
  void initState() {
    super.initState();
    _mainTab = TabController(length: mainTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _mainTab.dispose();
    super.dispose();
  }

  String? _categoryKey(String tab) {
    switch (tab) {
      case 'Sports':
        return 'sports';
      case 'News':
        return 'news';
      case 'Movies':
        return 'movies';
      default:
        return null;
    }
  }

  String _tabTitle(String tab, IptvProvider p) {
    switch (tab) {
      case 'All':
        return 'All (${p.channels.length})';
      case 'Sports':
        return 'Sports (${p.filterChannels(category: "sports").length})';
      case 'News':
        return 'News (${p.filterChannels(category: "news").length})';
      case 'Movies':
        return 'Movies (${p.filterChannels(category: "movies").length})';
      case 'India':
        return 'India (${p.filterChannels(country: "IN").length})';
      case 'India Hindi':
        return 'India Hindi (${p.filterChannels(country: "IN", language: "hin").length})';
      case 'Popular':
        return 'Popular (${p.popularChannels().length})';
      default:
        return tab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();

    if (provider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Live TV', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _mainTab,
          isScrollable: true,

          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: mainTabs.map((t) => Tab(text: _tabTitle(t, provider))).toList(),
        ),
      ),
      body: TabBarView(
        controller: _mainTab,
        children: mainTabs.map((tab) {
          if (tab == 'India Hindi') {
            return _IndiaHindiSection(provider: provider);
          }

          if (tab == 'India') {
            return ChannelGrid(list: provider.filterChannels(country: "IN"));
          }

          if (tab == 'Popular') {
            return ChannelGrid(list: provider.popularChannels());
          }

          final key = _categoryKey(tab);
          return ChannelGrid(
            list: key == null
                ? provider.channels.toList()
                : provider.filterChannels(category: key),
          );
        }).toList(),
      ),
    );
  }
}

// =======================================================
// INDIA HINDI SECTION
// =======================================================

class _IndiaHindiSection extends StatefulWidget {
  final IptvProvider provider;
  const _IndiaHindiSection({required this.provider});

  @override
  State<_IndiaHindiSection> createState() => _IndiaHindiSectionState();
}

class _IndiaHindiSectionState extends State<_IndiaHindiSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

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

  String? _key(String tab) {
    switch (tab) {
      case 'Sports':
        return 'sports';
      case 'News':
        return 'news';
      case 'Movies':
        return 'movies';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,

          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: indiaHindiTabs.map((t) => Tab(text: t)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: indiaHindiTabs.map((tab) {
              final key = _key(tab);
              return ChannelGrid(
                list: key == null
                    ? widget.provider.filterChannels(
                        country: "IN",
                        language: "hin",
                      )
                    : widget.provider.filterChannels(
                        country: "IN",
                        language: "hin",
                        category: key,
                      ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// =======================================================
// CHANNEL GRID (same as Search style)
// =======================================================

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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.78,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VideoPlayerScreen(channel: c)),
            );
          },
          child: ChannelTile(channel: c),
        );
      },
    );
  }
}

class ChannelTile extends StatelessWidget {
  final AppChannel channel;
  const ChannelTile({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: channel.logo.isNotEmpty
                  ? Image.network(channel.logo, fit: BoxFit.contain)
                  : const Icon(Icons.tv, color: Colors.white54),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withValues(alpha: 0.65),
                child: Text(
                  channel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
