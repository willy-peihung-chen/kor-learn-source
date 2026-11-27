import 'package:flutter/material.dart';

import 'app_scope.dart';

/// 包住每一頁：學習紀錄存檔失敗時，在畫面最上方顯示提醒；存檔恢復正常後自動消失。
///
/// 存檔失敗時畫面上的資料看起來一切正常，但重新整理後就會不見，所以一定要讓使用者知道。
class SaveStatusBanner extends StatelessWidget {
  const SaveStatusBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final failed = AppScope.of(context).saveFailed;
    final theme = Theme.of(context);
    // 不管有沒有失敗都用同一個 Column，頁面（Navigator）在畫面樹裡的位置固定，
    // 提醒出現或消失時不會重建頁面、輸入框也不會失去焦點。
    return Column(
      children: <Widget>[
        if (failed)
          Material(
            color: theme.colorScheme.errorContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '學習紀錄無法儲存：重新整理後，剛才的紀錄可能會不見。'
                        '請確認瀏覽器沒有封鎖網站資料、儲存空間足夠。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          key: const ValueKey<String>('page'),
          // 提醒已經留過上方安全區域，下面的頁面不用再留一次。
          child: MediaQuery.removePadding(
            context: context,
            removeTop: failed,
            child: child,
          ),
        ),
      ],
    );
  }
}
