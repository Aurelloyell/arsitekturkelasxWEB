import 'package:flutter_test/flutter_test.dart';
import 'package:arsitektur_x_web/basic_curriculum_data.dart';

void main() {
  test('Basic curriculum list has CP1 through CP5', () {
    expect(basicCurriculumList.length, 5);
    expect(
      basicCurriculumList.map((item) => item.id).toList(),
      ['cp1', 'cp2', 'cp3', 'cp4', 'cp5'],
    );
    for (final item in basicCurriculumList) {
      expect(item.content.trim().isNotEmpty, isTrue, reason: item.id);
      expect(item.title.trim().isNotEmpty, isTrue, reason: item.id);
      expect(item.description.trim().isNotEmpty, isTrue, reason: item.id);
    }
  });
}
