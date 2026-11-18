import 'package:flutter_test/flutter_test.dart';
import 'package:arsitektur_x_web/services/jamhood_scoring.dart';

void main() {
  group('JamHoodScoring.calculatePoints', () {
    const timeLimit = 20;

    test('wrong answer always scores zero', () {
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: false,
          elapsedMs: 0,
          timeLimitSeconds: timeLimit,
          previousStreak: 0,
        ),
        0,
      );
    });

    test('fast correct answer scores the maximum base points', () {
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: true,
          elapsedMs: 0,
          timeLimitSeconds: timeLimit,
          previousStreak: 0,
        ),
        JamHoodScoring.maxBasePoints,
      );
    });

    test('at the end of the timer the speed ratio reaches its floor', () {
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: true,
          elapsedMs: timeLimit * 1000,
          timeLimitSeconds: timeLimit,
          previousStreak: 0,
        ),
        JamHoodScoring.maxBasePoints ~/ 2,
      );
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: true,
          elapsedMs: timeLimit * 500,
          timeLimitSeconds: timeLimit,
          previousStreak: 0,
        ),
        750,
      );
    });

    test('answers beyond the time limit lose all points', () {
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: true,
          elapsedMs: (timeLimit * 1000) + 1,
          timeLimitSeconds: timeLimit,
          previousStreak: 0,
        ),
        0,
      );
    });

    test('grace window accepts a slightly late answer', () {
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: true,
          elapsedMs: (timeLimit * 1000) + 750,
          timeLimitSeconds: timeLimit,
          previousStreak: 0,
          graceMs: 750,
        ),
        JamHoodScoring.maxBasePoints ~/ 2,
      );
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: true,
          elapsedMs: (timeLimit * 1000) + 751,
          timeLimitSeconds: timeLimit,
          previousStreak: 0,
          graceMs: 750,
        ),
        0,
      );
    });

    test('streak bonus grows then stops at the cap', () {
      final base = JamHoodScoring.calculatePoints(
        isCorrect: true,
        elapsedMs: 0,
        timeLimitSeconds: timeLimit,
        previousStreak: 0,
      );
      final second = JamHoodScoring.calculatePoints(
        isCorrect: true,
        elapsedMs: 0,
        timeLimitSeconds: timeLimit,
        previousStreak: 1,
      );
      final late = JamHoodScoring.calculatePoints(
        isCorrect: true,
        elapsedMs: 0,
        timeLimitSeconds: timeLimit,
        previousStreak: 20,
      );
      expect(second - base, JamHoodScoring.streakBonusStep);
      expect(late - base, JamHoodScoring.maxStreakBonus);
    });

    test('non-positive time limit cannot score', () {
      expect(
        JamHoodScoring.calculatePoints(
          isCorrect: true,
          elapsedMs: 0,
          timeLimitSeconds: 0,
          previousStreak: 0,
        ),
        0,
      );
    });
  });

  group('JamHoodScoring.nextStreak', () {
    test('correct answer increments and wrong answer resets', () {
      expect(
        JamHoodScoring.nextStreak(isCorrect: true, previousStreak: 3),
        4,
      );
      expect(
        JamHoodScoring.nextStreak(isCorrect: false, previousStreak: 3),
        0,
      );
      expect(
        JamHoodScoring.nextStreak(isCorrect: true, previousStreak: -5),
        1,
      );
    });
  });
}
