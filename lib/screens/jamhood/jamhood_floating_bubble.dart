// lib/screens/jamhood/jamhood_floating_bubble.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/jamhood_model.dart';

class JamHoodFloatingBubble extends StatefulWidget {
  final JamHoodPlayer player;
  final int index;
  final bool isHost;
  final bool isMe;

  const JamHoodFloatingBubble({
    super.key,
    required this.player,
    required this.index,
    required this.isHost,
    this.isMe = false,
  });

  @override
  State<JamHoodFloatingBubble> createState() => _JamHoodFloatingBubbleState();
}

class _JamHoodFloatingBubbleState extends State<JamHoodFloatingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _verticalAmplitude;
  late final double _phaseOffset;
  late final double _rotationAmplitude;

  static const List<IconData> _avatarIcons = [
    Icons.face_rounded,
    Icons.rocket_launch_rounded,
    Icons.star_rounded,
    Icons.sports_esports_rounded,
    Icons.auto_awesome_rounded,
    Icons.pets_rounded,
    Icons.palette_rounded,
    Icons.emoji_events_rounded,
    Icons.bolt_rounded,
    Icons.music_note_rounded,
    Icons.favorite_rounded,
    Icons.lightbulb_rounded,
  ];

  static const List<Color> _bubbleColors = [
    Color(0xFFE21B3C), // Red
    Color(0xFF1368CE), // Blue
    Color(0xFFD89E00), // Amber
    Color(0xFF26890C), // Green
    Color(0xFF8E24AA), // Purple
    Color(0xFFE65100), // Deep Orange
    Color(0xFF3949AB), // Indigo
    Color(0xFF00ACC1), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    // Unique deterministic duration and phase for each bubble so they bob independently
    final int durationMs = 2200 + (widget.index % 6) * 320;
    _phaseOffset = (widget.index * 0.47) % 1.0;
    _verticalAmplitude = 5.0 + (widget.index % 4) * 2.0; // 5 to 11px bobbing
    _rotationAmplitude = 0.02 + (widget.index % 3) * 0.012; // ~1.1 to 1.8 degree tilt

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _bubbleColors[widget.index % _bubbleColors.length];
    final IconData icon = _avatarIcons[widget.index % _avatarIcons.length];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = (_controller.value + _phaseOffset) % 1.0;
        final double dy = sin(progress * 2 * pi) * _verticalAmplitude;
        final double rot = sin(progress * 2 * pi) * _rotationAmplitude;
        final double scale = 1.0 + (cos(progress * 2 * pi) * 0.02);

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(
            angle: rot,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: widget.isHost
                ? const Color(0xFFFFD700)
                : (widget.isMe ? const Color(0xFF00E676) : Colors.white),
            width: (widget.isHost || widget.isMe) ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.isHost ? Icons.workspace_premium_rounded : icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.player.nickname,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1035),
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
            if (widget.isHost) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Color(0xFF1E1035), size: 11),
                    SizedBox(width: 2),
                    Text(
                      'HOST',
                      style: TextStyle(
                        color: Color(0xFF1E1035),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (widget.isMe) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'KAMU',
                  style: TextStyle(
                    color: Color(0xFF1E1035),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
