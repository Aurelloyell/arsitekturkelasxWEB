import 'package:flutter_test/flutter_test.dart';
import 'package:arsitektur_x_web/quiz_data.dart';

void main() {
  group('masterQuizList', () {
    test('has 62 questions with unique ids', () {
      expect(masterQuizList.length, 62);
      final ids = masterQuizList.map((q) => q.id).toSet();
      expect(ids.length, masterQuizList.length);
    });

    test('every question has valid options and a correct answer', () {
      for (final q in masterQuizList) {
        expect(q.text.trim().isNotEmpty, isTrue, reason: q.id);
        expect(q.options.length, greaterThanOrEqualTo(2), reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1), reason: q.id);
        expect(
          q.options.toSet().length,
          q.options.length,
          reason: '${q.id} has duplicate options',
        );
      }
    });

    test('every question has a learning explanation', () {
      for (final q in masterQuizList) {
        expect(q.explanation.trim().isNotEmpty, isTrue, reason: q.id);
      }
    });

    test('image questions point to declared asset paths', () {
      final withImages = masterQuizList.where((q) => q.imagePath != null);
      expect(withImages.length, 14);
      for (final q in withImages) {
        expect(q.imagePath, startsWith('assets/gambar/'), reason: q.id);
      }
    });
  });
}
