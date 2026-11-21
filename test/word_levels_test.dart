import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/content_models.dart';
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

    test('已知的字落在正確的等級', () {
      expect(wordLevelOf(_word('가다')), WordLevel.level1);
      expect(wordLevelOf(_word('가격')), WordLevel.level2);
      // 問候語不在詞表裡，歸「其他」。
      expect(wordLevelOf(_word('안녕하세요')), WordLevel.other);
    });

    test('三組加起來剛好是全部單字，而且 1 級、2 級都有字', () {
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
    });
  });

  group('依等級分組', () {
    test('段落依 1 級、2 級、其他排列，空的段落省略，段落內維持原順序', () {
      final words = <WordItem>[
        _word('안녕하세요'),
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

  group('片語主題與學習順序', () {
    test('問候語主題不分段，照原順序；一般主題依等級分段', () {
      final greetings = Catalog.topicById('greetings')!;
      expect(isPhraseTopic(greetings), isTrue);
      expect(levelGroupsOf(greetings).length, 1);
      expect(studyOrderOf(greetings), greetings.words);

      final verbs = Catalog.topicById('verbs_move')!;
      expect(isPhraseTopic(verbs), isFalse);
      expect(studyOrderOf(verbs),
          <WordItem>[for (final g in groupByLevel(verbs.words)) ...g.words]);
    });

    test('全部的學習順序：每個字剛好一次，片語主題在最前面，其餘等級不倒退', () {
      final order = globalStudyOrder(Catalog.topics);
      expect(order.length, Catalog.words.length);
      expect(order.map((w) => w.id).toSet().length, Catalog.words.length);
      final greetings = Catalog.topicById('greetings')!;
      expect(order.take(greetings.words.length), greetings.words);
      var last = 0;
      for (final word in order.skip(greetings.words.length)) {
        final rank = wordLevelOf(word).index;
        expect(rank, greaterThanOrEqualTo(last), reason: word.id);
        last = rank;
      }
    });

    test('片語主題的 id 都存在', () {
      for (final id in phraseTopicIds) {
        expect(Catalog.topicById(id), isNotNull, reason: id);
      }
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
