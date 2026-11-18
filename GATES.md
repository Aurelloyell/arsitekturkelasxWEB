# Completion gates

Observable outcomes for this fix batch. `flutter`/`node` are unavailable in this shell, so
static outcomes use PowerShell checks that run here; Dart compilation/tests are recorded as
manual gates with the exact command to run when the Flutter SDK is available.

## G1 - SDK + assets declared (pubspec)
- [ ] CHECK: `Select-String -Path pubspec.yaml -Pattern "sdk: '>=3\.10\.0 <4\.0\.0'" -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path pubspec.yaml -Pattern 'assets/gambar/cp1/' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path pubspec.yaml -Pattern 'assets/glb/cp1/' -Quiet` | EXPECT: True

## G2 - duplicate/dead trees removed
- [ ] CHECK: `@('lib/gambar','lib/glb','web/assets','assets/3d','assets/mp4','assets/materi','assets/icon','assets/images') | Where-Object { Test-Path $_ }` | EXPECT: empty
- [ ] CHECK: `Get-ChildItem web -File | Where-Object { $_.Extension -in '.glb','.jpg','.webp' }` | EXPECT: empty

## G3 - web metadata + single model-viewer source
- [ ] CHECK: `Select-String -Path web/index.html -Pattern 'ajax.googleapis.com|unpkg.com/model-viewer' -Quiet` | EXPECT: False
- [ ] CHECK: `Select-String -Path web/index.html -Pattern 'playUiSound' -Quiet` | EXPECT: True

## G4 - portable audio service
- [ ] CHECK: `Select-String -Path lib/services/audio_effects_service.dart -Pattern 'dart:js_interop' -Quiet` | EXPECT: False
- [ ] CHECK: `Test-Path lib/services/audio_effects_web.dart -and Test-Path lib/services/audio_effects_stub.dart` | EXPECT: True

## G5 - dead screens removed / content pipeline
- [ ] CHECK: `@('lib/screens/materi_page.dart','lib/screens/materi_page backup.dart','lib/screens/materi_page backup2.dart','lib/screens/evaluation_page Gk Kepake.dart') | Where-Object { Test-Path $_ }` | EXPECT: empty
- [ ] CHECK: `Select-String -Path lib/basic_curriculum_data.dart -Pattern "id: 'cp3'" -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/chapter_detail_page.dart -Pattern 'kDebugMode' -Quiet` | EXPECT: True

## G6 - JamHood state/security
- [ ] CHECK: `Select-String -Path lib/services/jamhood_service.dart -Pattern 'serverTimeOffsetMs|streamActiveLobbies|hasRoomExpired' -Quiet` | EXPECT: True
- [ ] CHECK: `Test-Path firestore.rules` | EXPECT: True

## G7 - player question visibility + solo learning loop
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_player_page.dart -Pattern 'questionText|shuffledOptions' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/quiz_page.dart -Pattern 'Timer|explanation|bestScore' -Quiet` | EXPECT: True

## G8 - explanations for every question
- [ ] CHECK: `(Select-String -Path lib/quiz_data.dart -Pattern 'QuizQuestion\($').Count` | EXPECT: 62
- [ ] CHECK: `(Select-String -Path lib/quiz_data.dart -Pattern 'explanation:').Count` | EXPECT: 62

## G9 - shared widgets
- [ ] CHECK: `Test-Path lib/widgets/materi_detail_widgets.dart` | EXPECT: True

## G10 - tests
- [ ] CHECK: `(Get-ChildItem test -Filter '*_test.dart' -File).Count -ge 4` | EXPECT: True

## G11 - 3D/AR model viewer renders on web
- [ ] CHECK: `Select-String -Path web/index.html -Pattern 'assets/packages/model_viewer_plus/assets/model-viewer.min.js' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/pembelajaran_detail_page.dart -Pattern '_resolveModelAssetSrc' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path pubspec.yaml -Pattern 'assets/glb/cp1/' -Quiet` | EXPECT: True
- [ ] CHECK: `Test-Path assets/glb/cp1/low_poly_house_3.glb` | EXPECT: True
- [ ] CHECK: `Test-Path "$env:LOCALAPPDATA/Pub/Cache/hosted/pub.dev/model_viewer_plus-1.8.0/assets/model-viewer.min.js"` | EXPECT: True

## G12 - compile + test (manual, Flutter SDK required)
- MANUAL: run `flutter pub get`, `flutter analyze`, `flutter test` from repo root.
- EXPECT: zero analyzer errors and all tests pass. Evidence: paste command output.

## G13 - quiz hub without hostless "Room Aktif" list
- [ ] CHECK: `Select-String -Path lib/screens/quiz_page.dart -Pattern 'Room Aktif|_buildActiveLobbiesSection' -Quiet` | EXPECT: False
- [ ] CHECK: `Select-String -Path lib/screens/quiz_page.dart -Pattern 'Buat Room \(Host\)|Gabung dengan PIN|Latihan Mandiri|ATAU PILIH MODE LAIN' -Quiet` | EXPECT: True

## G14 - JamHood answer layout, image zoom, timer sync
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_player_page.dart -Pattern 'mainAxisExtent|_buildAnswerGrid' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_host_page.dart -Pattern '_buildAnswerGrid|_closeQuestionImage' -Quiet` | EXPECT: True
- [ ] CHECK: `Test-Path lib/widgets/zoomable_image_dialog.dart` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_player_page.dart -Pattern '_closeImagePreview' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/services/jamhood_service.dart -Pattern 'rawOptions.length == 4' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_player_page.dart,lib/screens/jamhood/jamhood_host_page.dart -Pattern 'childAspectRatio' -Quiet` | EXPECT: False
- [ ] CHECK: `Select-String -Path lib/services/jamhood_service.dart -Pattern 'serverQuestion.correctIndex' -Quiet` | EXPECT: True

## G15 - atomic answer scoring + honest reveal
- [ ] CHECK: `Select-String -Path lib/services/jamhood_service.dart -Pattern 'static Future<bool> submitAnswer' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/services/jamhood_service.dart -Pattern 'answeredSnap|freshRoomSnap' -Quiet` | EXPECT: False
- [ ] CHECK: `Select-String -Path lib/services/jamhood_service.dart -Pattern "'scoreFinalized': true" -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_player_page.dart -Pattern 'me\?\.scoreFinalized == true' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_player_page.dart -Pattern 'selected == q\.correctIndex' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path lib/screens/jamhood/jamhood_player_page.dart -Pattern "me\?\.id \?\? widget\.playerId" -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path firestore.rules -Pattern 'function unchanged\(' -Quiet` | EXPECT: True
- [ ] CHECK: `Select-String -Path test/jamhood_model_test.dart -Pattern 'scoreFinalized' -Quiet` | EXPECT: True
- MANUAL: run `flutter analyze` and `flutter test` once the SDK is available.
