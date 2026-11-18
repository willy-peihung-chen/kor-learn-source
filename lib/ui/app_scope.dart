import 'package:flutter/widgets.dart';

import '../state/app_state.dart';

/// 把 [AppState] 提供給整個 widget 樹；狀態改變時依賴它的頁面會自動重建。
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
