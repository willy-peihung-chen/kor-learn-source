import '../content_models.dart';

const GrammarLessonData grammarParticles1 = GrammarLessonData(
  id: 'particles1',
  title: '助詞（一）：主題、主語與受詞',
  summary: '韓文用「助詞」標示名詞在句中的角色。先學最常用的 은/는、이/가、을/를、도、의。',
  intros: <GrammarIntro>[
    GrammarIntro(
      id: 'order',
      title: '韓文的語序與助詞',
      paragraphs: <String>[
        '中文的基本語序是「主詞＋動詞＋受詞」，韓文則是「主詞＋受詞＋動詞」，動詞放在句尾。',
        '例：我 喝 咖啡 →「저는 커피를 마셔요.」（我 咖啡 喝）。',
        '韓文不靠位置，而是在名詞後面加上「助詞」來標示它是主題、主語還是受詞，所以語序可以稍微調動。',
        '很多助詞會依前一個字有沒有「終聲」（最底下的子音，例如「책」的 ㄱ）而改變形態，所以先學會看終聲很重要。',
      ],
    ),
  ],
  points: <GrammarPoint>[
    GrammarPoint(
      id: 'eun_neun',
      title: '은/는（主題助詞）',
      form: '無終聲＋는　有終聲＋은',
      explanation: <String>[
        '■ 一句話',
        '放在名詞後面，表示「這句話要談的是它」。',
        '■ 怎麼接',
        '看前一個字有沒有收尾音（也叫「終聲」，就是一個字最下面的子音，例如 책 的 ㄱ）：',
        '・沒有收尾音 → 는：저 → 저는、친구 → 친구는',
        '・有收尾音 → 은：책 → 책은、선생님 → 선생님은',
        '■ 跟中文比',
        '中文沒有對應的字，最接近「至於…」「…呢」。저는 학생이에요 照順序直翻是「我呢　學生　是」，中文就說「我是學生」。',
        '■ 什麼時候用',
        '1. 介紹自己、開始談一個話題：저는 대만 사람이에요.（我是台灣人。）',
        '2. 對比兩樣東西：이것은 커피예요. 저것은 차예요.（這個是咖啡，那個是茶。）',
        '■ 常見錯誤',
        '和 이／가 搞混。初學先記：介紹自己、說「A 是 B」時用 은／는。兩者的差別見下一個文法點「이/가（主語助詞）」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('저[는] 학생이에요.', '我是學生。', <String>['은', '가', '를']),
        GrammarExample('책[은] 책상 위에 있어요.', '書在書桌上。', <String>['는', '를', '에']),
        GrammarExample('한국어[는] 재미있어요.', '韓文很有趣。', <String>['은', '를', '에']),
      ],
    ),
    GrammarPoint(
      id: 'i_ga',
      title: '이/가（主語助詞）',
      form: '無終聲＋가　有終聲＋이',
      explanation: <String>[
        '標示動作或狀態的主語，常用來介紹新資訊。',
        '前面的字沒有終聲用「가」，有終聲用「이」。',
        '「은/는」強調「談論的主題」，「이/가」強調「是誰／什麼」；初學階段先記住形態變化即可。',
      ],
      examples: <GrammarExample>[
        GrammarExample('비[가] 와요.', '下雨。', <String>['이', '를', '에']),
        GrammarExample('사람[이] 많아요.', '人很多。', <String>['가', '를', '에서']),
        GrammarExample('친구[가] 와요.', '朋友來。', <String>['이', '를', '에']),
      ],
    ),
    GrammarPoint(
      id: 'eul_reul',
      title: '을/를（受詞助詞）',
      form: '無終聲＋를　有終聲＋을',
      explanation: <String>[
        '標示動作的對象（受詞），相當於中文「把…」「…（做某事）」。',
        '前面的字沒有終聲用「를」，有終聲用「을」。',
        '口語中常省略這個助詞。',
      ],
      examples: <GrammarExample>[
        GrammarExample('물[을] 마셔요.', '喝水。', <String>['를', '가', '에']),
        GrammarExample('커피[를] 마셔요.', '喝咖啡。', <String>['을', '이', '에']),
        GrammarExample('한국어[를] 공부해요.', '學韓文。', <String>['을', '가', '에서']),
      ],
    ),
    GrammarPoint(
      id: 'do',
      title: '도（也）',
      form: '名詞＋도（不受終聲影響）',
      explanation: <String>[
        '表示「也」。',
        '「도」會取代 은/는、이/가、을/를，不需要再加其他助詞。',
        '例：「저는 학생이에요.」→「저도 학생이에요.」（我也是學生。）',
      ],
      examples: <GrammarExample>[
        GrammarExample('저[도] 학생이에요.', '我也是學生。', <String>['는', '를', '에']),
        GrammarExample('커피[도] 마셔요.', '也喝咖啡。', <String>['는', '만', '에']),
        GrammarExample('친구[도] 와요.', '朋友也來。', <String>['는', '가', '를']),
      ],
    ),
    GrammarPoint(
      id: 'ui',
      title: '의（…的，所有格）',
      form: '名詞＋의＋名詞',
      explanation: <String>[
        '表示所屬關係，相當於中文的「的」：「친구의 가방」＝朋友的包包。',
        '口語中常常省略：「제 가방」「우리 집」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('친구[의] 가방이에요.', '是朋友的包包。', <String>['를', '에', '도']),
        GrammarExample('저[의] 이름은 민수예요.', '我的名字是民秀。', <String>['를', '에', '와']),
        GrammarExample('선생님[의] 책이에요.', '是老師的書。', <String>['을', '에서', '와']),
      ],
    ),
  ],
);
