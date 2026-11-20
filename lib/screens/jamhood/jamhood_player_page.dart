// lib/screens/jamhood/jamhood_player_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/jamhood_model.dart';
import '../../services/jamhood_service.dart';
import '../../widgets/zoomable_image_dialog.dart';
import 'jamhood_floating_bubble.dart';
import 'jamhood_leaderboard_sheet.dart';
import 'jamhood_theme.dart';

class JamHoodPlayerPage extends StatefulWidget {
  final String pin;
  final String nickname;
  final String? playerId;

  const JamHoodPlayerPage({
    super.key,
    required this.pin,
    required this.nickname,
    this.playerId,
  });

  @override
  State<JamHoodPlayerPage> createState() => _JamHoodPlayerPageState();
}

class _JamHoodPlayerPageState extends State<JamHoodPlayerPage> {
  int? _selectedAnswerIndex;
  int _lastQuestionIndex = -1;
  bool _isImagePreviewOpen = false;

  final ValueNotifier<int> _secondsRemainingNotifier = ValueNotifier<int>(20);
  Timer? _questionTimer;
  int _lastTimerQuestionIndex = -1;

  @override
  void dispose() {
    _questionTimer?.cancel();
    _secondsRemainingNotifier.dispose();
    super.dispose();
  }

  void _startQuestionTimer(JamHoodRoom room) {
    _questionTimer?.cancel();
    int initialSeconds = room.timeLimitSeconds;
    if (room.questionStartTimeMs > 0) {
      final elapsedSec =
          (DateTime.now().millisecondsSinceEpoch - room.questionStartTimeMs) ~/
              1000;
      initialSeconds =
          (room.timeLimitSeconds - elapsedSec).clamp(0, room.timeLimitSeconds);
    }
    _secondsRemainingNotifier.value = initialSeconds;

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemainingNotifier.value > 0) {
        _secondsRemainingNotifier.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void _handleRoomTimerSync(JamHoodRoom room) {
    if (room.status == JamHoodRoomStatus.question) {
      if (_lastTimerQuestionIndex != room.currentQuestionIndex) {
        _lastTimerQuestionIndex = room.currentQuestionIndex;
        _startQuestionTimer(room);
      }
    } else {
      if (_lastTimerQuestionIndex != -1) {
        _lastTimerQuestionIndex = -1;
        _questionTimer?.cancel();
      }
    }
  }

  Future<void> _confirmExitRoom() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: Color(0xFFE53935)),
            SizedBox(width: 10),
            Text('Keluar dari Room?'),
          ],
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar dari antrean game PIN ${widget.pin}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.playerId != null) {
        await JamHoodService.leaveRoom(
          pin: widget.pin,
          playerId: widget.playerId!,
        );
      }
      if (mounted) Navigator.pop(context);
    }
  }

  void _openQuestionImage(String imagePath) {
    if (_isImagePreviewOpen) return;
    _isImagePreviewOpen = true;
    showZoomableImageDialog(
      context,
      imagePath: imagePath,
      title: 'Perbesar gambar soal',
    ).whenComplete(() {
      _isImagePreviewOpen = false;
    });
  }

  /// Closes the zoom preview when the question ends so the next phase is not
  /// hidden behind the dialog.
  void _closeImagePreview() {
    if (!_isImagePreviewOpen) return;
    _isImagePreviewOpen = false;
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }

  /// Build-safe variant used when a stream update is handled mid-build.
  void _scheduleImagePreviewClose() {
    if (!_isImagePreviewOpen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _closeImagePreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: JamHoodTheme.gradientBackground(),
        child: SafeArea(
          child: StreamBuilder<JamHoodRoom?>(
            stream: JamHoodService.streamRoom(widget.pin),
            builder: (context, roomSnap) {
              if (roomSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              final room = roomSnap.data;
              if (room == null) {
                _scheduleImagePreviewClose();
                return _buildRoomClosed();
              }

              // Keep the question phase and the zoom dialog in sync: as soon
              // as the room leaves the question state (timer out, all players
              // answered, host skips), close the image and let the game move on.
              if (_isImagePreviewOpen &&
                  room.status != JamHoodRoomStatus.question) {
                _scheduleImagePreviewClose();
              }

              return StreamBuilder<List<JamHoodPlayer>>(
                stream: JamHoodService.streamPlayers(widget.pin),
                builder: (context, playersSnap) {
                  final players = playersSnap.data ?? [];

                  // Find the current player by id first. Only fall back to the
                  // nickname when the join result carried no id, so a duplicate
                  // nickname can never resolve to somebody else's score.
                  JamHoodPlayer? me;
                  int myRank = 1;
                  int myIndex = widget.playerId != null
                      ? players.indexWhere((p) => p.id == widget.playerId)
                      : -1;
                  if (myIndex < 0) {
                    myIndex = players.indexWhere(
                      (p) =>
                          p.nickname.toLowerCase() ==
                          widget.nickname.toLowerCase(),
                    );
                  }
                  if (myIndex >= 0) {
                    me = players[myIndex];
                    myRank = myIndex + 1;
                  }

                  // Reset local selection when question changes or countdown begins
                  if (room.currentQuestionIndex != _lastQuestionIndex ||
                      room.status == JamHoodRoomStatus.countdown) {
                    _lastQuestionIndex = room.currentQuestionIndex;
                    _selectedAnswerIndex = null;
                    _scheduleImagePreviewClose();
                  }

                  _handleRoomTimerSync(room);

                  switch (room.status) {
                    case JamHoodRoomStatus.lobby:
                      return _buildPlayerLobbyView(players);
                    case JamHoodRoomStatus.countdown:
                      return _buildPlayerCountdownView();
                    case JamHoodRoomStatus.question:
                      return _buildPlayerQuestionView(room, me);
                    case JamHoodRoomStatus.reveal:
                      return _buildPlayerRevealView(room, me, players);
                    case JamHoodRoomStatus.leaderboard:
                      return _buildPlayerLeaderboardView(me, myRank, players);
                    case JamHoodRoomStatus.finished:
                      return _buildPlayerFinishedView(me, myRank, players);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoomClosed() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied,
            size: 72,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          const Text(
            'Game telah berakhir atau ditutup.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // 1. Player Waiting in Lobby
  Widget _buildPlayerLobbyView(List<JamHoodPlayer> players) {
    return Column(
      children: [
        // Top Bar with Back Button & Room PIN info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button to exit room
              InkWell(
                onTap: _confirmExitRoom,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Keluar Room',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Player Count Header Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00E676).withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Color(0xFF00E676), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${players.length} Pemain Siap',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Main Content Area with Avatar & Floating Bubbles
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Player's Avatar
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF46178F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF46178F).withOpacity(0.6),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sentiment_very_satisfied_rounded, size: 72, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kamu sudah bergabung! 🎉',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Lihat namamu di layar host dan tunggu game dimulai...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // Floating Players Arena
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E676),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pemain yang Sudah Bergabung (${players.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: List.generate(players.length, (index) {
                          final p = players[index];
                          final bool isMe = (widget.playerId != null && p.id == widget.playerId) ||
                              p.nickname.toLowerCase() == widget.nickname.toLowerCase();
                          return JamHoodFloatingBubble(
                            key: ValueKey(p.id),
                            player: p,
                            index: index,
                            isHost: false,
                            isMe: isMe,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. Countdown View
  Widget _buildPlayerCountdownView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 80, color: Color(0xFFFFA602)),
          SizedBox(height: 16),
          Text(
            'Siap-siap!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Soal akan muncul di perangkatmu.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // 3. Question Buttons (4 Big Kahoot-style buttons)
  Widget _buildPlayerQuestionView(JamHoodRoom room, JamHoodPlayer? me) {
    final q = room.currentQuestion;
    bool hasSubmitted =
        (me?.hasAnswered ?? false) || _selectedAnswerIndex != null;
    int? lockedChoice = _selectedAnswerIndex ?? me?.selectedOption;

    if (hasSubmitted) {
      Color selectedColor = lockedChoice != null
          ? JamHoodTheme.optionColors[lockedChoice % 4]
          : const Color(0xFF46178F);
      String selectedShape = lockedChoice != null
          ? JamHoodTheme.optionShapes[lockedChoice % 4]
          : '✓';

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  selectedShape,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Jawaban Terkunci! 🔒',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Menunggu pemain lain & waktu habis...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<int>(
              valueListenable: _secondsRemainingNotifier,
              builder: (context, seconds, _) {
                final isUrgent = seconds <= 5;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? const Color(0xFFE21B3C).withOpacity(0.3)
                        : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUrgent ? const Color(0xFFFF5252) : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: isUrgent ? const Color(0xFFFF5252) : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sisa waktu: $seconds dtk',
                        style: TextStyle(
                          color: isUrgent ? const Color(0xFFFF8A80) : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (lockedChoice != null &&
                q != null &&
                lockedChoice >= 0 &&
                lockedChoice < q.options.length) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Jawabanmu: ${q.options[lockedChoice]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Question Header Row with Question number and Countdown Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Soal ${room.currentQuestionIndex + 1} / ${room.totalQuestions}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _secondsRemainingNotifier,
                    builder: (context, seconds, _) {
                      final isUrgent = seconds <= 5;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUrgent ? const Color(0xFFE21B3C) : const Color(0xFF46178F),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUrgent ? const Color(0xFFFF5252) : Colors.white38,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isUrgent ? const Color(0xFFE21B3C) : const Color(0xFF46178F))
                                  .withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: isUrgent ? Colors.white : const Color(0xFFFFA602),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$seconds',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Question text is shown on every device, not only on the host screen.
              if (q != null)
                Text(
                  q.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),

              // Question image preview. Tap to open the zoomable viewer.
              if (q?.imagePath != null && q!.imagePath!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: _buildQuestionImage(q.imagePath!),
                ),
              ],

              const SizedBox(height: 8),
              const Text(
                'Pilih jawaban yang benar:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // All four answers stay visible regardless of viewport size.
              Expanded(child: _buildAnswerGrid(q, me)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionImage(String imagePath) {
    return Tooltip(
      message: 'Ketuk untuk memperbesar gambar',
      child: InkWell(
        onTap: () => _openQuestionImage(imagePath),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 120,
                  maxWidth: 320,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerGrid(JamHoodQuestionItem? q, JamHoodPlayer? me) {
    final int optionCount = q?.options.length ?? 0;
    if (optionCount == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 10;
        const double maxTileHeight = 180;
        final int rows = (optionCount / 2).ceil();
        final double availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 360;
        final double idealGridHeight =
            maxTileHeight * rows + spacing * (rows - 1);
        // Never taller than needed and never taller than the space available, so
        // all four answers stay on screen even in a short landscape viewport.
        final double gridHeight = availableHeight < idealGridHeight
            ? availableHeight
            : idealGridHeight;
        final double tileHeight = ((gridHeight - spacing * (rows - 1)) / rows)
            .clamp(1.0, maxTileHeight)
            .toDouble();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SizedBox(
              height: gridHeight,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: tileHeight,
                ),
                itemCount: optionCount,
                itemBuilder: (context, index) {
                  final Color color = JamHoodTheme.optionColors[index % 4];
                  final String shape = JamHoodTheme.optionShapes[index % 4];

                  return InkWell(
                    onTap: () async {
                      if (q == null || _selectedAnswerIndex != null) return;
                      // Fall back to the id from the join result so the button
                      // works even before the players stream has arrived.
                      final String? playerId = me?.id ?? widget.playerId;
                      if (playerId == null) return;

                      setState(() => _selectedAnswerIndex = index);
                      final messenger = ScaffoldMessenger.maybeOf(context);
                      final bool accepted = await JamHoodService.submitAnswer(
                        pin: widget.pin,
                        playerId: playerId,
                        selectedIndex: index,
                        question: q,
                      );

                      if (!accepted && mounted) {
                        setState(() => _selectedAnswerIndex = null);
                        messenger?.showSnackBar(
                          const SnackBar(
                            content: Text('Jawaban belum terkirim. Coba lagi.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.45),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              shape,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                q?.options[index] ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // 4. Reveal Screen (Instant feedback)
  Widget _buildPlayerRevealView(
    JamHoodRoom room,
    JamHoodPlayer? me,
    List<JamHoodPlayer> players,
  ) {
    final JamHoodQuestionItem? q = room.currentQuestion;
    final int? selected = me?.selectedOption ?? _selectedAnswerIndex;
    final bool hasAnswered = selected != null;

    final bool finalized = me?.scoreFinalized == true;
    final bool isCorrect = finalized
        ? me!.isLastAnswerCorrect
        : (hasAnswered &&
              q != null &&
              selected >= 0 &&
              selected < q.options.length &&
              selected == q.correctIndex);
    final int pointsEarned = me?.lastPointsEarned ?? 0;

    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    if (!hasAnswered) {
      statusColor = const Color(0xFFFFA602);
      statusIcon = Icons.timer_off_outlined;
      statusTitle = 'WAKTU HABIS! ⌛';
    } else if (isCorrect) {
      statusColor = const Color(0xFF00C853);
      statusIcon = Icons.check;
      statusTitle = 'BENAR! 🎉';
    } else {
      statusColor = const Color(0xFFE53935);
      statusIcon = Icons.close;
      statusTitle = 'KURANG TEPAT! 😢';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(statusIcon, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 18),
              Text(
                statusTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (isCorrect) ...[
                Text(
                  pointsEarned > 0
                      ? '+$pointsEarned pts'
                      : (finalized ? '+0 pts' : 'Menghitung poin...'),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if ((me?.streak ?? 0) > 1) ...[
                  const SizedBox(height: 6),
                  Text(
                    '🔥 ${me!.streak}x Jawaban Beruntun!',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ] else if (!hasAnswered) ...[
                const Text(
                  'Kamu belum sempat memilih jawaban.',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ] else ...[
                const Text(
                  '+0 pts',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Player's selected answer summary
              if (hasAnswered &&
                  q != null &&
                  selected >= 0 &&
                  selected < q.options.length) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        (isCorrect
                                ? const Color(0xFF00C853)
                                : const Color(0xFFE53935))
                            .withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFF00C853)
                          : const Color(0xFFE53935),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: JamHoodTheme.optionColors[selected % 4],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          JamHoodTheme.optionShapes[selected % 4],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCorrect ? 'Jawabanmu (Tepat):' : 'Jawabanmu:',
                              style: TextStyle(
                                color: isCorrect
                                    ? const Color(0xFF69F0AE)
                                    : const Color(0xFFFF8A80),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              q.options[selected],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF5252),
                        size: 26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Correct answer card if player got it wrong or timed out
              if (!isCorrect &&
                  q != null &&
                  q.correctIndex >= 0 &&
                  q.correctIndex < q.options.length) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00C853),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: JamHoodTheme.optionColors[q.correctIndex % 4],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          JamHoodTheme.optionShapes[q.correctIndex % 4],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kunci Jawaban Benar:',
                              style: TextStyle(
                                color: Color(0xFF69F0AE),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              q.options[q.correctIndex],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF00E676),
                        size: 26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),
              const Text(
                'Tunggu host melanjutkan...',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Leaderboard View
  Widget _buildPlayerLeaderboardView(
    JamHoodPlayer? me,
    int rank,
    List<JamHoodPlayer> players,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Peringkat Kamu #$rank',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'dari ${players.length} pemain',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Skor',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${me?.score ?? 0} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showJamHoodLeaderboardModal(
                  context,
                  players: players,
                  currentUserId: me?.id ?? widget.playerId,
                  isReveal: false,
                );
              },
              icon: const Icon(Icons.leaderboard_rounded),
              label: Text('Buka Semua Peringkat (${players.length}) 📊'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF46178F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tunggu host melanjutkan ke soal berikutnya...',
              style: TextStyle(color: Colors.white60, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Finished View
  Widget _buildPlayerFinishedView(
    JamHoodPlayer? me,
    int rank,
    List<JamHoodPlayer> players,
  ) {
    String message = 'Kerja Bagus!';
    String emoji = '🎉';
    if (rank == 1) {
      message = 'JUARA 1!';
      emoji = '🥇';
    } else if (rank == 2) {
      message = 'JUARA 2!';
      emoji = '🥈';
    } else if (rank == 3) {
      message = 'JUARA 3!';
      emoji = '🥉';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Peringkat #$rank • ${me?.score ?? 0} pts',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () {
                showJamHoodLeaderboardModal(
                  context,
                  players: players,
                  currentUserId: me?.id ?? widget.playerId,
                  isReveal: false,
                );
              },
              icon: const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
              label: Text(
                'Lihat Papan Peringkat Lengkap (${players.length}) 🏆',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E1035),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Kembali ke Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
