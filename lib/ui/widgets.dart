import 'package:flutter/material.dart';

import '../storage/progress_data.dart';
import '../util/format.dart';

/// 頁面主體：置中、限制最大寬度，寬螢幕不會把內容拉得過長。
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = 760});

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          // 分頁同時存在（IndexedStack），不共用 PrimaryScrollController。
          primary: false,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: children,
        ),
      ),
    );
  }
}

/// 白底、細邊框的區塊；給 [onTap] 時整塊可點擊。
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 數字統計方塊。
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return SizedBox(
      width: 150,
      child: SectionCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.headlineSmall),
            if (caption != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                caption!,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String describeActivity(ActivityEntry entry) {
  switch (entry.type) {
    case 'lesson_completed':
      return '完成課程：${entry.label}';
    case 'review':
      return '單字複習 ${entry.count} 張';
    default:
      return entry.label;
  }
}

IconData _activityIcon(String type) {
  switch (type) {
    case 'lesson_completed':
      return Icons.menu_book_outlined;
    case 'review':
      return Icons.style_outlined;
    default:
      return Icons.quiz_outlined;
  }
}

/// 最近學習紀錄清單。
class ActivityList extends StatelessWidget {
  const ActivityList({super.key, required this.entries});

  final List<ActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      children: <Widget>[
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: <Widget>[
                Icon(_activityIcon(entry.type), size: 18, color: muted),
                const SizedBox(width: 10),
                Expanded(child: Text(describeActivity(entry))),
                const SizedBox(width: 8),
                Text(
                  formatDateTime(entry.at),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
