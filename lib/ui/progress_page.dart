import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/labels.dart';
import '../data/lessons.dart';
import 'about_page.dart';
import 'app_scope.dart';
import 'theme.dart';
import 'widgets.dart';

/// 學習進度：所有數字都來自實際的學習與測驗紀錄。
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final accuracy = state.recentAccuracy;
    final weak = state.weakItems;
    final recent = state.recentActivity(limit: 8);

    return PageBody(
      children: <Widget>[
        Text('學習進度', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '以下數字都來自你的實際學習與測驗紀錄，只保存在這台裝置上。',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            StatTile(
              label: '已完成課程',
              value: '${state.completedLessonCount} / ${Lessons.all.length}',
            ),
            StatTile(label: '已學習項目', value: '${state.learnedCount}'),
            StatTile(
              label: '已學單字',
              value: '${state.learnedWordCount}',
              caption: '共 ${Catalog.words.length} 個',
            ),
            StatTile(label: '待複習單字', value: '${state.dueCount}', caption: '張到期'),
            StatTile(
              label: '最近測驗正確率',
              value: accuracy == null ? '—' : '${(accuracy * 100).round()}%',
              caption: accuracy == null ? '尚無測驗紀錄' : '近 ${state.recentAttemptCount} 題',
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('各課程狀態', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final lesson in Lessons.all)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(lesson.title)),
                      const SizedBox(width: 8),
                      Text(
                        state.isLessonCompleted(lesson.id)
                            ? '已完成'
                            : '${state.learnedCardCount(lesson)} / ${lesson.cards.length}',
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('單字主題進度', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '「已學」指在單字複習中評估過的單字。',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              for (final topic in Catalog.topics)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(topic.title)),
                      const SizedBox(width: 8),
                      Text(
                        '${state.topicProgress(topic.id).learned} / ${topic.words.length}',
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('錯誤較多的項目', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (weak.isEmpty)
                Text(
                  '目前沒有錯誤紀錄。',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                )
              else
                for (final item in weak)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(itemLabel(item.itemId), style: hangulStyle(16)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '答錯 ${item.wrong} / ${item.total} 次',
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('最近學習紀錄', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                Text(
                  '還沒有學習紀錄。',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                )
              else
                ActivityList(entries: recent),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => openAbout(context),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('教材說明（來源、查核方式與限制）'),
          ),
        ),
      ],
    );
  }
}
