import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../models/app_channel.dart';
import 'widgets/player_surface.dart';
import 'widgets/quality_bottom_sheet.dart';

class VideoPlayerScreen extends StatefulWidget {
  final AppChannel channel;
  const VideoPlayerScreen({super.key, required this.channel});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _video;

  StreamSubscription? _errorSub;
  StreamSubscription? _videoSub;
  StreamSubscription? _tracksSub;

  int _streamIndex = 0;
  bool _hasVideo = false;
  bool _exhausted = false;
  bool _opening = false;

  // Quality selection
  List<VideoTrack> _videoTracks = [];
  VideoTrack? _selectedTrack;
  bool _isAutoQuality = true;

  @override
  void initState() {
    super.initState();

    _player = Player(
      configuration: const PlayerConfiguration(
        title: 'Live TV',
      
      ),
    );

    _video = VideoController(_player);

    _errorSub = _player.stream.error.listen((_) {
      if (!_hasVideo) {
        _openNext();
      }
    });

    _videoSub = _player.stream.videoParams.listen((params) {
      if (mounted) {
        setState(() {
          _hasVideo = true;
          _exhausted = false;
        });
      }
    });
    // 🎬 Listen for available tracks (qualities)
    _tracksSub = _player.stream.tracks.listen((tracks) {
      if (!mounted) return;

      final videos = tracks.video.where((t) => t.id != 'no').toList();
      if (videos.isEmpty) return;

      setState(() {
        _videoTracks = videos;
      });
    });

    _setQuality(null);
    _openNext();
  }

  Future<void> _openNext() async {
    if (_opening) return;
    _opening = true;
    _hasVideo = false;

    if (_streamIndex >= widget.channel.streams.length) {
      if (mounted) {
        setState(() => _exhausted = true);
      }
      _opening = false;
      return;
    }

    final url = widget.channel.streams[_streamIndex++];
    final headers = widget.channel.headers ?? const {};

    try {
      await _player.open(
        Media(url, httpHeaders: headers, start: const Duration(seconds: 1)),
        play: true,
      );
    } catch (_) {
      _opening = false;
      _openNext();
      return;
    }

    _opening = false;
  }

  Future<void> _setQuality(VideoTrack? track) async {
    if (track == null) {
      _isAutoQuality = true;
      _selectedTrack = null;

      if (_videoTracks.isNotEmpty) {
        final lowest = _videoTracks.reduce(
          (a, b) => (a.h ?? 9999) < (b.h ?? 9999) ? a : b,
        );
        await _player.setVideoTrack(lowest);
      }
    } else {
      _isAutoQuality = false;
      _selectedTrack = track;
      await _player.setVideoTrack(track);
    }

    if (mounted) setState(() {});
  }

  // 📊 Show quality selection bottom sheet
  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => QualityBottomSheet(
        tracks: _videoTracks,
        selectedTrack: _selectedTrack,
        isAuto: _isAutoQuality,
        onSelect: (track) {
          Navigator.pop(context);
          _setQuality(track);
        },
      ),
    );
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _videoSub?.cancel();
    _tracksSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: [
          // Quality button in app bar (optional)
          if (_hasVideo && _videoTracks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showQualitySelector,
            ),
        ],
      ),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: PlayerSurface(
          controller: _video,
          hasVideo: _hasVideo,
          exhausted: _exhausted,
          videoTracks: _videoTracks,
          selectedTrack: _selectedTrack,
          isAutoQuality: _isAutoQuality,
          onQualityTap: _showQualitySelector,
          
        ),
      ),
    );
  }
}
