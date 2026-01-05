
// ─────────────────────────────────────────────────────────────
// 🎬 Player Surface with Custom Controls
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerSurface extends StatelessWidget {
  final VideoController controller;
  final bool hasVideo;
  final bool exhausted;
  final List<VideoTrack> videoTracks;
  final VideoTrack? selectedTrack;
  final bool isAutoQuality;
  final VoidCallback onQualityTap;

  const PlayerSurface({super.key, 
    required this.controller,
    required this.hasVideo,
    required this.exhausted,
    required this.videoTracks,
    required this.selectedTrack,
    required this.isAutoQuality,
    required this.onQualityTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hasVideo) {
      return 
      
      
      Video(
        controller: controller,
        controls: (state) => _CustomControls(
          state: state,
          videoTracks: videoTracks,
          selectedTrack: selectedTrack,
          isAutoQuality: isAutoQuality,
          onQualityTap: onQualityTap,
        ),
      );
    }

    if (exhausted) {
      return _message('Stream not supported on this device');
    }

    return _message('Loading stream…');
  }

  Widget _message(String text) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🎮 Custom Video Controls with Quality Button
// ─────────────────────────────────────────────────────────────

class _CustomControls extends StatelessWidget {
  final VideoState state;
  final List<VideoTrack> videoTracks;
  final VideoTrack? selectedTrack;
  final bool isAutoQuality;
  final VoidCallback onQualityTap;

  const _CustomControls({
    required this.state,
    required this.videoTracks,
    required this.selectedTrack,
    required this.isAutoQuality,
    required this.onQualityTap,
  });

  String get _qualityLabel {
    if (isAutoQuality) return 'Auto';
    if (selectedTrack != null) {
      final height = selectedTrack!.h;
      if (height != null) return '${height}p';
    }
    return 'Auto';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Default controls
        AdaptiveVideoControls(state),

        // Quality button overlay (top-right)
     if ( videoTracks.isNotEmpty )
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: onQualityTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hd, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _qualityLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
