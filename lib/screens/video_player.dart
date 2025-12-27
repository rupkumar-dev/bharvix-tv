
import 'package:bharvix_tv/models/app_channel.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';



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

  void _playNext() {
    if (_index >= widget.channel.streams.length) {
      setState(() => _failed = true);
      return;
    }

 

    _controller?.dispose();

    // -------- Build headers dynamically --------

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
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableQualities: true,
        ),
        errorBuilder: (_, _) {
          // Try next stream on failure
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _playNext();
          });

          return const Center(
            child: Text(
              'Trying another stream…',
              style: TextStyle(color: Colors.white70),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _failed
            ? const Center(
                child: Text(
                  'No working stream found',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                  controller: _controller!,
                ),
              ),
      ),
    );
  }
}
