// lib/screens/jamhood/jamhood_leaderboard_sheet.dart
import 'package:flutter/material.dart';
import '../../models/jamhood_model.dart';

void showJamHoodLeaderboardModal(
  BuildContext context, {
  required List<JamHoodPlayer> players,
  String? currentUserId,
  String? hostPlayerId,
  bool isReveal = false,
}) {
  final sorted = List<JamHoodPlayer>.from(players)
    ..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.nickname.compareTo(b.nickname);
    });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(modalContext).size.height * 0.85,
          maxWidth: 680,
        ),
        margin: EdgeInsets.only(
          left: MediaQuery.of(modalContext).size.width > 700
              ? (MediaQuery.of(modalContext).size.width - 680) / 2
              : 0,
          right: MediaQuery.of(modalContext).size.width > 700
              ? (MediaQuery.of(modalContext).size.width - 680) / 2
              : 0,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1035),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 25,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Papan Peringkat JamHood',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${sorted.length} Peserta Bertanding',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),

              // Player List
              Flexible(
                child: sorted.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Belum ada pemain.',
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shrinkWrap: true,
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          final p = sorted[index];
                          final bool isMe = currentUserId != null && p.id == currentUserId;
                          final bool isHost = hostPlayerId != null && p.id == hostPlayerId;

                          Color rankColor = Colors.white70;
                          String medal = '#${index + 1}';
                          if (index == 0) {
                            rankColor = const Color(0xFFFFD700);
                            medal = '🥇 1';
                          } else if (index == 1) {
                            rankColor = const Color(0xFFC0C0C0);
                            medal = '🥈 2';
                          } else if (index == 2) {
                            rankColor = const Color(0xFFCD7F32);
                            medal = '🥉 3';
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFF46178F).withValues(alpha: 0.55)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMe
                                    ? const Color(0xFFFFD700)
                                    : (index == 0
                                        ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                                        : Colors.white10),
                                width: isMe ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Rank
                                SizedBox(
                                  width: 52,
                                  child: Text(
                                    medal,
                                    style: TextStyle(
                                      color: rankColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),

                                // Avatar
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isMe
                                      ? const Color(0xFFFFD700)
                                      : (isHost ? const Color(0xFF00C853) : const Color(0xFF46178F)),
                                  child: Icon(
                                    isHost ? Icons.school : Icons.person,
                                    size: 20,
                                    color: isMe ? const Color(0xFF1E1035) : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Nickname + Badges
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              p.nickname,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: isMe ? FontWeight.w900 : FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFD700),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Kamu',
                                                style: TextStyle(
                                                  color: Color(0xFF1E1035),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (isHost && !isMe) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00C853),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Host',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (p.streak > 1) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '🔥 ${p.streak}x Beruntun',
                                          style: const TextStyle(
                                            color: Colors.orangeAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Reveal status or Points
                                if (isReveal && p.hasAnswered) ...[
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: p.isLastAnswerCorrect
                                          ? const Color(0xFF00C853).withValues(alpha: 0.25)
                                          : const Color(0xFFE53935).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p.isLastAnswerCorrect
                                          ? '+${p.lastPointsEarned}'
                                          : '✗ 0',
                                      style: TextStyle(
                                        color: p.isLastAnswerCorrect
                                            ? const Color(0xFF69F0AE)
                                            : const Color(0xFFFF8A80),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],

                                // Total Score
                                Text(
                                  '${p.score} pts',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
