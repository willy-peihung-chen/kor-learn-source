import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'progress_data.dart';

/// 學習紀錄的儲存介面。UI 與邏輯只依賴這個介面，
/// 之後要加上手機與電腦同步時，只需要新增另一個實作。
abstract class ProgressRepository {
  Future<ProgressData> load();

  Future<void> save(ProgressData data);
}

/// 以 shared_preferences 保存成一段 JSON（Web 使用 localStorage）。
class SharedPrefsProgressRepository implements ProgressRepository {
  SharedPrefsProgressRepository(this._prefs);

  static const String storageKey = 'hangul_progress_v1';
  static const String corruptBackupKey = 'hangul_progress_v1.corrupt';

  final SharedPreferences _prefs;

  @override
  Future<ProgressData> load() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) {
      return ProgressData();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ProgressData.fromJson(decoded);
      }
    } catch (_) {
      // 落到下方：保留原始內容作備份，改用空白紀錄。
    }
    await _prefs.setString(corruptBackupKey, raw);
    return ProgressData();
  }

  @override
  Future<void> save(ProgressData data) async {
    final ok = await _prefs.setString(storageKey, jsonEncode(data.toJson()));
    if (!ok) {
      throw StateError('瀏覽器拒絕寫入學習紀錄（可能是儲存空間不足）');
    }
  }
}

/// 只存在記憶體中的實作，測試用。
class MemoryProgressRepository implements ProgressRepository {
  MemoryProgressRepository([this._stored]);

  String? _stored;

  @override
  Future<ProgressData> load() async {
    final raw = _stored;
    if (raw == null) {
      return ProgressData();
    }
    return ProgressData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(ProgressData data) async {
    _stored = jsonEncode(data.toJson());
  }
}
