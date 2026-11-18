/// Pure scoring rules for JamHood. Kept free of Firestore so it can be tested.
class JamHoodScoring {
  static const int maxBasePoints = 1000;
  static const int streakBonusStep = 100;
  static const int maxStreakBonus = 500;
  static const double minimumSpeedRatio = 0.5;

  /// Points for a single answer.
  ///
  /// `elapsedMs` and `timeLimitSeconds` must both come from the server clock,
  /// never from a player's device. `graceMs` absorbs the gap between the host's
  /// on-screen timer reaching zero and the room status changing to reveal.
  static int calculatePoints({
    required bool isCorrect,
    required int elapsedMs,
    required int timeLimitSeconds,
    required int previousStreak,
    int graceMs = 0,
  }) {
    if (!isCorrect || timeLimitSeconds <= 0) return 0;

    final int allowedMs = timeLimitSeconds * 1000 + (graceMs > 0 ? graceMs : 0);
    if (elapsedMs > allowedMs) return 0;

    final double safeElapsed = elapsedMs < 0 ? 0 : elapsedMs.toDouble();
    final double ratio = (1.0 - (safeElapsed / (2.0 * timeLimitSeconds * 1000)))
        .clamp(minimumSpeedRatio, 1.0)
        .toDouble();

    int points = (maxBasePoints * ratio).round();

    final int streak = previousStreak + 1;
    if (streak > 1) {
      points += (streak - 1) * streakBonusStep > maxStreakBonus
          ? maxStreakBonus
          : (streak - 1) * streakBonusStep;
    }
    return points;
  }

  /// Streak after an answer. A wrong answer resets it.
  static int nextStreak({required bool isCorrect, required int previousStreak}) {
    if (!isCorrect) return 0;
    return previousStreak < 0 ? 1 : previousStreak + 1;
  }
}
