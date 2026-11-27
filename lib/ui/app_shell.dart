import 'package:flutter/material.dart';

import 'dictionary_page.dart';
import 'home_page.dart';
import 'lessons_page.dart';
import 'quiz_page.dart';
import 'vocab_page.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<_Destination> _destinations = <_Destination>[
  _Destination('首頁', Icons.home_outlined, Icons.home),
  _Destination('課程', Icons.menu_book_outlined, Icons.menu_book),
  _Destination('單字', Icons.style_outlined, Icons.style),
  _Destination('測驗', Icons.quiz_outlined, Icons.quiz),
  _Destination('辭典', Icons.search, Icons.search),
];

/// 主框架：窄螢幕用底部導覽列，寬螢幕（>= 860）改用左側導覽列。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  /// 五個分頁都留在畫面樹裡（只顯示目前這一個），切換分頁時保留各頁的狀態，
  /// 例如辭典的查詢字、測驗頁選的範圍、捲動位置。
  Widget _page() {
    final pages = <Widget>[
      HomePage(onNavigate: _goTo),
      const LessonsPage(),
      const VocabHomePage(),
      const QuizHomePage(),
      const DictionaryPage(),
    ];
    return IndexedStack(
      index: _index,
      children: <Widget>[
        // 隱藏的分頁不能取得焦點（例如用 Tab 鍵跳到辭典的輸入框）。
        for (var i = 0; i < pages.length; i++)
          ExcludeFocus(excluding: i != _index, child: pages[i]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        return Scaffold(
          body: SafeArea(
            child: wide
                ? Row(
                    children: <Widget>[
                      NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: _goTo,
                        labelType: NavigationRailLabelType.all,
                        destinations: <NavigationRailDestination>[
                          for (final d in _destinations)
                            NavigationRailDestination(
                              icon: Icon(d.icon),
                              selectedIcon: Icon(d.selectedIcon),
                              label: Text(d.label),
                            ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _page()),
                    ],
                  )
                : _page(),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _goTo,
                  destinations: <NavigationDestination>[
                    for (final d in _destinations)
                      NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}
