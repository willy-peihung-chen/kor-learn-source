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

  Widget _page() {
    switch (_index) {
      case 0:
        return HomePage(onNavigate: _goTo);
      case 1:
        return const LessonsPage();
      case 2:
        return const VocabHomePage();
      case 4:
        return const DictionaryPage();
      default:
        return const QuizHomePage();
    }
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
