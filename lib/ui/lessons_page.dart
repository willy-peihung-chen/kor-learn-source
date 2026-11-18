import 'package:flutter/material.dart';

import '../data/lessons.dart';
import 'app_scope.dart';
import 'lesson_page.dart';
import 'widgets.dart';

/// 每個分類底下的一句說明。
String _groupDescription(LessonGroup group) {
  switch (group) {
    case LessonGroup.hangul:
      return '先學會讀：母音、子音、送氣音與濃音、收尾音。';
    case LessonGroup.unit:
      return '依情境學會開口：自我介紹、點餐、問時間、購物、問路、交通、住宿。';
    case LessonGroup.grammar:
      return '句子怎麼組成：助詞、句尾、否定與請求、敬語。單元裡用到的文法也在這裡，方便集中複習。';
    case LessonGroup.casual:
      return '只對很熟的人說的半語。敬語學好之後再看。';
  }
}

/// 課程列表：上方用分類切換，下方只列出該分類的課程。
class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  LessonGroup _group = LessonGroup.values.first;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    List<Lesson> lessonsOf(LessonGroup g) =>
        Lessons.all.where((l) => l.group == g).toList();
    int doneOf(LessonGroup g) =>
        lessonsOf(g).where((l) => state.isLessonCompleted(l.id)).length;

    final lessons = lessonsOf(_group);

    return PageBody(
      children: <Widget>[
        Text('課程', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '選一個分類，建議依照順序從第一課開始。',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final g in LessonGroup.values)
              ChoiceChip(
                label: Text('${g.label}　${doneOf(g)}/${lessonsOf(g).length}'),
                selected: g == _group,
                showCheckmark: false,
                onSelected: (_) => setState(() => _group = g),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(_group.label, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          _groupDescription(_group),
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final columns = constraints.maxWidth >= 600 ? 2 : 1;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (var i = 0; i < lessons.length; i++)
                  SizedBox(
                    width: width,
                    child: _LessonTile(number: i + 1, lesson: lessons[i]),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.number, required this.lesson});

  final int number;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final done = state.isLessonCompleted(lesson.id);

    return SectionCard(
      padding: const EdgeInsets.all(16),
      onTap: () => openLesson(context, lesson),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? scheme.primary : scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: done
                ? Icon(Icons.check, size: 18, color: scheme.onPrimary)
                : Text(
                    '$number',
                    style: theme.textTheme.labelLarge?.copyWith(color: muted),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(lesson.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  lesson.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 8),
                Text(
                  done
                      ? '已完成'
                      : '已看 ${state.learnedCardCount(lesson)} / ${lesson.cards.length} 張卡片',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: done ? scheme.primary : muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
