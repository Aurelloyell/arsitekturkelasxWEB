// lib/screens/jamhood/jamhood_host_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/jamhood_model.dart';
import '../../services/jamhood_service.dart';
import '../../widgets/zoomable_image_dialog.dart';
import 'jamhood_floating_bubble.dart';
import 'jamhood_theme.dart';

class JamHoodHostPage extends StatefulWidget {
  final String pin;
  final String? hostPlayerId;
  final String? hostNickname;

  const JamHoodHostPage({
    super.key,
    required this.pin,
    this.hostPlayerId,
    this.hostNickname,
  });

  @override
  State<JamHoodHostPage> createState() => _JamHoodHostPageState();
}

class _JamHoodHostPageState extends State<JamHoodHostPage> {
  // Isolate timer state to prevent screen flickering
  final ValueNotifier<int> _countdownNotifier = ValueNotifier<int>(3);
  final ValueNotifier<int> _secondsRemainingNotifier = ValueNotifier<int>(20);

  // 3-sec Auto Advance on Reveal
  final ValueNotifier<int> _autoAdvanceSecondsNotifier = ValueNotifier<int>(3);
  Timer? _autoAdvanceTimer;
  bool _isAutoAdvancePaused = false;

  Timer? _countdownTimer;
  Timer? _questionTimer;

  JamHoodRoomStatus? _lastStatus;
  int _lastQuestionIndex = -1;
  int _totalPlayersCount = 0;
  bool _isImagePreviewOpen = false;
  bool _revealRequested = false;

  String? _currentHostPlayerId;
  String? _currentHostNickname;
  int? _hostSelectedAnswerIndex;

  StreamSubscription<JamHoodRoom?>? _roomSub;
  StreamSubscription<List<JamHoodPlayer>>? _playersSub;

