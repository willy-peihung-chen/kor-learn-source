/// 日期與時間的簡單格式化（不依賴額外套件）。
String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime t) => '${t.year}/${_two(t.month)}/${_two(t.day)}';

String formatDateTime(DateTime t) =>
    '${_two(t.month)}/${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
