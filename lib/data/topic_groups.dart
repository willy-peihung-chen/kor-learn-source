import 'content_models.dart';

/// 單字頁把主題分成幾大類顯示。
class TopicGroup {
  const TopicGroup(this.title, this.topics);

  final String title;
  final List<WordTopic> topics;
}

const String _lifeTitle = '生活主題';

/// 主題 id 的前綴（底線前面的部分）對應到的大類；沒有底線、或不在表內的歸「生活主題」。
const Map<String, String> _groupOfPrefix = <String, String>{
  'verbs': '動詞',
  'adjectives': '形容詞',
  'function': '代名詞、副詞與連接詞',
  'concepts': '抽象名詞',
};

/// 依主題 id 分類；大類與大類裡的主題都維持 [topics] 原本的順序。
List<TopicGroup> groupTopics(List<WordTopic> topics) {
  final order = <String>[];
  final byTitle = <String, List<WordTopic>>{};
  for (final topic in topics) {
    final prefix = topic.id.contains('_') ? topic.id.split('_').first : '';
    final title = _groupOfPrefix[prefix] ?? _lifeTitle;
    if (!byTitle.containsKey(title)) {
      order.add(title);
      byTitle[title] = <WordTopic>[];
    }
    byTitle[title]!.add(topic);
  }
  return <TopicGroup>[for (final t in order) TopicGroup(t, byTitle[t]!)];
}
