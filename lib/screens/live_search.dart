import 'dart:async';
import 'package:bharvix_tv/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  bool get hasQuery => _controller.text.trim().isNotEmpty;

  void onSearch(String value) {
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

  TextSpan highlight(String text, String query) {
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
    
        elevation: 0,
        title: Text(
          hasQuery ? 'Results (${_results.length})' : 'Search',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (!hasQuery) ...[
            const FilterChips(),
            Expanded(child: _buildSuggestions(provider)),
          ] else ...[
            Expanded(child: _buildResults()),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        onChanged: onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search channels, categories, language…',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _results = []);
                  },
                )
              : null,
          filled: true,
    
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

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

  Widget _buildResults() {
    if (_results.isEmpty) {
      return const Center(
        child: Text('No results', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final c = _results[i];
        return ListTile(
          leading: c.logo.isNotEmpty
              ? Image.network(
                  c.logo,
                  width: 42,
                  height: 42,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.tv, color: Colors.white54),
                )
              : const Icon(Icons.tv, color: Colors.white54),
          title: RichText(
            text: highlight(c.name, _controller.text),
          ),
          subtitle: Text(
            '${c.country} • ${c.categories.join(', ')}',
            style: const TextStyle(color: Colors.white54),
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
}

/* ----------------------------- COMPONENTS ----------------------------- */

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
      itemBuilder: (_, i) => ChannelTile(channel: channels[i]),
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

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          _Chip('All', true),
          _Chip('Sports', false),
          _Chip('Movies', false),
          _Chip('News', false),
          _Chip('Kids', false),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  const _Chip(this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: active ? AppColors.accentColor : AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = ['Movies', 'Sports', 'News', 'Kids', 'Regional', 'Devotional'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          cats[i],
          style: const TextStyle(color: Colors.white),
        ),
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
