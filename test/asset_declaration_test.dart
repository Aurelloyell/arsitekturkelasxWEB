import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arsitektur_x_web/quiz_data.dart';

List<String> _declaredAssetDirectories(String pubspec) {
  final declared = <String>[];
  bool inAssets = false;
  for (final line in pubspec.split('\n')) {
    final trimmed = line.trim();
    if (trimmed == 'assets:') {
      inAssets = true;
      continue;
    }
    if (!inAssets) continue;
    if (trimmed.startsWith('- ')) {
      declared.add(trimmed.substring(2).trim());
    } else if (trimmed.isNotEmpty) {
      inAssets = false;
    }
  }
  return declared;
}

void main() {
  group('asset declarations', () {
    late String pubspec;
    late List<String> declared;

    setUpAll(() {
      pubspec = File('pubspec.yaml').readAsStringSync();
      declared = _declaredAssetDirectories(pubspec);
    });

    test('pubspec declares the six asset directories', () {
      expect(
        declared,
        containsAll([
          'assets/gambar/cp1/',
          'assets/gambar/cp2/Jalan/',
          'assets/gambar/cp2/Jembatan/',
          'assets/gambar/cp2/Perkerasan_Jalan/',
          'assets/gambar/cp2/Umum/',
          'assets/glb/cp1/',
        ]),
      );
    });

    test('every quiz image is covered by a declared directory and exists', () {
      final imageQuestions = masterQuizList.where((q) => q.imagePath != null);
      expect(imageQuestions.length, greaterThan(0));
      for (final question in imageQuestions) {
        final path = question.imagePath!;
        expect(
          declared.any(path.startsWith),
          isTrue,
          reason: '$path is not covered by $declared',
        );
        expect(File(path).existsSync(), isTrue, reason: 'missing asset: $path');
      }
    });

    test('declared directories exist on disk', () {
      for (final dir in declared) {
        expect(Directory(dir).existsSync(), isTrue, reason: 'missing dir: $dir');
      }
    });

    test('the bundled GLB model is present', () {
      expect(
        File('assets/glb/cp1/low_poly_house_3.glb').existsSync(),
        isTrue,
      );
    });

    test('the web entrypoint does not pin its own model viewer script', () {
      final html = File('web/index.html').readAsStringSync();
      expect(html, isNot(contains('ajax.googleapis.com')));
      expect(html, isNot(contains('unpkg.com/model-viewer')));
      expect(html, contains('playUiSound'));
    });
  });
}
