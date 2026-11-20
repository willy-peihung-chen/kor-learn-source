import '../content_models.dart';

const GrammarLessonData grammarRequests = GrammarLessonData(
  id: 'requests',
  title: '否定、願望與請求',
  summary: '學會說「不…」「沒辦法…」「想要…」「請…」「請不要…」。',
  intros: <GrammarIntro>[
    GrammarIntro(
      id: 'negation_intro',
      title: '兩種否定：안 與 못',
      paragraphs: <String>[
        '「안」＝不（單純不做，或不是某狀態）；「못」＝無法（想做但做不到，或能力不足）。',
        '兩者都放在動詞或形容詞前面：안 가요（不去）、못 가요（去不了）。',
        '「名詞＋하다」的動詞，안／못放在「하다」前面：공부 안 해요、운동 못 해요。',
      ],
    ),
  ],
  points: <GrammarPoint>[
    GrammarPoint(
      id: 'an',
      title: '안（不）',
      form: '안＋動詞／形容詞　或　語幹＋지 않아요',
      explanation: <String>[
        '表示單純的否定或意志上的「不」。',
        '還有另一種寫法：語幹＋「-지 않아요」，語氣稍正式一些，例如「비싸지 않아요」（不貴）。',
      ],
      examples: <GrammarExample>[
        GrammarExample('커피를 [안] 마셔요.', '不喝咖啡。', <String>['못', '없', '아니']),
        GrammarExample('오늘은 학교에 [안] 가요.', '今天不去學校。', <String>['못', '없', '아니']),
        GrammarExample('비싸지 [않아요].', '不貴。', <String>['안 해요', '못해요', '없어요']),
      ],
    ),
    GrammarPoint(
      id: 'mot',
      title: '못（無法）',
      form: '못＋動詞　或　語幹＋지 못해요',
      explanation: <String>[
        '表示因為能力不足或情況不允許而「做不到」。',
        '「못」通常只搭配動詞，不搭配形容詞。',
      ],
      examples: <GrammarExample>[
        GrammarExample('한국어를 [못] 해요.', '不會說韓語。', <String>['안', '없', '아니']),
        GrammarExample('수영을 [못] 해요.', '不會游泳。', <String>['안', '없', '아니']),
        GrammarExample('오늘은 바빠서 [못] 가요.', '今天太忙去不了。', <String>['안', '없', '아니']),
      ],
    ),
    GrammarPoint(
      id: 'go_sipeoyo',
      title: '-고 싶어요（想要…）',
      form: '語幹＋고 싶어요',
      explanation: <String>[
        '表示說話者「想要做某事」。語幹不需要判斷終聲或母音，直接接「-고 싶어요」。',
        '這個句型通常用於第一人稱（我）或詢問對方「你想…嗎？」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('한국에 [가고 싶어요].', '想去韓國。', <String>['가고 있어요', '갈 거예요', '갔어요']),
        GrammarExample('커피를 [마시고 싶어요].', '想喝咖啡。', <String>['마시고 있어요', '마셨어요', '마실 거예요']),
        GrammarExample('한국어를 [배우고 싶어요].', '想學韓文。', <String>['배우고 있어요', '배웠어요', '배울 거예요']),
      ],
    ),
    GrammarPoint(
      id: 'euseyo',
      title: '-(으)세요（請…、敬語現在式）',
      form: '語幹無終聲＋세요　有終聲＋으세요',
      explanation: <String>[
        '兩種用法：一是對長輩、尊敬的對象說「請…」；二是敘述長輩的動作，是「敬語」的現在式。',
        '語幹無終聲接「세요」：가다 → 가세요；有終聲接「으세요」：앉다 → 앉으세요。',
        '「하다」類：말하다 → 말하세요。',
        '少數動詞有專用的敬語詞，例如 먹다 → 드세요，這些之後再補充。',
      ],
      examples: <GrammarExample>[
        GrammarExample('여기에 [앉으세요].', '請坐這裡。', <String>['앉세요', '앉아세요', '앉습니다']),
        GrammarExample('천천히 [말하세요].', '請慢慢說。', <String>['말하으세요', '말해세요', '말했어요']),
        GrammarExample('선생님은 책을 [읽으세요].', '老師在讀書。', <String>['읽세요', '읽어세요', '읽었어요']),
      ],
    ),
    GrammarPoint(
      id: 'a_eo_juseyo',
      title: '-아/어 주세요（請幫我…）',
      form: '語幹＋아／어 주세요',
      explanation: <String>[
        '■ 一句話',
        '拜託對方為自己做某件事：「請幫我…」「請…」。',
        '■ 怎麼接',
        '動詞先變成「-아／-어」的樣子，空一格，再接 주세요。變法和 -아요／어요 一樣，只是不加 요：',
        '・하다 結尾 → 해：계산하다 → 계산해 주세요（請幫我結帳）、말하다 → 말해 주세요（請說）',
        '・語幹最後的母音是 ㅏ 或 ㅗ → 아：닫다 → 닫아 주세요（請關上）',
        '・其他母音 → 어：열다 → 열어 주세요（請打開）、찍다 → 찍어 주세요（請拍）',
        '■ 跟中文比',
        '주세요 單獨用是「請給我（東西）」，例如 물 주세요（請給我水）。接在動詞後面，就變成「請（為我）做…」。中文的「請」在前面，韓文的 주세요 在後面。',
        '■ 常見錯誤',
        '・書寫時一般在 주세요 前面空一格：계산해 주세요（規範上連寫 계산해주세요 也可以，但本 App 一律空格）。',
        '・不要寫成 열아 주세요、하아 주세요：先照 -아요／어요 的規則變，再拿掉 요。',
      ],
      examples: <GrammarExample>[
        GrammarExample('문 좀 [열어 주세요].', '請幫我開門。', <String>['열아 주세요', '열고 주세요', '열어요']),
        GrammarExample('사진을 [찍어 주세요].', '請幫我拍照。', <String>['찍아 주세요', '찍고 주세요', '찍어요']),
        GrammarExample('천천히 [말해 주세요].', '請慢慢說。', <String>['말하아 주세요', '말하고 주세요', '말해요']),
      ],
    ),
    GrammarPoint(
      id: 'ji_maseyo',
      title: '-지 마세요（請不要…）',
      form: '語幹＋지 마세요',
      explanation: <String>[
        '禮貌地請對方「不要做某事」。',
        '語幹直接接「-지 마세요」，不用判斷終聲。',
      ],
      examples: <GrammarExample>[
        GrammarExample('여기에 앉[지 마세요].', '請不要坐這裡。', <String>['지 않아요', '지 못해요', '으세요']),
        GrammarExample('걱정하[지 마세요].', '請不要擔心。', <String>['지 않아요', '지 못해요', '세요']),
        GrammarExample('늦[지 마세요].', '請不要遲到。', <String>['지 않아요', '지 못해요', '으세요']),
      ],
    ),
  ],
);
