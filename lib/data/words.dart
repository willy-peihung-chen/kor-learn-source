import 'content_models.dart';
import 'vocab/all_topics.dart';

/// 全部單字（依主題順序攤平）。單字內容本身放在 `vocab/` 資料夾，一個主題一個檔案。
final List<WordItem> vocabularyWords = List<WordItem>.unmodifiable(
  <WordItem>[
    for (final topic in allWordTopics) ...topic.words,
  ],
);
