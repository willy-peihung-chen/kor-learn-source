import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/content_models.dart';
import 'package:hangul_app/data/essential_words.dart';
import 'package:hangul_app/data/late_words.dart';
import 'package:hangul_app/data/topic_groups.dart';
import 'package:hangul_app/data/word_level_data.dart';
import 'package:hangul_app/data/word_levels.dart';

WordItem _word(String hangul) =>
    Catalog.words.firstWhere((w) => w.hangul == hangul);

void main() {
  group('單字等級', () {
    test('等級表只記 1、2 級，而且每一個都是單字庫裡的字', () {
      final hangul = Catalog.words.map((w) => w.hangul).toSet();
      for (final entry in wordLevelData.entries) {
        expect(hangul.contains(entry.key), isTrue, reason: entry.key);
        expect(<int>[1, 2].contains(entry.value), isTrue, reason: entry.key);
      }
    });

    test('「較少用」名單：每一個都是單字庫裡唯一的字', () {
      for (final hangul in lateWordHangul) {
        final matches = Catalog.words.where((w) => w.hangul == hangul).toList();
        expect(matches.length, 1, reason: '$hangul 必須剛好在單字庫出現一次');
        expect(wordLevelOf(matches.first), WordLevel.later, reason: hangul);
      }
    });

    test('「基本用語」名單：每一個都是單字庫裡唯一的字，而且不在詞表、也不在較少用', () {
      for (final hangul in essentialWordHangul) {
        final matches = Catalog.words.where((w) => w.hangul == hangul).toList();
        expect(matches.length, 1, reason: '$hangul 必須剛好在單字庫出現一次');
        expect(wordLevelOf(matches.first), WordLevel.essential, reason: hangul);
        expect(wordLevelData.containsKey(hangul), isFalse, reason: hangul);
        expect(lateWordHangul.contains(hangul), isFalse, reason: hangul);
      }
    });

    test('「較少用」排在最後，不管詞表等級', () {
      expect(wordLevelOf(_word('그녀')), WordLevel.later);
      expect(wordLevelOf(_word('가다')), WordLevel.level1);
      final groups = groupByLevel(<WordItem>[
        _word('그녀'),
        _word('예의'),
        _word('가격'),
        _word('가다'),
        _word('안녕하세요'),
      ]);
      expect(groups.map((g) => g.level).toList(), <WordLevel>[
        WordLevel.essential,
        WordLevel.level1,
        WordLevel.level2,
        WordLevel.other,
        WordLevel.later,
      ]);
    });

    test('已知的字落在正確的等級', () {
      expect(wordLevelOf(_word('가다')), WordLevel.level1);
      expect(wordLevelOf(_word('가격')), WordLevel.level2);
      // 問候語不在詞表裡，是編輯挑選的「基本用語」；非固定說法的詞表外單字歸「其他」。
      expect(wordLevelOf(_word('안녕하세요')), WordLevel.essential);
      expect(wordLevelOf(_word('예의')), WordLevel.other);
      expect(wordLevelOf(_word('여쭙다')), WordLevel.later);
    });

    test('各組加起來剛好是全部單字，而且 1 級、2 級都有字', () {
      var total = 0;
      final counts = <WordLevel, int>{};
      for (final group in groupByLevel(Catalog.words)) {
        counts[group.level] = group.words.length;
        total += group.words.length;
      }
      expect(total, Catalog.words.length);
      expect(counts[WordLevel.level1], greaterThan(500));
      expect(counts[WordLevel.level2], greaterThan(300));
      expect(counts[WordLevel.other], greaterThan(0));
      expect(counts[WordLevel.essential], essentialWordHangul.length);
    });
  });

  group('依等級分組', () {
    test('段落依等級排列，空的段落省略，段落內維持原順序', () {
      final words = <WordItem>[
        _word('예의'),
        _word('가격'),
        _word('가다'),
        _word('오다'),
      ];
      final groups = groupByLevel(words);
      expect(groups.map((g) => g.level).toList(), <WordLevel>[
        WordLevel.level1,
        WordLevel.level2,
        WordLevel.other,
      ]);
      expect(
        groups.first.words.map((w) => w.hangul).toList(),
        <String>['가다', '오다'],
      );
      expect(groupByLevel(<WordItem>[_word('가다')]).length, 1);
      expect(groupByLevel(<WordItem>[]), isEmpty);
    });
  });

  group('學習順序', () {
    test('每個主題都依等級分段，段落內維持主題原本的順序', () {
      for (final topic in Catalog.topics) {
        final groups = levelGroupsOf(topic);
        expect(groups.map((g) => g.words.length).fold<int>(0, (a, b) => a + b),
            topic.words.length, reason: topic.id);
        var last = -1;
        for (final group in groups) {
          expect(group.level.index, greaterThan(last), reason: topic.id);
          last = group.level.index;
          final positions = group.words.map(topic.words.indexOf).toList();
          expect(positions, <int>[...positions]..sort(), reason: topic.id);
        }
        expect(studyOrderOf(topic).toSet().length, topic.words.length);
      }
    });

    test('問候語與禮貌與敬語主題也分段：基本用語在前、較少用在最後', () {
      final polite = Catalog.topicById('polite')!;
      final groups = levelGroupsOf(polite);
      expect(groups.first.level, WordLevel.essential);
      expect(groups.last.level, WordLevel.later);
      expect(groups.last.words.map((w) => w.hangul),
          containsAll(<String>['여쭙다', '진지', '웃어른']));
    });

    test('全部的學習順序：每個字剛好一次，等級不倒退', () {
      final order = globalStudyOrder(Catalog.topics);
      expect(order.length, Catalog.words.length);
      expect(order.map((w) => w.id).toSet().length, Catalog.words.length);
      var last = 0;
      for (final word in order) {
        final rank = wordLevelOf(word).index;
        expect(rank, greaterThanOrEqualTo(last), reason: word.id);
        last = rank;
      }
      expect(wordLevelOf(order.first), WordLevel.essential);
      expect(wordLevelOf(order.last), WordLevel.later);
    });
  });

  group('主題分類', () {
    test('每個主題剛好出現一次，順序不變', () {
      final groups = groupTopics(Catalog.topics);
      final ids = <String>[
        for (final g in groups) for (final t in g.topics) t.id,
      ];
      expect(ids.toSet().length, Catalog.topics.length);
      expect(ids.length, Catalog.topics.length);
      // 同一類裡的主題維持原本相對順序。
      final order = <String, int>{
        for (var i = 0; i < Catalog.topics.length; i++) Catalog.topics[i].id: i,
      };
      for (final g in groups) {
        final positions = g.topics.map((t) => order[t.id]!).toList();
        expect(positions, <int>[...positions]..sort(), reason: g.title);
      }
    });

    test('大主題已拆小：沒有主題超過 70 個字，動詞等分成多個主題', () {
      for (final topic in Catalog.topics) {
        expect(topic.words.length, lessThanOrEqualTo(70), reason: topic.id);
      }
      final groups = {
        for (final g in groupTopics(Catalog.topics)) g.title: g.topics,
      };
      expect(groups['生活主題'], isNotEmpty);
      for (final title in <String>['動詞', '形容詞', '代名詞、副詞與連接詞', '抽象名詞']) {
        expect(groups[title]!.length, greaterThan(1), reason: title);
      }
      // 第一個大類是生活主題，第一個主題維持「問候與日常表達」（widget 測試依賴）。
      expect(groupTopics(Catalog.topics).first.title, '生活主題');
      expect(groupTopics(Catalog.topics).first.topics.first.id,
          Catalog.topics.first.id);
    });
  });
}
