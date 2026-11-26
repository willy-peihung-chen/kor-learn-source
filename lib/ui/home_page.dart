import 'package:flutter/material.dart';

import '../util/format.dart';
import 'about_page.dart';
import 'app_scope.dart';
import 'lesson_page.dart';
import 'progress_page.dart';
import 'review_page.dart';
import 'widgets.dart';

/// 首頁：今日學習。
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onNavigate});

  /// 切換主頁籤：0 首頁、1 課程、2 單字、3 測驗。
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final nextLesson = state.nextLesson;
    final due = state.dueCount;
    final fresh = state.newWordCount;
    final mistakes = state.mistakeSeeds.length;
    final accuracy = state.recentAccuracy;

    final reviewParts = <String>[
      if (due > 0) '$due 張單字卡到期',
      if (fresh > 0) newWordStatus(state),
      if (state.newReverseReadyCount > 0)
        '${state.newReverseReadyCount} 張中文→韓文新卡',
      if (mistakes > 0) '$mistakes 題錯題',
    ];

    void startLearning() {
      if (nextLesson != null) {
        openLesson(context, nextLesson);
      } else if (due > 0 ||
          state.newWordsAvailable > 0 ||
          state.newReverseReadyCount > 0) {
        onNavigate(2);
      } else {
        onNavigate(3);
      }
    }

    return PageBody(
      children: <Widget>[
        Text('今日學習', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          formatDate(state.now),
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 20),
        _TaskCard(
          icon: Icons.menu_book_outlined,
          title: '今日課程',
          detail: nextLesson == null
              ? '所有課程都已完成，可以隨時回頭重看。'
              : '下一課：${nextLesson.title}',
          done: state.didToday('lesson_completed'),
          actionLabel: nextLesson == null ? '查看課程' : '開始',
          onPressed: () {
            if (nextLesson == null) {
              onNavigate(1);
            } else {
              openLesson(context, nextLesson);
            }
          },
        ),
        _TaskCard(
          icon: Icons.quiz_outlined,
          title: '新知識練習',
          detail: accuracy == null
              ? '完成一組 10 題混合測驗，練習剛學過的內容。'
              : '完成一組 10 題混合測驗（近 ${state.recentAttemptCount} 題正確率 ${(accuracy * 100).round()}%）。',
          done: state.didToday('quiz'),
          actionLabel: '去測驗',
          onPressed: () => onNavigate(3),
        ),
        _TaskCard(
          icon: Icons.style_outlined,
          title: '舊知識複習',
          detail: reviewParts.isEmpty ? '目前沒有待複習的項目。' : reviewParts.join('、'),
          done: state.didToday('review'),
          actionLabel: '去複習',
          onPressed: () => onNavigate(2),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: startLearning,
          icon: const Icon(Icons.play_arrow),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('開始學習'),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => openProgress(context),
            icon: const Icon(Icons.insights_outlined, size: 18),
            label: const Text('學習進度（難記的字、錯題、各主題）'),
          ),
        ),
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

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.done,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool done;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              done ? Icons.check_circle : icon,
              color: done ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    done ? '$detail\n今天已完成。' : detail,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
