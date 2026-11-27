import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/content_models.dart';
import '../logic/dictionary.dart';
import 'haeyo_form_line.dart';
import 'hanja_suffix_line.dart';
import 'speak_button.dart';
import 'theme.dart';
import 'widgets.dart';

/// 「辭典」頁籤：輸入中文找對應的韓文單字（也可以輸入韓文反查）。
class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  static const int _limit = 50;
  static const List<String> _suggestions = <String>[
    '學生',
    '老師',
    '朋友',
    '咖啡',
    '謝謝',
    '多少',
  ];

  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _query = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    // 多查一筆，用來判斷結果是不是被截斷了。
    final found = DictionarySearch.all.search(_query, limit: _limit + 1);
    final truncated = found.length > _limit;
    final shown = truncated ? found.take(_limit).toList() : found;

    return PageBody(
      children: <Widget>[
        Text('辭典', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '輸入中文找對應的韓文，也可以輸入韓文反查。'
          '只查得到 App 內收錄的 ${Catalog.words.length} 個單字。',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          onChanged: (value) => setState(() => _query = value.trim()),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '輸入中文，例如：學生、喝、咖啡',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: '清除',
                    icon: const Icon(Icons.close),
                    onPressed: () => _setQuery(''),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_query.isEmpty) ...<Widget>[
          Text('試試看', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final s in _suggestions)
                ActionChip(label: Text(s), onPressed: () => _setQuery(s)),
            ],
          ),
        ] else if (shown.isEmpty)
          SectionCard(
            child: Text(
              '找不到「$_query」。辭典只收錄 App 內的單字，'
              '可以換成意思相近的說法再試一次（例如「謝謝」「喜歡」這類常用詞）。',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          )
        else ...<Widget>[
          Text(
            truncated ? '找到超過 $_limit 筆，只顯示最相關的 $_limit 筆。' : '找到 ${shown.length} 筆',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 8),
          for (final word in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SectionCard(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                onTap: () => speakText(context, word.hangul),
                child: _ResultCard(word: word),
              ),
            ),
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.word});

  final WordItem word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final topic = Catalog.topicOfWord(word.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: <Widget>[
                  Text(
                    word.hangul,
                    style: hangulStyle(22, weight: FontWeight.w600),
                  ),
                  Text(word.meaning, style: theme.textTheme.bodyLarge),
                  if (word.hanja != null)
                    Text(
                      '漢字：${word.hanja}',
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                ],
              ),
            ),
            SpeakButton(text: word.hangul, tooltip: '朗讀單字', iconSize: 22),
          ],
        ),
        if (topic != null)
          Text(
            '主題：${topic.title}',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        HanjaSuffixLine(word: word),
        HaeyoFormLine(word: word),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(word.example, style: hangulStyle(15)),
                  Text(
                    word.exampleMeaning,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  if (word.note != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      '用法：${word.note}',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            SpeakButton(text: word.example, tooltip: '朗讀例句', iconSize: 20),
          ],
        ),
      ],
    );
  }
}
