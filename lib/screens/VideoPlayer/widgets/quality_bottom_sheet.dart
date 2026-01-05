
// ─────────────────────────────────────────────────────────────
// 📊 Quality Selection Bottom Sheet (YouTube-like)
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class QualityBottomSheet extends StatelessWidget {
  final List<VideoTrack> tracks;
  final VideoTrack? selectedTrack;
  final bool isAuto;
  final Function(VideoTrack?) onSelect;

  const QualityBottomSheet({super.key, 
    required this.tracks,
    required this.selectedTrack,
    required this.isAuto,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Sort tracks by height (highest first)
    final sortedTracks = List<VideoTrack>.from(tracks)
      ..sort((a, b) => (b.h ?? 0).compareTo(a.h ?? 0));

    // Remove duplicates based on height
    final uniqueTracks = <int, VideoTrack>{};
    for (final track in sortedTracks) {
      if (track.h != null && !uniqueTracks.containsKey(track.h)) {
        uniqueTracks[track.h!] = track;
      }
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Auto option
          _QualityTile(
            title: 'Auto',
            subtitle: 'Recommended',
            isSelected: isAuto,
            icon: Icons.auto_awesome,
            onTap: () => onSelect(null),
          ),

          // Quality options
          ...uniqueTracks.entries.map((entry) {
            final track = entry.value;
            final height = entry.key;
            final isSelected = !isAuto && selectedTrack?.h == height;

            return _QualityTile(
              title: '${height}p',
              subtitle: _getQualityLabel(height),
              isSelected: isSelected,
              onTap: () => onSelect(track),
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getQualityLabel(int height) {
    if (height >= 2160) return '4K Ultra HD';
    if (height >= 1440) return '2K QHD';
    if (height >= 1080) return 'Full HD';
    if (height >= 720) return 'HD';
    if (height >= 480) return 'SD';
    if (height >= 360) return 'Low';
    return 'Very Low';
  }
}

// ─────────────────────────────────────────────────────────────
// 🎯 Quality Tile Widget
// ─────────────────────────────────────────────────────────────

class _QualityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const _QualityTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: isSelected ? Colors.blue : Colors.white70)
          : _buildQualityBadge(),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildQualityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
