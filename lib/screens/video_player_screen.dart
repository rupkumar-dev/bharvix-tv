import 'dart:async';
import 'dart:ui';
import 'package:bharvix_tv/widgets/ads_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../model/app_channel.dart';

enum PlayerHeaderState { loading, video, banner }

class VideoPlayerScreen extends StatefulWidget {
  final AppChannel channel;

  const VideoPlayerScreen({super.key, required this.channel});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;

  PlayerHeaderState _state = PlayerHeaderState.loading;

  bool _showControls = true;
  bool _isFullscreen = false;
  Timer? _hideTimer;

  // Banner data
  String _bannerTitle = '';
  String _bannerSubtitle = '';
  String? _ctaText;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }
String get _activeStream => widget.channel.streams.first;

  Future<void> _initPlayer() async {
    
    setState(() => _state = PlayerHeaderState.loading);

    _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(_activeStream),
    
    );

    try {
      await _controller!.initialize().timeout(const Duration(seconds: 7));

      _controller!.addListener(_listener);
      await _controller!.play();

      setState(() => _state = PlayerHeaderState.video);
      _startAutoHide();
    } catch (_) {
      _showBannerForReason(_activeStream);
    }
  }

  void _listener() {
    if (_controller == null) return;
    if (_controller!.value.hasError) {
      _showBannerForReason(_activeStream);
    }
  }

  // ---------------- BANNER DECISION ----------------
void _showBannerForReason(String url) {
  _controller?.removeListener(_listener);

  if (url.contains('login') || url.contains('token')) {
    _setBanner(
      title: 'Login required',
      subtitle: 'Login to watch this channel and premium content',
      cta: 'LOGIN NOW',
    );
  } else if (url.startsWith('http://')) {
    _setBanner(
      title: 'Channel blocked',
      subtitle: 'This channel is not available on your network',
    );
  } else {
    _setBanner(
      title: 'Channel unavailable',
      subtitle: 'This channel is temporarily unavailable',
    );
  }
}



  void _setBanner({
    required String title,
    required String subtitle,
    String? cta,
  }) {
    setState(() {
      _state = PlayerHeaderState.banner;
      _bannerTitle = title;
      _bannerSubtitle = subtitle;
      _ctaText = cta;
    });
  }

  // ---------------- CONTROLS ----------------

  void _startAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _hideTimer?.cancel();
      setState(() => _showControls = false);
    } else {
      setState(() => _showControls = true);
      _startAutoHide();
    }
  }

  // ---------------- FULLSCREEN ----------------

  void _enterFullscreen() {
    _isFullscreen = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() {});
  }

  void _exitFullscreen() {
    _isFullscreen = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    _exitFullscreen();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullscreen) {
          _exitFullscreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isFullscreen
            ? _buildHeader()
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBelowContent()),
                ],
              ),
      ),
    );
  }

  // ---------------- HEADER (FULL WIDTH VIDEO / BANNER) ----------------

  Widget _buildHeader() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _state == PlayerHeaderState.video
            ? _buildPlayer(key: const ValueKey('video'))
            : _state == PlayerHeaderState.banner
            ? _buildBannerSurface(key: const ValueKey('banner'))
            : const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  // ---------------- VIDEO PLAYER ----------------

  Widget _buildPlayer({required Key key}) {
    return Container(
      key: key,
      color: Colors.black,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            VideoPlayer(_controller!),

            if (_showControls)
              Center(
                child: IconButton(
                  iconSize: 64,
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                    _startAutoHide();
                  },
                ),
              ),

            if (_showControls && !_isFullscreen)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

            if (_showControls)
              Positioned(
                bottom: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _isFullscreen ? _exitFullscreen() : _enterFullscreen();
                    _startAutoHide();
                  },
                ),
              ),

            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- FULL WIDTH BANNER (PLAYER STYLE) ----------------
  Widget _buildBannerSurface({required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1️⃣ Last video frame (frozen)
          if (_controller != null && _controller!.value.isInitialized)
            VideoPlayer(_controller!),

          // 2️⃣ Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withValues(alpha: .6)),
          ),

          // 3️⃣ Ads / Promo content (foreground)
          Center(
            child: _ctaText != null
                ? AdsCarousel() // login / ads
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tv_off, color: Colors.white70, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _bannerTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _bannerSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------- BELOW PLAYER ----------------

  Widget _buildBelowContent() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          widget.channel.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white24),
      ],
    );
  }
}
