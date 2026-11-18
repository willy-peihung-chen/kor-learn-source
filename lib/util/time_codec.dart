/// 時間與字串互轉，供本地儲存使用。
String encodeTime(DateTime time) => time.toUtc().toIso8601String();

DateTime decodeTime(String text) => DateTime.parse(text).toLocal();
