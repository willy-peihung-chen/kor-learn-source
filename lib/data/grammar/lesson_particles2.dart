import '../content_models.dart';

const GrammarLessonData grammarParticles2 = GrammarLessonData(
  id: 'particles2',
  title: '助詞（二）：地點、時間、對象與工具',
  summary: '學會 에、에서、와/과、(으)로、에게/한테、부터/까지，就能說出「在哪裡、跟誰、用什麼」。',
  intros: <GrammarIntro>[
    GrammarIntro(
      id: 'place_particles',
      title: '「在」要分兩種',
      paragraphs: <String>[
        '中文的「在」在韓文要分成兩種：',
        '「에」用在「存在、到達的地點」（있다、가다、오다），以及時間點。',
        '「에서」用在「動作進行的地點」（學習、吃飯、工作等），也可以表示「從」。',
        '例：「집에 있어요.」（在家裡）；「집에서 밥을 먹어요.」（在家裡吃飯）。',
      ],
    ),
  ],
  points: <GrammarPoint>[
    GrammarPoint(
      id: 'e',
      title: '에（時間、目的地、存在的地點）',
      form: '名詞＋에',
      explanation: <String>[
        '接在時間後面表示「在…時間」：「일곱 시에」。',
        '接在地點後面，搭配 가다／오다 表示目的地，搭配 있다／없다 表示存在的地點。',
      ],
      examples: <GrammarExample>[
        GrammarExample('학교[에] 가요.', '去學校。', <String>['에서', '와', '의']),
        GrammarExample('일곱 시[에] 일어나요.', '七點起床。', <String>['에서', '를', '와']),
        GrammarExample('집[에] 있어요.', '在家。', <String>['에서', '를', '와']),
      ],
    ),
    GrammarPoint(
      id: 'eseo',
      title: '에서（動作的地點、從…）',
      form: '地點名詞＋에서',
      explanation: <String>[
        '表示動作發生的地點：「도서관에서 공부해요.」（在圖書館念書）。',
        '也可以表示出發點「從…」：「서울에서 왔어요.」（從首爾來的）。',
      ],
      examples: <GrammarExample>[
        GrammarExample('도서관[에서] 공부해요.', '在圖書館念書。', <String>['에', '를', '와']),
        GrammarExample('집[에서] 밥을 먹어요.', '在家裡吃飯。', <String>['에', '의', '와']),
        GrammarExample('서울[에서] 왔어요.', '從首爾來的。', <String>['에', '를', '의']),
      ],
    ),
    GrammarPoint(
      id: 'wa_gwa',
      title: '와/과 · (이)랑 · 하고（和、跟）',
      form: '無終聲＋와／랑　有終聲＋과／이랑　（하고不變）',
      explanation: <String>[
        '連接名詞表示「和」，或表示「跟誰一起做」。',
        '「와/과」偏書面，「(이)랑」「하고」偏口語。',
        '前面沒有終聲用「와／랑」，有終聲用「과／이랑」；「하고」不受終聲影響。',
      ],
      examples: <GrammarExample>[
        GrammarExample('친구[와] 영화를 봐요.', '和朋友看電影。', <String>['과', '을', '에']),
        GrammarExample('책[과] 연필이 있어요.', '有書和鉛筆。', <String>['와', '를', '에']),
        GrammarExample('엄마[랑] 시장에 가요.', '和媽媽去市場。', <String>['이랑', '을', '에서']),
      ],
    ),
    GrammarPoint(
      id: 'euro',
      title: '(으)로（方向、工具、手段）',
      form: '無終聲或ㄹ終聲＋로　其他終聲＋으로',
      explanation: <String>[
        '■ 一句話',
        '接在名詞後面，表示「用…（工具、方法）」或「往…（方向）」。',
        '■ 怎麼接',
        '看前一個字有沒有收尾音：',
        '・沒有收尾音 → 로：카드 → 카드로（用卡片）、버스 → 버스로（搭公車）',
        '・有收尾音 → 으로：현금 → 현금으로（用現金）、오른쪽 → 오른쪽으로（往右邊）',
        '・收尾音是 ㄹ → 也用 로：지하철 → 지하철로（搭地鐵）、연필 → 연필로（用鉛筆）',
        '■ 跟中文比',
        '中文的「用」「搭」「往」放在名詞前面（用卡片、往右邊），韓文的 로／으로 放在名詞後面（카드로、오른쪽으로）。',
        '■ 什麼時候用',
        '1. 付款方式、工具：카드로 계산해 주세요.（請用卡片結帳。）',
        '2. 交通工具：버스로 가요.（搭公車去。）',
        '3. 方向：오른쪽으로 가세요.（請往右邊走。）',
        '■ 常見錯誤',
        'ㄹ 收尾的字最容易錯：不要寫成 지하철으로、연필으로。',
      ],
      examples: <GrammarExample>[
        GrammarExample('버스[로] 가요.', '搭公車去。', <String>['를', '에서', '와']),
        GrammarExample('오른쪽[으로] 가세요.', '請往右邊走。', <String>['로', '에서', '를']),
        GrammarExample('연필[로] 써요.', '用鉛筆寫。', <String>['으로', '를', '에서']),
      ],
    ),
    GrammarPoint(
      id: 'ege_hante',
      title: '에게 · 한테（給…、對…）',
      form: '人／動物＋에게（口語：한테）',
      explanation: <String>[
        '接在人或動物後面，表示動作的對象，例如「給」「對」。',
        '「한테」比「에게」更口語。對長輩可用敬語「께」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('친구[에게] 선물을 줘요.', '送朋友禮物。', <String>['를', '에서', '와']),
        GrammarExample('엄마[한테] 전화해요.', '打電話給媽媽。', <String>['를', '에서', '와']),
        GrammarExample('동생[한테] 책을 보내요.', '寄書給弟弟（妹妹）。', <String>['를', '에서', '와']),
      ],
    ),
    GrammarPoint(
      id: 'buteo_kkaji',
      title: '부터 · 까지（從…、到…）',
      form: '名詞＋부터　名詞＋까지',
      explanation: <String>[
        '「부터」表示起點（從…開始），「까지」表示終點（到…為止）。',
        '可以用在時間，也可以用在地點。常成對出現：「아홉 시부터 여섯 시까지」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('아홉 시[부터] 수업이 있어요.', '從九點開始有課。', <String>['까지', '에서', '를']),
        GrammarExample('여섯 시[까지] 일해요.', '工作到六點。', <String>['부터', '를', '에서']),
        GrammarExample('월요일[부터] 금요일까지 일해요.', '從星期一工作到星期五。', <String>['까지', '에서', '를']),
      ],
    ),
  ],
);
