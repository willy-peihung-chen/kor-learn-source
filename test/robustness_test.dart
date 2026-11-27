import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/logic/srs.dart';
import 'package:hangul_app/state/app_state.dart';
import 'package:hangul_app/storage/progress_data.dart';
import 'package:hangul_app/storage/progress_repository.dart';

/// 存檔一定失敗的儲存庫，用來測試失敗提醒。
class _FailingRepository implements ProgressRepository {
  bool fail = true;

  @override
  Future<ProgressData> load() async => ProgressData();

  @override
  Future<void> save(ProgressData data) async {
    if (fail) {
      throw StateError('模擬存檔失敗');
    }
  }
}

void main() {
  group('舊版 App 不刪新版的資料', () {
    test('不認得的頂層欄位存檔時原樣寫回', () {
      final json = <String, dynamic>{
        'version': 1,
        'completedLessons': <String>['a'],
        'futureField': <String, dynamic>{'x': 1},
      };
      final data = ProgressData.fromJson(json);
      final out = data.toJson();
      expect(out['futureField'], <String, dynamic>{'x': 1});
      expect(out['completedLessons'], <String>['a']);
      // 再讀再存一次仍然保留。
      final again = ProgressData.fromJson(
          jsonDecode(jsonEncode(out)) as Map<String, dynamic>);
      expect(again.toJson()['futureField'], <String, dynamic>{'x': 1});
    });

    test('讀到較新的版本號：存檔時不降回舊版本號', () {
      final data = ProgressData.fromJson(<String, dynamic>{'version': 5});
      expect(data.toJson()['version'], 5);
      expect(ProgressData().toJson()['version'], ProgressData.schemaVersion);
    });

    test('認得的欄位不會被當成不認得的欄位重複寫入', () {
      final data = ProgressData.fromJson(<String, dynamic>{
        'version': 1,
        'reviews': <Object>[],
        'extraNewWords': 3,
      });
      expect(data.unknownFields, isEmpty);
    });
  });

  group('存檔失敗提醒', () {
    test('存檔失敗時 saveFailed 變成 true，恢復後變回 false', () async {
      final repo = _FailingRepository();
      final state = await AppState.load(repo);
      expect(state.saveFailed, isFalse);

      state.rateWord(Catalog.words.first.id, ReviewRating.normal);
      await state.flush();
      expect(state.saveFailed, isTrue);

      repo.fail = false;
      state.rateWord(Catalog.words[1].id, ReviewRating.normal);
      await state.flush();
      expect(state.saveFailed, isFalse);
    });
  });
}
