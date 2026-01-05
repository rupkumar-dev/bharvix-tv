import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class _CustomControls extends StatefulWidget {
  final Player player;
  final VoidCallback onQualityTap;
  final String qualityLabel;

  const _CustomControls({
    required this.player,
    required this.onQualityTap,
    required this.qualityLabel,
  });

  @override
  State<_CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<_CustomControls> {
  bool _visible = false;
  Timer? _hideTimer;

  void _toggle() {
    setState(() => _visible = !_visible);
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ▶️ Play / Pause (center)
          if (_visible)
            IconButton(
              iconSize: 64,
              color: Colors.white,
              icon: Icon(
                widget.player.state.playing
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                widget.player.state.playing
                    ? widget.player.pause()
                    : widget.player.play();
                _startHideTimer();
              },
            ),

          // ⚙️ Quality (top-right)
          if (_visible)
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: widget.onQualityTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hd,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          widget.qualityLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