  @override
  void initState() {
    super.initState();
    _currentHostPlayerId = widget.hostPlayerId;
    _currentHostNickname = widget.hostNickname ?? 'Host / Guru';

    _roomSub = JamHoodService.streamRoom(widget.pin).listen((room) {
      if (room != null && mounted) {
        _onRoomUpdate(room);
      }
    });

    _playersSub = JamHoodService.streamPlayers(widget.pin).listen((players) {
      _totalPlayersCount = players.length;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _roomSub?.cancel();
    _playersSub?.cancel();
    _countdownNotifier.dispose();
    _secondsRemainingNotifier.dispose();
    _autoAdvanceSecondsNotifier.dispose();
    super.dispose();
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

  /// Dismisses the zoom preview immediately so a timer expiry or host action
  /// never leaves the next phase hidden behind the dialog.
  void _closeQuestionImage() {
    if (!_isImagePreviewOpen) return;
    _isImagePreviewOpen = false;
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }

  /// Build-safe variant used when the room disappears mid-build.
  void _scheduleQuestionImageClose() {
    if (!_isImagePreviewOpen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _closeQuestionImage();
    });
  }

  void _startAutoAdvanceTimer(JamHoodRoom room) {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceSecondsNotifier.value = 3;
    _isAutoAdvancePaused = false;

    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isAutoAdvancePaused) return;

      if (_autoAdvanceSecondsNotifier.value > 1) {
        _autoAdvanceSecondsNotifier.value--;
      } else {
        timer.cancel();
        JamHoodService.advanceNext(
          widget.pin,
          room.currentQuestionIndex + 1,
          room.totalQuestions,
        );
      }
    });
  }

  void _onRoomUpdate(JamHoodRoom room) {
    bool statusChanged = _lastStatus != room.status;
    bool questionChanged = _lastQuestionIndex != room.currentQuestionIndex;

    if (statusChanged || questionChanged) {
      // Any transition out of the question phase closes the zoom preview.
      if (room.status != JamHoodRoomStatus.question || questionChanged) {
        _closeQuestionImage();
      }
      _lastStatus = room.status;
      _lastQuestionIndex = room.currentQuestionIndex;
      _revealRequested = false;

      _countdownTimer?.cancel();
      _questionTimer?.cancel();
      _autoAdvanceTimer?.cancel();

      if (questionChanged) {
        _hostSelectedAnswerIndex = null;
      }

      if (room.status == JamHoodRoomStatus.countdown) {
        _countdownNotifier.value = 3;
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_countdownNotifier.value > 1) {
            _countdownNotifier.value--;
          } else {
            timer.cancel();
            JamHoodService.startQuestion(widget.pin, room.currentQuestionIndex);
          }
        });
      } else if (room.status == JamHoodRoomStatus.question) {
        _secondsRemainingNotifier.value = room.timeLimitSeconds;
        _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_secondsRemainingNotifier.value > 0) {
            _secondsRemainingNotifier.value--;
          } else {
            timer.cancel();
            _revealRequested = true;
            _closeQuestionImage();
            JamHoodService.showReveal(widget.pin);
          }
        });
      } else if (room.status == JamHoodRoomStatus.reveal) {
        _startAutoAdvanceTimer(room);
      }
    }

    // Check if all players answered
    if (room.status == JamHoodRoomStatus.question &&
        !_revealRequested &&
        _totalPlayersCount > 0 &&
        room.totalAnswersSubmitted >= _totalPlayersCount) {
      _revealRequested = true;
      _questionTimer?.cancel();
      _closeQuestionImage();
      JamHoodService.showReveal(widget.pin);
    }
  }

  Future<void> _toggleHostPlaying() async {
    if (_currentHostPlayerId != null) {
      final pid = _currentHostPlayerId!;
      setState(() => _currentHostPlayerId = null);
      await JamHoodService.leaveRoom(pin: widget.pin, playerId: pid);
    } else {
      final name = _currentHostNickname ?? 'Guru / Host';
      final res = await JamHoodService.joinRoom(pin: widget.pin, nickname: name);
      if (res.isSuccess && mounted) {
        setState(() => _currentHostPlayerId = res.playerId);
      }
    }
  }

  Future<void> _handleHostAnswer(int index, JamHoodQuestionItem q) async {
    if (_hostSelectedAnswerIndex != null || _currentHostPlayerId == null) return;
    setState(() => _hostSelectedAnswerIndex = index);
    await JamHoodService.submitAnswer(
      pin: widget.pin,
      playerId: _currentHostPlayerId!,
      selectedIndex: index,
      question: q,
    );
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
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              final room = roomSnap.data;
              if (room == null) {
                _scheduleQuestionImageClose();
                return _buildNotFound();
              }

              return StreamBuilder<List<JamHoodPlayer>>(
                stream: JamHoodService.streamPlayers(widget.pin),
                builder: (context, playersSnap) {
                  final players = playersSnap.data ?? [];

                  switch (room.status) {
                    case JamHoodRoomStatus.lobby:
                      return _buildLobbyView(room, players);
                    case JamHoodRoomStatus.countdown:
                      return _buildCountdownView(room);
                    case JamHoodRoomStatus.question:
                      return _buildQuestionView(room, players, isReveal: false);
                    case JamHoodRoomStatus.reveal:
                      return _buildQuestionView(room, players, isReveal: true);
                    case JamHoodRoomStatus.leaderboard:
                      return _buildLeaderboardView(room, players);
                    case JamHoodRoomStatus.finished:
                      return _buildPodiumView(room, players);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white70),
          const SizedBox(height: 16),
          const Text('Room tidak ditemukan atau telah ditutup.',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  // ================= 1. LOBBY VIEW =================
  Widget _buildLobbyView(JamHoodRoom room, List<JamHoodPlayer> players) {
    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🎉 JAMHOOD HOST',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Tutup Lobby?'),
                      content: const Text('Game akan dibatalkan untuk semua pemain.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Tutup')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await JamHoodService.deleteRoom(widget.pin);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),

        const Spacer(),

        // PIN Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GABUNG DI JAMHOOD PIN:',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.pin,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1035),
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFF46178F)),
                    tooltip: 'Salin PIN',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.pin));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN berhasil disalin!')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Player Count Header Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_alt_rounded, color: Color(0xFF00E676), size: 22),
              const SizedBox(width: 10),
              Text(
                '${players.length} Pemain Siap Bergabung',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Floating Player Bubbles Arena
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: players.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_empty_rounded,
                            size: 48,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Menunggu para pemain memasukkan Game PIN...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Nama pemain yang bergabung akan melayang di sini secara otomatis ✨',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 18,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: List.generate(players.length, (index) {
                            final p = players[index];
                            final bool isHost = p.id == _currentHostPlayerId;
                            return JamHoodFloatingBubble(
                              key: ValueKey(p.id),
                              player: p,
                              index: index,
                              isHost: isHost,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Host Play Toggle Card
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 32,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 14 : 18,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: _currentHostPlayerId != null
                ? const Color(0xFF00C853).withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _currentHostPlayerId != null
                  ? const Color(0xFF00C853)
                  : Colors.white24,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final textColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentHostPlayerId != null
                        ? 'Host Ikut Bermain sebagai "$_currentHostNickname"'
                        : 'Mode Host Saja (Spectator / Layar Proyektor)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: _currentHostPlayerId != null
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentHostPlayerId != null
                        ? 'Kamu dapat menjawab soal dan bersaing di papan peringkat'
                        : 'Host hanya menampilkan soal untuk siswa',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              );

              final toggleButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentHostPlayerId != null
                      ? const Color(0xFFE53935)
                      : const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _toggleHostPlaying,
                icon: Icon(
                  _currentHostPlayerId != null ? Icons.cancel : Icons.play_arrow,
                  size: 16,
                ),
                label: Text(_currentHostPlayerId != null ? 'Batal Ikut' : 'Ikut Main 🎮'),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _currentHostPlayerId != null
                              ? Icons.sports_esports
                              : Icons.sports_esports_outlined,
                          color: _currentHostPlayerId != null
                              ? const Color(0xFF00E676)
                              : Colors.white70,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: textColumn),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: toggleButton,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Icon(
                    _currentHostPlayerId != null
                        ? Icons.sports_esports
                        : Icons.sports_esports_outlined,
                    color: _currentHostPlayerId != null
                        ? const Color(0xFF00E676)
                        : Colors.white70,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: textColumn),
                  const SizedBox(width: 16),
                  toggleButton,
                ],
              );
            },
          ),
        ),

        const Spacer(),

        // Start Button
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: ElevatedButton(
            onPressed: players.isEmpty
                ? null
                : () => JamHoodService.startCountdown(widget.pin, 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
            ),
            child: Text(
              players.isEmpty ? 'Menunggu Pemain...' : 'Mulai Game (${players.length}) 🚀',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  // ================= 2. COUNTDOWN VIEW =================
  Widget _buildCountdownView(JamHoodRoom room) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Soal ${room.currentQuestionIndex + 1} dari ${room.totalQuestions}',
            style: const TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<int>(
            valueListenable: _countdownNotifier,
            builder: (context, count, _) {
              return Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA602),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xFFFFA602), blurRadius: 40, spreadRadius: 5),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Siap-siap!',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= 3. QUESTION & REVEAL VIEW =================
  Widget _buildQuestionView(JamHoodRoom room, List<JamHoodPlayer> players, {required bool isReveal}) {
    final q = room.currentQuestion;
    if (q == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Top Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Soal ${room.currentQuestionIndex + 1} / ${room.totalQuestions}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // Countdown Ring or Answer Count
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${room.totalAnswersSubmitted} / ${players.length} Menjawab',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Isolated Countdown Circle (Zero Flickering)
                  ValueListenableBuilder<int>(
                    valueListenable: _secondsRemainingNotifier,
                    builder: (context, seconds, _) {
                      Color badgeColor = isReveal
                          ? Colors.grey
                          : (seconds <= 5 ? const Color(0xFFE21B3C) : const Color(0xFF46178F));
                      return Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: badgeColor.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isReveal ? '✓' : '$seconds',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Big Question Card (With Image Support)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  q.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),

                // Question Image Display (tap to zoom)
                if (q.imagePath != null && q.imagePath!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Tooltip(
                    message: 'Ketuk untuk memperbesar gambar',
                    child: InkWell(
                      onTap: () => _openQuestionImage(q.imagePath!),
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Image.asset(
                                q.imagePath!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.image_not_supported, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text('Gambar: ${q.imagePath}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.zoom_in_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Host Playing Status Banner
          if (_currentHostPlayerId != null) ...[
            const SizedBox(height: 10),
            if (!isReveal)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _hostSelectedAnswerIndex != null
                      ? const Color(0xFF00C853).withValues(alpha: 0.22)
                      : const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hostSelectedAnswerIndex != null
                        ? const Color(0xFF00C853)
                        : const Color(0xFFFFD700),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hostSelectedAnswerIndex != null ? Icons.lock : Icons.touch_app,
                      color: _hostSelectedAnswerIndex != null
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFFD700),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hostSelectedAnswerIndex != null
                          ? 'Jawaban Host Terkunci: ${q.options[_hostSelectedAnswerIndex!]}'
                          : '👑 Host Ikut Bermain: Ketuk salah satu pilihan kartu di bawah untuk menjawab!',
                      style: TextStyle(
                        color: _hostSelectedAnswerIndex != null
                            ? const Color(0xFF69F0AE)
                            : const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              Builder(builder: (context) {
                JamHoodPlayer? hostP;
                try {
                  hostP = players.firstWhere((p) => p.id == _currentHostPlayerId);
                } catch (_) {}
                if (hostP == null) return const SizedBox.shrink();
                final bool isCorrect = hostP.isLastAnswerCorrect;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isCorrect ? const Color(0xFF00C853) : const Color(0xFFE53935))
                        .withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect ? const Color(0xFF00C853) : const Color(0xFFE53935),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCorrect
                            ? 'Jawaban Host Benar! +${hostP.lastPointsEarned} pts  •  Skor Host: ${hostP.score} pts'
                            : 'Jawaban Host Kurang Tepat! +0 pts  •  Skor Host: ${hostP.score} pts',
                        style: TextStyle(
                          color: isCorrect ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],

          const SizedBox(height: 12),

          // 4 Big Shape/Color Answer Cards
          Expanded(
            child: _buildAnswerGrid(q, isReveal, players),
          ),

          // Bottom Host Action with Auto-Advance & Full Leaderboard View
          if (isReveal)
            () {
              bool isLast = room.currentQuestionIndex + 1 >= room.totalQuestions;
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    // Auto-advance chip with pause toggle
                    ValueListenableBuilder<int>(
                      valueListenable: _autoAdvanceSecondsNotifier,
                      builder: (context, seconds, _) {
                        return ActionChip(
                          avatar: Icon(
                            _isAutoAdvancePaused ? Icons.play_arrow : Icons.timer,
                            size: 18,
                            color: _isAutoAdvancePaused
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFFA602),
                          ),
                          label: Text(
                            _isAutoAdvancePaused
                                ? 'Otomatis Dijeda (Klik untuk lanjut)'
                                : 'Lanjut otomatis dalam ${seconds}d... (Klik jeda)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          backgroundColor: Colors.black.withValues(alpha: 0.45),
                          side: BorderSide(
                            color: _isAutoAdvancePaused
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFFA602),
                          ),
                          onPressed: () {
                            setState(() {
                              _isAutoAdvancePaused = !_isAutoAdvancePaused;
                              if (!_isAutoAdvancePaused) {
                                _startAutoAdvanceTimer(room);
                              } else {
                                _autoAdvanceTimer?.cancel();
                              }
                            });
                          },
                        );
                      },
                    ),

                    // Manual button to advance immediately
                    ElevatedButton.icon(
                      onPressed: () {
                        _autoAdvanceTimer?.cancel();
                        JamHoodService.advanceNext(
                          widget.pin,
                          room.currentQuestionIndex + 1,
                          room.totalQuestions,
                        );
                      },
                      icon: Icon(
                        isLast ? Icons.emoji_events : Icons.arrow_forward,
                        color: isLast ? const Color(0xFF1E1035) : Colors.white,
                      ),
                      label: Text(
                        isLast ? 'Lihat Juara & Leaderboard Akhir! 🏆' : 'Lanjut Sekarang ➔',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isLast ? const Color(0xFF1E1035) : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast ? const Color(0xFFFFD700) : const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 6,
                      ),
                    ),
                  ],
                ),
              );
            }()
          else
            TextButton(
              onPressed: () => JamHoodService.showReveal(widget.pin),
              child: const Text('Lewati / Buka Jawaban', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerGrid(JamHoodQuestionItem q, bool isReveal, [List<JamHoodPlayer> players = const []]) {
    final int optionCount = q.options.length;
    if (optionCount == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 14;
        const double maxTileHeight = 180;
        final int rows = (optionCount / 2).ceil();
        final double availableHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 420;
        final double idealGridHeight =
            maxTileHeight * rows + spacing * (rows - 1);
        final double gridHeight =
            availableHeight < idealGridHeight ? availableHeight : idealGridHeight;
        final double tileHeight =
            ((gridHeight - spacing * (rows - 1)) / rows)
                .clamp(1.0, maxTileHeight)
                .toDouble();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
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
                  Color color = JamHoodTheme.optionColors[index % 4];
                  String shape = JamHoodTheme.optionShapes[index % 4];
                  bool isCorrectOption = index == q.correctIndex;
                  final int chosenCount =
                      players.where((p) => p.selectedOption == index).length;

                  final bool isHostChoice =
                      _currentHostPlayerId != null && _hostSelectedAnswerIndex == index;
                  final bool canHostTap =
                      _currentHostPlayerId != null && !isReveal && _hostSelectedAnswerIndex == null;

                  double opacity = 1.0;
                  if (isReveal) {
                    opacity = isCorrectOption ? 1.0 : 0.35;
                  }

                  Widget cardContent = Opacity(
                    opacity: opacity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        border: isHostChoice
                            ? Border.all(color: const Color(0xFFFFD700), width: 3.5)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isHostChoice
                                ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                                : color.withOpacity(0.4),
                            blurRadius: isHostChoice ? 16 : 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                shape,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              q.options[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isHostChoice) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFD700)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Pilihan Host',
                                    style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (isReveal) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$chosenCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (isReveal && isCorrectOption)
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 32),
                        ],
                      ),
                    ),
                  );

                  if (canHostTap) {
                    return InkWell(
                      onTap: () => _handleHostAnswer(index, q),
                      borderRadius: BorderRadius.circular(20),
                      child: cardContent,
                    );
                  }

                  return cardContent;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= 4. LEADERBOARD VIEW =================
  Widget _buildLeaderboardView(JamHoodRoom room, List<JamHoodPlayer> players) {
    var topPlayers = players.take(5).toList();
    bool isLast = room.currentQuestionIndex + 1 >= room.totalQuestions;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const Text(
            '🏆 LEADERBOARD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: topPlayers.length,
              itemBuilder: (context, index) {
                final p = topPlayers[index];
                Color rankColor;
                if (index == 0) {
                  rankColor = const Color(0xFFFFD700);
                } else if (index == 1) {
                  rankColor = const Color(0xFFC0C0C0);
                } else if (index == 2) {
                  rankColor = const Color(0xFFCD7F32);
                } else {
                  rankColor = Colors.white70;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: index == 0 ? const Color(0xFFFFD700) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: rankColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          p.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (p.streak > 1)
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🔥 ${p.streak}',
                            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      Text(
                        '${p.score} pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton(
              onPressed: () {
                JamHoodService.advanceNext(
                  widget.pin,
                  room.currentQuestionIndex + 1,
                  room.totalQuestions,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 8,
              ),
              child: Text(
                isLast ? 'Lihat Pemenang Podium! 🥇' : 'Soal Berikutnya ➔',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 5. PODIUM & FINAL LEADERBOARD VIEW =================
  Widget _buildPodiumView(JamHoodRoom room, List<JamHoodPlayer> players) {
    final first = players.isNotEmpty ? players[0] : null;
    final second = players.length > 1 ? players[1] : null;
    final third = players.length > 2 ? players[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
      child: Column(
        children: [
          const Text(
            '👑 JUARA & LEADERBOARD AKHIR 👑',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left: 3D-Style Podium (Top 3)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🏆 TOP 3 PEMENANG',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 2nd Place
                            if (second != null)
                              _buildPodiumStep(
                                player: second,
                                place: 2,
                                height: 160,
                                color: const Color(0xFFC0C0C0),
                                trophy: '🥈',
                              ),
                            const SizedBox(width: 14),

                            // 1st Place
                            if (first != null)
                              _buildPodiumStep(
                                player: first,
                                place: 1,
                                height: 220,
                                color: const Color(0xFFFFD700),
                                trophy: '🥇',
                              ),
                            const SizedBox(width: 14),

                            // 3rd Place
                            if (third != null)
                              _buildPodiumStep(
                                player: third,
                                place: 3,
                                height: 120,
                                color: const Color(0xFFCD7F32),
                                trophy: '🥉',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Right: Complete Final Leaderboard
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '📊 KLASEMEN LENGKAP',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${players.length} Pemain',
                              style: const TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final p = players[index];
                              Color rankColor;
                              if (index == 0) {
                                rankColor = const Color(0xFFFFD700);
                              } else if (index == 1) {
                                rankColor = const Color(0xFFC0C0C0);
                              } else if (index == 2) {
                                rankColor = const Color(0xFFCD7F32);
                              } else {
                                rankColor = Colors.white70;
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: index == 0 ? const Color(0xFFFFD700) : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '#${index + 1}',
                                      style: TextStyle(
                                        color: rankColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        p.nickname,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (p.streak > 1)
                                      Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '🔥 ${p.streak}',
                                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    Text(
                                      '${p.score} pts',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
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
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                JamHoodService.deleteRoom(widget.pin);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.exit_to_app_rounded, color: Color(0xFF1E1035)),
              label: const Text(
                'Selesai & Keluar ke Menu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1035),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E1035),
                padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep({
    required JamHoodPlayer player,
    required int place,
    required double height,
    required Color color,
    required String trophy,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(trophy, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 4),
        Text(
          player.nickname,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${player.score} pts',
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Container(
          width: 120,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$place',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

