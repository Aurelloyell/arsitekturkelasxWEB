import 'package:flutter_test/flutter_test.dart';
import 'package:arsitektur_x_web/models/jamhood_model.dart';

class _FakeTimestamp {
  final int millisecondsSinceEpoch;
  const _FakeTimestamp(this.millisecondsSinceEpoch);
}

JamHoodQuestionItem _question() => JamHoodQuestionItem(
      id: 'q1',
      questionText: 'Contoh soal?',
      options: const ['A', 'B', 'C', 'D'],
      correctIndex: 2,
    );

JamHoodRoom _room({
  JamHoodRoomStatus status = JamHoodRoomStatus.lobby,
  int createdAtMs = 1000,
  int expiresAtMs = 0,
}) =>
    JamHoodRoom(
      pin: '123456',
      hostId: 'host-1',
      status: status,
      currentQuestionIndex: 0,
      totalQuestions: 1,
      questions: [_question()],
      createdAtMs: createdAtMs,
      expiresAtMs: expiresAtMs == 0 ? createdAtMs + JamHoodRoom.lobbyTtlMs : expiresAtMs,
    );

void main() {
  group('JamHoodRoom', () {
    test('legacy room without an expiry is not treated as expired', () {
      final room = JamHoodRoom(
        pin: '123456',
        hostId: 'host-1',
        status: JamHoodRoomStatus.lobby,
        currentQuestionIndex: 0,
        totalQuestions: 1,
        questions: [_question()],
      );
      expect(room.isExpired(atMs: 9999999999999), isFalse);
      expect(room.isActiveLobby(atMs: 9999999999999), isTrue);
    });

    test('expiry is inclusive and excludes the room from active lobbies', () {
      final room = _room(createdAtMs: 1000, expiresAtMs: 5000);
      expect(room.isExpired(atMs: 4999), isFalse);
      expect(room.isActiveLobby(atMs: 4999), isTrue);
      expect(room.isExpired(atMs: 5000), isTrue);
      expect(room.isActiveLobby(atMs: 5000), isFalse);
    });

    test('only lobby rooms can be browsed as active', () {
      final room = _room(status: JamHoodRoomStatus.question);
      expect(room.isExpired(atMs: 2000), isFalse);
      expect(room.isActiveLobby(atMs: 2000), isFalse);
    });

    test('fromMap derives expiry from createdAt when missing', () {
      final room = JamHoodRoom.fromMap({
        'pin': '654321',
        'hostId': 'host-2',
        'status': 'lobby',
        'createdAtMs': 10000,
        'questions': [
          _question().toMap(),
        ],
      });
      expect(room.expiresAtMs, 10000 + JamHoodRoom.lobbyTtlMs);
      expect(room.questionStartFromServer, isFalse);
      expect(room.currentQuestion?.id, 'q1');
    });

    test('fromMap prefers the server questionStartedAt over legacy millis', () {
      final room = JamHoodRoom.fromMap({
        'pin': '654321',
        'hostId': 'host-2',
        'status': 'question',
        'questionStartedAt': const _FakeTimestamp(30000),
        'questionStartTimeMs': 20000,
        'questions': [],
      });
      expect(room.questionStartTimeMs, 30000);
      expect(room.questionStartFromServer, isTrue);
      expect(room.currentQuestion, isNull);
    });

    test('fromMap falls back to lobby for an unknown status', () {
      final room = JamHoodRoom.fromMap({
        'pin': '111111',
        'status': 'something-new',
        'questions': [],
      });
      expect(room.status, JamHoodRoomStatus.lobby);
    });

    test('question round-trips through toMap and fromMap', () {
      final map = _question().toMap();
      final restored = JamHoodQuestionItem.fromMap(map);
      expect(restored.id, 'q1');
      expect(restored.correctIndex, 2);
      expect(restored.options, ['A', 'B', 'C', 'D']);
      expect(restored.timeLimit, 20);
    });
  });

  group('JamHoodPlayer', () {
    test('fromMap uses the document id as the player id', () {
      final player = JamHoodPlayer.fromMap(
        {
          'nickname': 'Budi',
          'score': 1200,
          'streak': 3,
          'hasAnswered': true,
          'selectedOption': 1,
        },
        'player-doc-1',
      );
      expect(player.id, 'player-doc-1');
      expect(player.nickname, 'Budi');
      expect(player.score, 1200);
      expect(player.selectedOption, 1);
      expect(player.hasAnswered, isTrue);
    });

    test('fromMap restores the finalized answer result', () {
      final player = JamHoodPlayer.fromMap(
        {
          'nickname': 'Sari',
          'hasAnswered': true,
          'selectedOption': 2,
          'lastPointsEarned': 900,
          'isLastAnswerCorrect': true,
          'scoreFinalized': true,
        },
        'player-doc-2',
      );
      expect(player.scoreFinalized, isTrue);
      expect(player.isLastAnswerCorrect, isTrue);
      expect(player.lastPointsEarned, 900);
    });

    test('toMap round-trips the finalized answer result', () {
      final original = JamHoodPlayer(
        id: 'player-doc-3',
        nickname: 'Rina',
        hasAnswered: true,
        selectedOption: 0,
        lastPointsEarned: 1000,
        isLastAnswerCorrect: true,
        scoreFinalized: true,
      );
      final restored = JamHoodPlayer.fromMap(original.toMap(), original.id);
      expect(restored.selectedOption, 0);
      expect(restored.isLastAnswerCorrect, isTrue);
      expect(restored.scoreFinalized, isTrue);
    });
  });
}
