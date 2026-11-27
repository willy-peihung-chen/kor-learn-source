import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/content_models.dart';
import '../data/topic_groups.dart';
import '../data/word_levels.dart';
import '../state/app_state.dart';
import 'app_scope.dart';
import 'haeyo_form_line.dart';
import 'hanja_suffix_line.dart';
import 'progress_page.dart';
import 'review_page.dart';
import 'speak_button.dart';
import 'theme.dart';
import 'widgets.dart';

/// 「單字」頁籤：所有單字都依主題放在一起；從主題進去瀏覽、聽發音、開始複習。
class VocabHomePage extends StatelessWidget {
  const VocabHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final due = state.dueCount;
    final fresh = state.newWordCount;
    final hardCount = state.hardWordIds.length;
    final reverseReady = state.newReverseReadyCount;
    final reviewDetail = (due == 0 && fresh == 0 && reverseReady == 0)
        ? '目前沒有需要複習的單字。'
        : <String>[
            if (due > 0) '$due 張到期（每輪最多 ${AppState.dueCardsPerRound} 張）',
            if (fresh > 0) newWordStatus(state),
            if (reverseReady > 0) '$reverseReady 張中文→韓文新卡',
          ].join('、');

    return PageBody(
      children: <Widget>[
        Text('單字', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '已學 ${state.learnedWordCount} / ${Catalog.words.length} 個・'
          '${Catalog.topics.length} 個主題',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Row(
            children: <Widget>[
              Icon(Icons.style_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('單字複習', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      reviewDetail,
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => openReview(context),
                child: const Text('開始複習'),
              ),
            ],
          ),
        ),
        if (hardCount > 0) ...<Widget>[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => openProgress(context),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: Text('難記的字 $hardCount 個'),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text('主題', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '點進主題可以瀏覽單字、聽發音；也可以只複習那一個主題。'
          '主題裡的單字再依常用程度分段，先學前面的。',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        for (final group in groupTopics(Catalog.topics)) ...<Widget>[
          const SizedBox(height: 20),
          Text(
            '${group.title}・${group.topics.length} 個主題',
            style: theme.textTheme.titleSmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final twoColumns = constraints.maxWidth >= 560;
              final width = twoColumns
                  ? (constraints.maxWidth - gap) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (final topic in group.topics)
                    SizedBox(width: width, child: _TopicCard(topic: topic)),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final WordTopic topic;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final progress = state.topicProgress(topic.id);
    final due = state.dueCountOf(topic.id);

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TopicWordsPage(topic: topic)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(topic.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${topic.words.length} 個・已學 ${progress.learned}'
                  '${due > 0 ? '・到期 $due' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: topic.words.isEmpty
                        ? 0
                        : progress.learned / topic.words.length,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: muted),
        ],
      ),
    );
  }
}

/// 一個主題底下的單字清單：點單字那一列會念出單字。
class TopicWordsPage extends StatelessWidget {
  const TopicWordsPage({super.key, required this.topic});

  final WordTopic topic;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final groups = levelGroupsOf(topic);

    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: SafeArea(
        child: PageBody(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${topic.words.length} 個單字・點單字會念出來',
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => openReview(context, topic: topic),
                  icon: const Icon(Icons.style_outlined, size: 18),
                  label: const Text('複習這個主題'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '漢字詞可以用中文聯想，但意思不一定完全相同。',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            if (groups.length > 1) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '「基本用語」是問候、道謝、請求等最先用到的固定說法（編輯挑選，非官方分級）；'
                '之後依國立國語院學習用詞表的等級分段，1 級最常用；'
                '「其他」是詞表 3 級或詞表沒有列出的字；'
                '「較少用」是日常比較少聽到的字，先學前面的就好。',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
            for (final group in groups) ...<Widget>[
              if (groups.length > 1) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  '${group.level.label}・${group.level.hint}'
                  '（${group.words.length} 個）',
                  style: theme.textTheme.titleSmall,
                ),
              ],
              const SizedBox(height: 8),
              for (final word in group.words)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SectionCard(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                    onTap: () => speakText(context, word.hangul),
                    child: _WordRow(
                      word: word,
                      learned: !state.isNewWord(word.id),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word, required this.learned});

  final WordItem word;
  final bool learned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
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
            if (learned)
              Icon(
                Icons.check_circle_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            SpeakButton(text: word.hangul, tooltip: '朗讀單字', iconSize: 22),
          ],
        ),
        HanjaSuffixLine(word: word, compact: true),
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
