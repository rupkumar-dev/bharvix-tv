import 'package:bharvix_tv/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:provider/provider.dart';

import '../models/app_channel.dart';
import '../provider/iptv_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final AppChannel channel;

  const VideoPlayerScreen({super.key, required this.channel});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  BetterPlayerController? _controller;
  int _index = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _playNext();
  }

  // ---------------- Stream fallback ----------------
  void _playNext() {
    if (_index >= widget.channel.streams.length) {
      setState(() => _failed = true);
      return;
    }

    _controller?.dispose();

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.channel.streams[_index++],
      videoFormat: BetterPlayerVideoFormat.hls,
      headers: widget.channel.headers,
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        controlsConfiguration:
            const BetterPlayerControlsConfiguration(enableQualities: true),
        errorBuilder: (_, __) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _playNext();
          });
          return const SizedBox.shrink();
        },
      ),
      betterPlayerDataSource: dataSource,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ---------------- Brand detection ----------------
  String? _extractBrand(String name) {
    final n = name.toLowerCase();

    const brands = [
      'star',
      'sony',
      'zee',
      'colors',
      'dd',
      'aaj tak',
      'abp',
      'news18',
      'sun',
      'asianet',
    ];

    for (final b in brands) {
      if (n.startsWith(b)) return b;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();

    final brand = _extractBrand(widget.channel.name);

    // -------- OTT-style recommendations --------
    final sameBrand = brand == null
        ? <AppChannel>[]
        : provider.channels
            .where((c) =>
                c.id != widget.channel.id &&
                c.name.toLowerCase().startsWith(brand))
            .take(10)
            .toList();

    final similar = widget.channel.categories.isNotEmpty
        ? provider
            .filterChannels(category: widget.channel.categories.first)
            .where((c) => c.id != widget.channel.id)
            .take(10)
            .toList()
        : <AppChannel>[];

    final popular = provider.popularChannels(limit: 10);

    return Scaffold(
  
      appBar: AppBar(
  
        elevation: 0,
        title: Text(widget.channel.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= VIDEO AREA =================
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller != null)
                    BetterPlayer(controller: _controller!),

                  if (_failed)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: const Text(
                        'No working stream found',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ================= INFO =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.channel.country} • ${widget.channel.categories.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // ================= RECOMMENDATIONS =================
            if (sameBrand.isNotEmpty)
              _SuggestionRow(
                title: 'More from ${brand!.toUpperCase()}',
                channels: sameBrand,
              ),

            if (similar.isNotEmpty)
              _SuggestionRow(
                title: 'Similar channels',
                channels: similar,
              ),

            _SuggestionRow(
              title: 'Popular on Live TV',
              channels: popular,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// OTT SUGGESTION ROW
// =======================================================

class _SuggestionRow extends StatelessWidget {
  final String title;
  final List<AppChannel> channels;

  const _SuggestionRow({
    required this.title,
    required this.channels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: channels.length,
              itemBuilder: (_, i) {
                final c = channels[i];
                return _SuggestionTile(channel: c);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final AppChannel channel;

  const _SuggestionTile({required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
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
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: channel.logo.isNotEmpty
                  ? Image.network(channel.logo, fit: BoxFit.contain)
                  : const Icon(Icons.tv, color: Colors.white54),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                channel.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
