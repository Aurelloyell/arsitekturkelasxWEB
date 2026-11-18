// lib/models/jamhood_model.dart

enum JamHoodRoomStatus {
  lobby,        // Waiting for players to join
  countdown,    // 3..2..1 starting round
  question,     // Question active, players can tap answer
  reveal,       // Answer revealed, show correct answer & stats
  leaderboard,  // Top 5 / ranking shown
  finished,     // Final podium (1st, 2nd, 3rd)
}

int? _readMillis(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  // Firestore Timestamp exposes millisecondsSinceEpoch without needing an import.
  try {
    return (value as dynamic).millisecondsSinceEpoch as int;
  } catch (_) {
    return null;
  }
}

class JamHoodQuestionItem {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int timeLimit; // seconds (default: 20)
  final String? imagePath;

  JamHoodQuestionItem({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.timeLimit = 20,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctIndex': correctIndex,
      'timeLimit': timeLimit,
      'imagePath': imagePath,
    };
  }

  factory JamHoodQuestionItem.fromMap(Map<String, dynamic> map) {
    return JamHoodQuestionItem(
      id: map['id']?.toString() ?? '',
      questionText: map['questionText']?.toString() ?? '',
      options: (map['options'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      timeLimit: (map['timeLimit'] as num?)?.toInt() ?? 20,
      imagePath: map['imagePath']?.toString(),
    );
  }
}

class JamHoodRoom {
  /// A lobby older than this is considered abandoned. Two hours comfortably
  /// covers a lesson while still releasing PINs after a closed browser tab.
  static const int lobbyTtlMs = 2 * 60 * 60 * 1000;

  final String pin;
  final String hostId;
  final JamHoodRoomStatus status;
  final int currentQuestionIndex;
  final int totalQuestions;
  final List<JamHoodQuestionItem> questions;
  final int questionStartTimeMs;
  final int timeLimitSeconds;
  final int totalAnswersSubmitted;
  final int createdAtMs;
  final int expiresAtMs;
  final bool questionStartFromServer;

  JamHoodRoom({
    required this.pin,
    required this.hostId,
    required this.status,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.questions,
    this.questionStartTimeMs = 0,
    this.timeLimitSeconds = 20,
    this.totalAnswersSubmitted = 0,
    this.createdAtMs = 0,
    this.expiresAtMs = 0,
    this.questionStartFromServer = false,
  });

  JamHoodQuestionItem? get currentQuestion {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  bool isExpired({int? atMs}) {
    if (expiresAtMs <= 0) return false; // legacy room with no TTL yet
    return (atMs ?? DateTime.now().millisecondsSinceEpoch) >= expiresAtMs;
  }

  bool isActiveLobby({int? atMs}) =>
      status == JamHoodRoomStatus.lobby && !isExpired(atMs: atMs);

  Map<String, dynamic> toMap() {
    return {
      'pin': pin,
      'hostId': hostId,
      'status': status.name,
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
      'questions': questions.map((q) => q.toMap()).toList(),
      'questionStartTimeMs': questionStartTimeMs,
      'timeLimitSeconds': timeLimitSeconds,
      'totalAnswersSubmitted': totalAnswersSubmitted,
      'createdAtMs': createdAtMs,
      'expiresAtMs': expiresAtMs,
    };
  }

  factory JamHoodRoom.fromMap(Map<String, dynamic> map) {
    var rawQuestions = (map['questions'] as List<dynamic>? ?? [])
        .map((q) => JamHoodQuestionItem.fromMap(Map<String, dynamic>.from(q as Map)))
        .toList();

    final int created = _readMillis(map['createdAtMs']) ?? 0;
    final int? serverStart = _readMillis(map['questionStartedAt']);
    final int legacyStart = _readMillis(map['questionStartTimeMs']) ?? 0;

    return JamHoodRoom(
      pin: map['pin']?.toString() ?? '',
      hostId: map['hostId']?.toString() ?? '',
      status: JamHoodRoomStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => JamHoodRoomStatus.lobby,
      ),
      currentQuestionIndex: (map['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? rawQuestions.length,
      questions: rawQuestions,
      questionStartTimeMs: (serverStart != null && serverStart > 0) ? serverStart : legacyStart,
      timeLimitSeconds: (map['timeLimitSeconds'] as num?)?.toInt() ?? 20,
      totalAnswersSubmitted: (map['totalAnswersSubmitted'] as num?)?.toInt() ?? 0,
      createdAtMs: created,
      expiresAtMs: _readMillis(map['expiresAtMs']) ??
          (created > 0 ? created + lobbyTtlMs : 0),
      questionStartFromServer: serverStart != null,
    );
  }
}

class JamHoodPlayer {
  final String id;
  final String nickname;
  final int score;
  final int streak;
  final bool hasAnswered;
  final int? selectedOption;
  final int lastPointsEarned;
  final bool isLastAnswerCorrect;
  final bool scoreFinalized;

  JamHoodPlayer({
    required this.id,
    required this.nickname,
    this.score = 0,
    this.streak = 0,
    this.hasAnswered = false,
    this.selectedOption,
    this.lastPointsEarned = 0,
    this.isLastAnswerCorrect = false,
    this.scoreFinalized = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'score': score,
      'streak': streak,
      'hasAnswered': hasAnswered,
      'selectedOption': selectedOption,
      'lastPointsEarned': lastPointsEarned,
      'isLastAnswerCorrect': isLastAnswerCorrect,
      'scoreFinalized': scoreFinalized,
    };
  }

  factory JamHoodPlayer.fromMap(Map<String, dynamic> map, String docId) {
    return JamHoodPlayer(
      id: docId,
      nickname: map['nickname']?.toString() ?? 'Player',
      score: (map['score'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      hasAnswered: map['hasAnswered'] == true,
      selectedOption: (map['selectedOption'] as num?)?.toInt(),
      lastPointsEarned: (map['lastPointsEarned'] as num?)?.toInt() ?? 0,
      isLastAnswerCorrect: map['isLastAnswerCorrect'] == true,
      scoreFinalized: map['scoreFinalized'] == true,
    );
  }
}
