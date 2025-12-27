import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bharvix_tv/core/app_colors.dart';
import '../models/app_channel.dart';
import '../provider/iptv_provider.dart';
import 'video_player.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<AppChannel> _results = [];

  bool get _isSearching => _controller.text.trim().isNotEmpty;

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final provider = context.read<IptvProvider>();
      setState(() {
        _results = provider.search(value);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  TextSpan _highlight(String text, String query) {
    if (query.isEmpty) return TextSpan(text: text);

    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final index = lower.indexOf(q);

    if (index < 0) return TextSpan(text: text);

    return TextSpan(children: [
      TextSpan(text: text.substring(0, index)),
      TextSpan(
        text: text.substring(index, index + q.length),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.accentColor,
        ),
      ),
      TextSpan(text: text.substring(index + q.length)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSearching ? 'Results (${_results.length})' : 'Search',
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildSuggestions(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search channels, language, category…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _results.clear());
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------------- SEARCH RESULTS ----------------

  Widget _buildSearchResults() {
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final c = _results[i];
        return ListTile(
          leading: c.logo.isNotEmpty
              ? Image.network(c.logo, width: 42)
              : const Icon(Icons.tv),
          title: RichText(
            text: _highlight(c.name, _controller.text),
          ),
          subtitle: Text(
            '${c.country} • ${c.categories.join(', ')}',
            maxLines: 1,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(channel: c),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- SUGGESTIONS ----------------

  Widget _buildSuggestions(IptvProvider provider) {
    final popular = provider.popularChannels(limit: 12);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Popular'),
          const SizedBox(height: 12),
          ResultsGrid(channels: popular),
          const SizedBox(height: 24),
          const SectionTitle('Categories'),
          const SizedBox(height: 12),
          const CategoryGrid(),
        ],
      ),
    );
  }
}



/* ============================= COMPONENTS ============================= */
class ResultsGrid extends StatelessWidget {
  final List<AppChannel> channels;

  const ResultsGrid({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: channels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, i) {
        final c = channels[i];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Filter Chips (FUNCTIONAL) ----------------

class FilterChips extends StatelessWidget {
  final String? active;
  final ValueChanged<String?> onSelect;

  const FilterChips({super.key, required this.active, required this.onSelect});

  static const _cats = ['sports', 'movies', 'news', 'kids'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'All',
            active: active == null,
            onTap: () => onSelect(null),
          ),
          ..._cats.map(
            (c) => _Chip(
              label: c.toUpperCase(),
              active: active == c,
              onTap: () => onSelect(c),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.accentColor : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const categories = [
    ('movies', 'Movies'),
    ('sports', 'Sports'),
    ('news', 'News'),
    ('kids', 'Kids'),
    ('regional', 'Regional'),
    ('devotional', 'Devotional'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final key = categories[i].$1;
        final label = categories[i].$2;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryChannelsScreen(
                  categoryKey: key,
                  title: label,
                ),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
class CategoryChannelsScreen extends StatelessWidget {
  final String categoryKey;
  final String title;

  const CategoryChannelsScreen({
    super.key,
    required this.categoryKey,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();
    final channels = provider.filterChannels(category: categoryKey);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: channels.isEmpty
          ? const Center(
              child: Text(
                'No channels available',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: channels.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, i) {
                final c = channels[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VideoPlayerScreen(channel: c),
                      ),
                    );
                  },
                  child: ChannelTile(channel: c),
                );
              },
            ),
    );
  }
}



class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
