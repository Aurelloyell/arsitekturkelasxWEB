// lib/screens/quiz_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../quiz_data.dart';
import '../services/audio_effects_service.dart';
import '../services/jamhood_service.dart';
import 'jamhood/jamhood_host_page.dart';
import 'jamhood/jamhood_player_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

enum QuizViewMode { hub, solo, review }

class QuizSessionItem {
  final QuizQuestion question;
  final List<String> shuffledOptions;
  final int correctOptionIndex;
  int? selectedIndex;
  bool wasCorrect = false;
  bool timedOut = false;

  QuizSessionItem({
    required this.question,
    required this.shuffledOptions,
    required this.correctOptionIndex,
  });
}

class _QuizPageState extends State<QuizPage> {
  static const int soloQuestionCount = 20;
  static const int soloSecondsPerQuestion = 20;
  static const String bestScoreKey = 'solo_quiz_best_score';

  QuizViewMode _currentMode = QuizViewMode.hub;

  List<QuizSessionItem> _sessionItems = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _secondsRemaining = soloSecondsPerQuestion;
  Timer? _questionTimer;
  int _bestScore = 0;

  bool _isCreatingRoom = false;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    JamHoodService.cleanupExpiredRooms();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _bestScore = prefs.getInt(bestScoreKey) ?? 0);
    }
  }

  Future<void> _saveBestScore(int percentage) async {
    if (percentage <= _bestScore) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(bestScoreKey, percentage);
    if (mounted) setState(() => _bestScore = percentage);
  }

  // -------------------------------------------------------------------
  // Solo flow
  // -------------------------------------------------------------------

  void _startSoloQuiz() {
    _questionTimer?.cancel();
    final allQuestions = List<QuizQuestion>.from(masterQuizList)..shuffle();
    final takeCount = allQuestions.length < soloQuestionCount
        ? allQuestions.length
        : soloQuestionCount;

    final processed = allQuestions.take(takeCount).map((q) {
      final correctText = q.options[q.correctIndex];
      final options = List<String>.from(q.options)..shuffle();
      return QuizSessionItem(
        question: q,
        shuffledOptions: options,
        correctOptionIndex: options.indexOf(correctText),
      );
    }).toList();

    AudioEffectsService.playClick();
    setState(() {
      _sessionItems = processed;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _answered = false;
      _currentMode = QuizViewMode.solo;
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _secondsRemaining = soloSecondsPerQuestion;
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _answerSoloQuestion(null, timedOut: true);
        return;
      }
      if (mounted) setState(() => _secondsRemaining--);
    });
  }

  void _answerSoloQuestion(int? selectedIndex, {bool timedOut = false}) {
    if (_answered || _sessionItems.isEmpty) return;
    _questionTimer?.cancel();

    final item = _sessionItems[_currentQuestionIndex];
    final bool correct = !timedOut &&
        selectedIndex != null &&
        selectedIndex == item.correctOptionIndex;

    if (correct) {
      _score++;
      AudioEffectsService.playSuccess();
    } else {
      AudioEffectsService.playClick();
    }

    setState(() {
      _answered = true;
      _selectedIndex = selectedIndex;
      item.selectedIndex = selectedIndex;
      item.wasCorrect = correct;
      item.timedOut = timedOut;
    });
  }

  void _nextSoloQuestion() {
    if (_currentQuestionIndex >= _sessionItems.length - 1) {
      final percentage =
          ((_score / _sessionItems.length) * 100).round();
      _saveBestScore(percentage);
      setState(() => _currentMode = QuizViewMode.review);
      return;
    }
    setState(() {
      _currentQuestionIndex++;
      _selectedIndex = null;
      _answered = false;
    });
    _startQuestionTimer();
  }

  void _leaveSolo() {
    _questionTimer?.cancel();
    AudioEffectsService.playClick();
    setState(() => _currentMode = QuizViewMode.hub);
  }

  // -------------------------------------------------------------------
  // JamHood dialogs
  // -------------------------------------------------------------------

  Future<void> _showJoinJamHoodDialog({String initialPin = ''}) async {
    final pinController = TextEditingController(text: initialPin);
    final nameController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Gabung JamHood',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Game PIN (6 Angka)',
                        hintText: 'Contoh: 123456',
                        prefixIcon: const Icon(Icons.pin),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: 'Nickname Kamu',
                        hintText: 'Contoh: Alex, Budi',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '',
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF46178F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final String pin = pinController.text.trim();
                          final String name = nameController.text.trim();

                          if (pin.length != 6 || int.tryParse(pin) == null) {
                            setDialogState(() => errorMessage = 'PIN harus 6 digit angka');
                            return;
                          }
                          if (name.isEmpty) {
                            setDialogState(() => errorMessage = 'Masukkan nama kamu!');
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          final navigator = Navigator.of(context);
                          final dialogNav = Navigator.of(dialogContext);
                          final JoinResult res = await JamHoodService.joinRoom(
                            pin: pin,
                            nickname: name,
                          );

                          if (!res.isSuccess && dialogContext.mounted) {
                            setDialogState(() {
                              isLoading = false;
                              errorMessage = res.error ?? 'Gagal bergabung';
                            });
                          } else if (res.isSuccess) {
                            dialogNav.pop();
                            navigator.push(
                              MaterialPageRoute(
                                builder: (context) => JamHoodPlayerPage(
                                  pin: pin,
                                  nickname: name,
                                  playerId: res.playerId,
                                ),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Masuk Game'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showHostConfigDialog() async {
    int questionCount = 10;
    int timeLimit = 20;
    bool hostPlays = false;
    final hostNameController = TextEditingController(text: 'Guru / Host');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Atur Room JamHood',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jumlah Soal:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 5, label: Text('5')),
                          ButtonSegment(value: 10, label: Text('10')),
                          ButtonSegment(value: 15, label: Text('15')),
                          ButtonSegment(value: 20, label: Text('20')),
                        ],
                        selected: {questionCount},
                        onSelectionChanged: (val) {
                          setDialogState(() => questionCount = val.first);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Waktu Per Soal:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 10, label: Text('10s')),
                          ButtonSegment(value: 20, label: Text('20s')),
                          ButtonSegment(value: 30, label: Text('30s')),
                        ],
                        selected: {timeLimit},
                        onSelectionChanged: (val) {
                          setDialogState(() => timeLimit = val.first);
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hostPlays
                              ? const Color(0xFF00C853).withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: hostPlays ? const Color(0xFF00C853) : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Host Ikut Bermain?',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: const Text(
                                'Host ikut menjawab soal dan bersaing di papan peringkat',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: hostPlays,
                              activeThumbColor: const Color(0xFF00C853),
                              onChanged: (val) => setDialogState(() => hostPlays = val),
                            ),
                            if (hostPlays) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: hostNameController,
                                maxLength: 15,
                                decoration: InputDecoration(
                                  labelText: 'Nama Host di Game',
                                  hintText: 'Contoh: Guru Budi',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  counterText: '',
                                  isDense: true,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A853),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    setState(() => _isCreatingRoom = true);
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final String pin = await JamHoodService.createRoom(
                        hostId: 'host_${DateTime.now().millisecondsSinceEpoch}',
                        questionCount: questionCount,
                        timeLimitSeconds: timeLimit,
                      );

                      String? hostPlayerId;
                      String? hostNickname;
                      if (hostPlays) {
                        hostNickname = hostNameController.text.trim().isEmpty
                            ? 'Guru / Host'
                            : hostNameController.text.trim();
                        final joinRes = await JamHoodService.joinRoom(
                          pin: pin,
                          nickname: hostNickname,
                        );
                        if (joinRes.isSuccess) {
                          hostPlayerId = joinRes.playerId;
                        }
                      }

                      navigator.push(
                        MaterialPageRoute(
                          builder: (context) => JamHoodHostPage(
                            pin: pin,
                            hostPlayerId: hostPlayerId,
                            hostNickname: hostNickname,
                          ),
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Gagal membuat room: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _isCreatingRoom = false);
                    }
                  },
                  child: const Text('Buat Room'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentMode) {
      case QuizViewMode.solo:
        return _buildSoloScaffold();
      case QuizViewMode.review:
        return _buildReviewScaffold();
      case QuizViewMode.hub:
        return _buildHubScaffold();
    }
  }

  // -------------------------------------------------------------------
  // Hub
  // -------------------------------------------------------------------

  Widget _buildHubScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Arena Kuis Arsitektur',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF0F172A), size: 20),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Kembali',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.home_rounded,
                    color: Color(0xFF0F172A), size: 20),
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                tooltip: 'Halaman Utama',
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ATAU PILIH MODE LAIN',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                _AnimatedSoloCard(
                  onTap: _startSoloQuiz,
                  bestScore: _bestScore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1654), Color(0xFF46178F), Color(0xFF7A22C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('MINIGAME INTERAKTIF',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.5)),
          ),
          const SizedBox(height: 16),
          const Text(
            'JamHood Multiplayer!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mainkan kuis arsitektur bersama teman secara real-time. Host di layar utama, lalu jawab dari HP atau browser masing-masing!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _AnimatedQuizActionButton(
                onPressed: _isCreatingRoom ? null : _showHostConfigDialog,
                icon: _isCreatingRoom
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF46178F)),
                      )
                    : const Icon(Icons.tv, size: 22),
                label: 'Buat Room (Host)',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF46178F),
              ),
              _AnimatedQuizActionButton(
                onPressed: () => _showJoinJamHoodDialog(),
                icon: const Icon(Icons.login, size: 22),
                label: 'Gabung dengan PIN',
                backgroundColor: const Color(0xFF00A853),
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Solo question screen
  // -------------------------------------------------------------------

  Widget _buildSoloScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis Mandiri Arsitektur'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _leaveSolo,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 800,
                maxHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _sessionItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSoloQuizScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoloQuizScreen() {
    final item = _sessionItems[_currentQuestionIndex];
    final bool timeLow = _secondsRemaining <= 5 && !_answered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _sessionItems.length,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Pertanyaan ${_currentQuestionIndex + 1} / ${_sessionItems.length}',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timeLow
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer,
                      size: 16,
                      color: timeLow
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF0369A1)),
                  const SizedBox(width: 6),
                  Text(
                    '${_answered ? '-' : _secondsRemaining}s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: timeLow
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.question.text,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
              ),
              if (item.question.imagePath != null &&
                  item.question.imagePath!.isNotEmpty) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Image.asset(
                      item.question.imagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              color: Color(0xFF94A3B8), size: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: item.shuffledOptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final bool isCorrect = index == item.correctOptionIndex;
              final bool isChosen = index == _selectedIndex;
              Color? background;
              Color border = const Color(0xFFCBD5E1);
              IconData? endIcon;
              if (_answered) {
                if (isCorrect) {
                  background = const Color(0xFFDCFCE7);
                  border = const Color(0xFF16A34A);
                  endIcon = Icons.check_circle;
                } else if (isChosen) {
                  background = const Color(0xFFFEE2E2);
                  border = const Color(0xFFDC2626);
                  endIcon = Icons.cancel;
                }
              }
              return _AnimatedQuizOptionButton(
                text: item.shuffledOptions[index],
                background: background,
                border: border,
                endIcon: endIcon,
                enabled: !_answered,
                onPressed: () => _answerSoloQuestion(index),
              );
            },
          ),
        ),
        if (_answered) ...[
          const SizedBox(height: 8),
          _buildFeedbackCard(item),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _nextSoloQuestion,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_currentQuestionIndex >= _sessionItems.length - 1
                ? 'Lihat Hasil'
                : 'Soal Berikutnya'),
          ),
        ],
      ],
    );
  }

  Widget _buildFeedbackCard(QuizSessionItem item) {
    final String title = item.wasCorrect
        ? 'Benar!'
        : item.timedOut
            ? 'Waktu habis'
            : 'Belum tepat';
    final Color color = item.wasCorrect
        ? const Color(0xFF166534)
        : const Color(0xFFB91C1C);
    final String explanation = item.question.explanation.trim().isEmpty
        ? 'Jawaban yang benar: ${item.shuffledOptions[item.correctOptionIndex]}.'
        : item.question.explanation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.wasCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.wasCorrect ? Icons.check_circle : Icons.info_outline,
                  color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: color, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Jawaban benar: ${item.shuffledOptions[item.correctOptionIndex]}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Review screen
  // -------------------------------------------------------------------

  Widget _buildReviewScaffold() {
    final int percentage = _sessionItems.isEmpty
        ? 0
        : ((_score / _sessionItems.length) * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Hasil & Pembahasan'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF0F172A),
            child: SafeArea(
              child: Column(
                children: [
                  Icon(
                    percentage >= 70 ? Icons.emoji_events : Icons.school_outlined,
                    size: 48,
                    color: percentage >= 70
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF7DD3FC),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                  Text(
                    '$_score dari ${_sessionItems.length} soal benar',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Skor terbaik: $_bestScore%',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _leaveSolo,
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Menu Utama'),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _startSoloQuiz,
                    icon: const Icon(Icons.replay),
                    label: const Text('Ulangi'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: _sessionItems.length,
              itemBuilder: (context, index) {
                final item = _sessionItems[index];
                return _buildReviewItem(index + 1, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(int number, QuizSessionItem item) {
    final String yourAnswer = item.timedOut
        ? 'Tidak menjawab (waktu habis)'
        : item.selectedIndex != null
            ? item.shuffledOptions[item.selectedIndex!]
            : 'Tidak menjawab';
    final String explanation = item.question.explanation.trim().isEmpty
        ? 'Jawaban yang benar: ${item.shuffledOptions[item.correctOptionIndex]}.'
        : item.question.explanation;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: item.wasCorrect
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  child: Icon(
                    item.wasCorrect ? Icons.check : Icons.close,
                    size: 16,
                    color: item.wasCorrect
                        ? const Color(0xFF166534)
                        : const Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$number. ${item.question.text}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Jawabanmu: $yourAnswer',
                style: TextStyle(
                    fontSize: 13,
                    color: item.wasCorrect
                        ? const Color(0xFF166534)
                        : const Color(0xFFB91C1C))),
            const SizedBox(height: 4),
            Text(
              'Jawaban benar: ${item.shuffledOptions[item.correctOptionIndex]}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== ANIMATED ACTION BUTTON FOR QUIZ =====================
class _AnimatedQuizActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _AnimatedQuizActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  State<_AnimatedQuizActionButton> createState() =>
      _AnimatedQuizActionButtonState();
}

class _AnimatedQuizActionButtonState extends State<_AnimatedQuizActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        AudioEffectsService.playHover();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed != null
              ? () {
                  AudioEffectsService.playClick();
                  widget.onPressed!();
                }
              : null,
          icon: widget.icon,
          label: Text(widget.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ===================== SOLO CARD =====================
class _AnimatedSoloCard extends StatefulWidget {
  final VoidCallback onTap;
  final int bestScore;

  const _AnimatedSoloCard({required this.onTap, required this.bestScore});

  @override
  State<_AnimatedSoloCard> createState() => _AnimatedSoloCardState();
}

class _AnimatedSoloCardState extends State<_AnimatedSoloCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        AudioEffectsService.playHover();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        child: Card(
          elevation: _isHovered ? 5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _isHovered
                  ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school,
                          size: 34, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Latihan Mandiri (Solo Quiz)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '20 soal pilihan ganda dengan timer, pembahasan, dan daftar review. Skor terbaik tersimpan di perangkat ini.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          if (widget.bestScore > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Skor terbaik: ${widget.bestScore}%',
                              style: const TextStyle(
                                color: Color(0xFF0369A1),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AudioEffectsService.playClick();
                      widget.onTap();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai Solo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== SOLO OPTION BUTTON =====================
class _AnimatedQuizOptionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? background;
  final Color border;
  final IconData? endIcon;
  final bool enabled;

  const _AnimatedQuizOptionButton({
    required this.text,
    required this.onPressed,
    required this.border,
    required this.enabled,
    this.background,
    this.endIcon,
  });

  @override
  State<_AnimatedQuizOptionButton> createState() =>
      _AnimatedQuizOptionButtonState();
}

class _AnimatedQuizOptionButtonState extends State<_AnimatedQuizOptionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool interactive = widget.enabled;
    return MouseRegion(
      onEnter: (_) {
        if (!interactive) return;
        setState(() => _isHovered = true);
        AudioEffectsService.playHover();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: interactive && _isHovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: widget.background ??
                (_isHovered ? const Color(0xFFF1F5F9) : Colors.white),
            foregroundColor: const Color(0xFF0F172A),
            disabledBackgroundColor: widget.background ?? Colors.white,
            disabledForegroundColor: const Color(0xFF0F172A),
            elevation: interactive && _isHovered ? 3 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: widget.border, width: 1.5),
            ),
            alignment: Alignment.centerLeft,
          ),
          onPressed: interactive ? widget.onPressed : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (widget.endIcon != null) Icon(widget.endIcon, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
