import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/content_models.dart';
import 'widgets.dart';

void openAbout(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AboutContentPage()),
  );
}

/// 教材說明：教材的來源、查核方式與限制，集中放在這一頁。
/// （各個學習畫面不再逐項標示查核狀態。）
class AboutContentPage extends StatelessWidget {
  const AboutContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final verifiedRoman = Catalog.letters
        .where((l) => l.romanStatus == ContentStatus.verified)
        .length;
    final exampleCount = Catalog.grammarExampleIds.length;

    Widget section(String title, List<String> lines) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      line,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('教材說明')),
      body: SafeArea(
        child: PageBody(
          children: <Widget>[
            Text(
              '這一頁說明 App 裡的教材從哪裡來、怎麼檢查，以及有哪些限制。',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 16),
            section('目前的教材量', <String>[
              '韓文字母：${Catalog.letters.length} 個基本字母，3 堂課。',
              '單字：${Catalog.words.length} 個，分成 ${Catalog.topics.length} 個主題。',
              '文法：${Catalog.grammarLessons.length} 堂課、${Catalog.grammarPoints.length} 個文法點、'
                  '$exampleCount 個填空例句。',
            ]),
            section('教材怎麼來的', <String>[
              '單字、例句、文法說明與中文翻譯，都是開發者自行整理的學習用教材，'
                  '沒有複製任何教科書或網站的內容。',
              '韓文字母的羅馬字標記中，有 $verifiedRoman 個已對照國立國語院網站上的說明頁面；'
                  '其餘教材沒有逐項對照過官方資料。',
              '單字表是依主題整理的常用詞，尚未對照 TOPIK 官方詞彙表，'
                  '所以不保證涵蓋或等同 TOPIK I 的考試範圍。',
              '詳細的來源與查核紀錄寫在專案的 docs/content_sources.md。',
            ]),
            section('怎麼檢查錯誤', <String>[
              '教材會由開發者不定期做整批的網路複查，核對單字意思、例句與文法規則；'
                  '發現問題才會修正教材並更新 App。',
              '網路資料本身也可能有誤，複查只能降低錯誤，不能保證完全正確。'
                  '重要的內容（例如要應考時），請再以官方教材或老師的說明為準。',
              '學習畫面上不再逐項標示「已查核／待查核」，避免給人過度精確的印象；'
                  '所有教材的狀態以這一頁的說明為準。',
            ]),
            section('使用上的注意事項', <String>[
              '朗讀是裝置或瀏覽器內建的機器語音，不是真人錄音，語調與少數字的發音可能和標準語有落差。',
              '羅馬字只是輔助標記，並不等於實際發音。',
              '漢字詞（韓文裡來自漢字的詞）可以幫助你用中文聯想，但意思和用法不一定和中文完全相同。',
              '有些韓文單字寫法相同、意思不同（例如 눈 可以是「雪」或「眼睛」），'
                  'App 會把它們分開收錄。',
              '動詞與形容詞以辭典形（-다 結尾）收錄，例句裡則使用實際的變化形。',
            ]),
            section('發現錯誤時', <String>[
              '目前沒有內建的回報功能。如果你發現單字或文法有錯，'
                  '請直接告訴開發者，教材會在下一次複查時一併修正。',
            ]),
          ],
        ),
      ),
    );
  }
}
