// lib/services/jamhood_service.dart
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/jamhood_model.dart';
import '../quiz_data.dart';
import 'jamhood_scoring.dart';

class JoinResult {
  final String? playerId;
  final String? error;
  bool get isSuccess => error == null && playerId != null;

  JoinResult({this.playerId, this.error});
}

class _PinOccupied implements Exception {}

class JamHoodService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _roomsCollection = 'jamhood_rooms';

  /// Absorbs the delay between the host's countdown hitting zero and the room
  /// status changing to reveal.
  static const int _answerGraceMs = 750;
  static const int _pinAttempts = 8;

  // ---------------------------------------------------------------------
  // Time helpers
  // ---------------------------------------------------------------------

  static String _generatePin() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static int nowMs() => DateTime.now().millisecondsSinceEpoch;

  static Future<void> _ensureServerTimeSync() async {}

  static Future<int> _serverNowMs() async => nowMs();

  // ---------------------------------------------------------------------
  // Room creation
  // ---------------------------------------------------------------------

  static List<JamHoodQuestionItem> _buildQuestions({
    required int questionCount,
    required int timeLimitSeconds,
  }) {
    final List<QuizQuestion> allPool = List.from(masterQuizList)..shuffle();
    final int count = min(questionCount, allPool.length);
    final List<JamHoodQuestionItem> formatted = [];

    for (int i = 0; i < count; i++) {
      final q = allPool[i];
      final List<String> source = List<String>.from(q.options);
      if (source.isEmpty) continue;

      final int correctPos =
          (q.correctIndex >= 0 && q.correctIndex < source.length)
              ? q.correctIndex
              : 0;
      final String correctText = source[correctPos];

      // Deduplicate so a question never renders the same choice twice.
      final Set<String> seen = <String>{correctText};
      final List<String> distractors = <String>[];
      for (final String option in source) {
        if (seen.add(option)) distractors.add(option);
      }
      distractors.shuffle();

      // Every multiplayer question gets exactly four choices, which is what the
      // four colour/shape answer slots are designed for.
      List<String> rawOptions = <String>[
        correctText,
        ...distractors.take(3),
      ];
      if (rawOptions.length < 4) {
        final Set<String> used = rawOptions.toSet();
        for (final QuizQuestion other in allPool) {
          for (final String option in other.options) {
            if (used.add(option)) rawOptions.add(option);
            if (rawOptions.length == 4) break;
          }
          if (rawOptions.length == 4) break;
        }
      }

      rawOptions.shuffle();
      formatted.add(
        JamHoodQuestionItem(
          id: 'q_${i + 1}',
          questionText: q.text,
          options: rawOptions,
          correctIndex: rawOptions.indexOf(correctText),
          timeLimit: timeLimitSeconds,
          imagePath: q.imagePath,
        ),
      );
    }
    return formatted;
  }

  static Future<String> createRoom({
    required String hostId,
    int questionCount = 10,
    int timeLimitSeconds = 20,
  }) async {
    final int now = await _serverNowMs();
    final questions = _buildQuestions(
      questionCount: questionCount,
      timeLimitSeconds: timeLimitSeconds,
    );

    for (int attempt = 0; attempt < _pinAttempts; attempt++) {
      final String pin = _generatePin();
      final room = JamHoodRoom(
        pin: pin,
        hostId: hostId,
        status: JamHoodRoomStatus.lobby,
        currentQuestionIndex: 0,
        totalQuestions: questions.length,
        questions: questions,
        questionStartTimeMs: 0,
        timeLimitSeconds: timeLimitSeconds,
        totalAnswersSubmitted: 0,
        createdAtMs: now,
        expiresAtMs: now + JamHoodRoom.lobbyTtlMs,
      );

      final ref = _firestore.collection(_roomsCollection).doc(pin);
      try {
        await _firestore.runTransaction<void>((tx) async {
          final existing = await tx.get(ref);
          if (existing.exists) throw _PinOccupied();
          tx.set(ref, room.toMap());
        });
        return pin;
      } on _PinOccupied {
        continue;
      }
    }

    throw Exception('Gagal membuat PIN unik. Silakan coba lagi.');
  }

  // ---------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------

  static Stream<JamHoodRoom?> streamRoom(String pin) {
    return _firestore
        .collection(_roomsCollection)
        .doc(pin)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return JamHoodRoom.fromMap(snapshot.data()!);
    });
  }

  static Stream<List<JamHoodPlayer>> streamPlayers(String pin) {
    return _firestore
        .collection(_roomsCollection)
        .doc(pin)
        .collection('players')
        .snapshots()
        .map((query) {
      final list = query.docs
          .map((doc) => JamHoodPlayer.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : a.nickname.compareTo(b.nickname);
      });
      return list;
    });
  }

  /// Lobbies only. Expired rooms are filtered on the client so this query needs
  /// no composite Firestore index, and empty results get an explicit UI state.
  static Stream<List<JamHoodRoom>> streamActiveLobbies() async* {
    await _ensureServerTimeSync();
    yield* _firestore
        .collection(_roomsCollection)
        .where('status', isEqualTo: JamHoodRoomStatus.lobby.name)
        .snapshots()
        .map((query) {
      final rooms = query.docs
          .map((doc) => JamHoodRoom.fromMap(doc.data()))
          .where((room) => room.isActiveLobby(atMs: nowMs()))
          .toList();
      rooms.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      return rooms;
    });
  }

  // ---------------------------------------------------------------------
  // Joining and host flow
  // ---------------------------------------------------------------------

  static Future<JoinResult> joinRoom({
    required String pin,
    required String nickname,
  }) async {
    await _ensureServerTimeSync();
    final roomRef = _firestore.collection(_roomsCollection).doc(pin);
    final roomDoc = await roomRef.get();
    if (!roomDoc.exists || roomDoc.data() == null) {
      return JoinResult(error: 'Room PIN tidak ditemukan!');
    }

    final room = JamHoodRoom.fromMap(roomDoc.data()!);
    if (room.isExpired(atMs: nowMs())) {
      unawaited(deleteRoom(pin));
      return JoinResult(error: 'Room sudah kedaluwarsa. Buat room baru.');
    }
    if (room.status != JamHoodRoomStatus.lobby) {
      return JoinResult(error: 'Game sudah dimulai atau selesai!');
    }

    final String playerId =
        'p_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final player = JamHoodPlayer(
      id: playerId,
      nickname: nickname.trim().isEmpty ? 'Player' : nickname.trim(),
    );

    await roomRef.collection('players').doc(playerId).set(player.toMap());
    return JoinResult(playerId: playerId);
  }

  static Future<void> leaveRoom({
    required String pin,
    required String playerId,
  }) async {
    try {
      await _firestore
          .collection(_roomsCollection)
          .doc(pin)
          .collection('players')
          .doc(playerId)
          .delete();
    } catch (_) {}
  }

  static Future<void> startCountdown(String pin, [int? nextQuestionIndex]) async {
    final Map<String, dynamic> updateData = {
      'status': JamHoodRoomStatus.countdown.name,
    };
    if (nextQuestionIndex != null) {
      updateData['currentQuestionIndex'] = nextQuestionIndex;
    }
    await _firestore.collection(_roomsCollection).doc(pin).update(updateData);
  }

  static Future<void> startQuestion(String pin, int questionIndex) async {
    final roomRef = _firestore.collection(_roomsCollection).doc(pin);
    final playersSnap = await roomRef.collection('players').get();

    final WriteBatch batch = _firestore.batch();
    for (final doc in playersSnap.docs) {
      batch.update(doc.reference, {
        'hasAnswered': false,
        'selectedOption': null,
        'lastPointsEarned': 0,
        'isLastAnswerCorrect': false,
        'scoreFinalized': false,
      });
    }

    final int now = nowMs();
    batch.update(roomRef, {
      'status': JamHoodRoomStatus.question.name,
      'currentQuestionIndex': questionIndex,
      'questionStartTimeMs': now,
      'questionStartedAt': FieldValue.serverTimestamp(),
      'questionStartSource': 'server',
      'totalAnswersSubmitted': 0,
    });

    await batch.commit();
  }

  // ---------------------------------------------------------------------
  // Answer submission
  // ---------------------------------------------------------------------

  /// Submits an answer and records the score atomically.
  ///
  /// Returns `true` when the answer was accepted and recorded, or `false` on error.
  static Future<bool> submitAnswer({
    required String pin,
    required String playerId,
    required int selectedIndex,
    required JamHoodQuestionItem question,
  }) async {
    final roomRef = _firestore.collection(_roomsCollection).doc(pin);
    final playerRef = roomRef.collection('players').doc(playerId);

    try {
      final int now = nowMs();

      final playerSnap = await playerRef.get();
      if (!playerSnap.exists || playerSnap.data() == null) {
        return false;
      }
      final Map<String, dynamic> playerData = playerSnap.data()!;
      if (playerData['hasAnswered'] == true && playerData['scoreFinalized'] == true) {
        return true; // Already recorded
      }

      final roomSnap = await roomRef.get();
      if (!roomSnap.exists || roomSnap.data() == null) return false;
      final room = JamHoodRoom.fromMap(roomSnap.data()!);
      if (room.status != JamHoodRoomStatus.question) return false;

      final int currentQIndex = room.currentQuestionIndex;
      if (currentQIndex < 0 || currentQIndex >= room.questions.length) {
        return false;
      }
      final JamHoodQuestionItem serverQuestion = room.questions[currentQIndex];

      if (selectedIndex < 0 || selectedIndex >= serverQuestion.options.length) {
        return false;
      }

      final int previousScore = (playerData['score'] as num?)?.toInt() ?? 0;
      final int previousStreak = (playerData['streak'] as num?)?.toInt() ?? 0;

      final int startTime = room.questionStartTimeMs > 0 ? room.questionStartTimeMs : now;
      final int elapsedMs = (now - startTime).clamp(0, (room.timeLimitSeconds + 5) * 1000);
      final bool isCorrect = selectedIndex == serverQuestion.correctIndex;

      final int points = JamHoodScoring.calculatePoints(
        isCorrect: isCorrect,
        elapsedMs: elapsedMs,
        timeLimitSeconds: room.timeLimitSeconds,
        previousStreak: previousStreak,
        graceMs: _answerGraceMs,
      );
      final int newStreak = JamHoodScoring.nextStreak(
        isCorrect: isCorrect,
        previousStreak: previousStreak,
      );

      await playerRef.update({
        'hasAnswered': true,
        'selectedOption': selectedIndex,
        'score': previousScore + points,
        'streak': newStreak,
        'lastPointsEarned': points,
        'isLastAnswerCorrect': isCorrect,
        'scoreFinalized': true,
      });

      await roomRef.update({
        'totalAnswersSubmitted': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> showReveal(String pin) async {
    await _firestore.collection(_roomsCollection).doc(pin).update({
      'status': JamHoodRoomStatus.reveal.name,
    });
  }

  static Future<void> showLeaderboard(String pin) async {
    await _firestore.collection(_roomsCollection).doc(pin).update({
      'status': JamHoodRoomStatus.leaderboard.name,
    });
  }

  static Future<void> advanceNext(
    String pin,
    int nextIndex,
    int totalQuestions,
  ) async {
    if (nextIndex >= totalQuestions) {
      await _firestore.collection(_roomsCollection).doc(pin).update({
        'status': JamHoodRoomStatus.finished.name,
      });
    } else {
      await startCountdown(pin, nextIndex);
    }
  }

  // ---------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------

  /// Firestore does not delete subcollections with their parent document.
  static Future<void> deleteRoom(String pin) async {
    try {
      final roomRef = _firestore.collection(_roomsCollection).doc(pin);
      final players = await roomRef.collection('players').limit(450).get();
      final WriteBatch batch = _firestore.batch();
      for (final doc in players.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(roomRef);
      await batch.commit();
    } catch (_) {
      // Room may already be gone. Nothing to clean up.
    }
  }

  /// Frees PINs left behind by closed tabs. Safe to call from the lobby hub.
  static Future<int> cleanupExpiredRooms() async {
    await _ensureServerTimeSync();
    final expired = await _firestore
        .collection(_roomsCollection)
        .where('expiresAtMs', isLessThan: nowMs())
        .limit(8)
        .get();

    final WriteBatch batch = _firestore.batch();
    for (final doc in expired.docs) {
      final players = await doc.reference.collection('players').limit(50).get();
      for (final player in players.docs) {
        batch.delete(player.reference);
      }
      batch.delete(doc.reference);
    }
    if (expired.docs.isNotEmpty) await batch.commit();
    return expired.docs.length;
  }
}
