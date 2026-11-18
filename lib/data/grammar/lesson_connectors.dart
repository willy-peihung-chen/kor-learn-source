import '../content_models.dart';

const GrammarLessonData grammarConnectors = GrammarLessonData(
  id: 'connectors',
  title: '連接語尾與提議',
  summary: '把兩個句子連起來：而且、但是、因為、如果、為了…去，並學會「我們…吧？」。',
  intros: <GrammarIntro>[
    GrammarIntro(
      id: 'connector_intro',
      title: '用語尾連接句子',
      paragraphs: <String>[
        '韓文常把前後兩個子句用「連接語尾」接成一句，而不是像中文一樣加獨立的連接詞。',
        '連接語尾接在前一個子句的語幹之後，時態通常只標在句尾。',
        '例：「밥을 먹고 커피를 마셔요.」（吃飯，然後喝咖啡。）',
      ],
    ),
  ],
  points: <GrammarPoint>[
    GrammarPoint(
      id: 'go',
      title: '-고（而且、然後）',
      form: '語幹＋고（이다：이고／고）',
      explanation: <String>[
        '連接兩個動作或狀態：「…而且…」「…然後…」。',
        '直接接在語幹後面，不需要判斷終聲。名詞後面接「이다」時，變成「-이고」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('밥을 먹[고] 커피를 마셔요.', '吃飯，然後喝咖啡。', <String>['으면', '지만', '으니까']),
        GrammarExample('저는 학생이[고] 동생은 회사원이에요.', '我是學生，弟弟（妹妹）是上班族。', <String>['아서', '면', '서']),
        GrammarExample('손을 씻[고] 밥을 먹어요.', '洗手之後吃飯。', <String>['으면', '지만', '으니까']),
      ],
    ),
    GrammarPoint(
      id: 'jiman',
      title: '-지만（但是）',
      form: '語幹＋지만',
      explanation: <String>[
        '表示轉折：「雖然…但是…」。',
        '直接接在語幹後面，不需要判斷終聲。',
      ],
      examples: <GrammarExample>[
        GrammarExample('한국어는 어렵[지만] 재미있어요.', '韓文雖然難，但是有趣。', <String>['고', '아서', '으면']),
        GrammarExample('비싸[지만] 맛있어요.', '雖然貴，但是好吃。', <String>['고', '어서', '으면']),
        GrammarExample('키는 작[지만] 힘이 세요.', '個子雖然小，但是力氣大。', <String>['고', '아서', '으면']),
      ],
    ),
    GrammarPoint(
      id: 'a_eoseo',
      title: '-아서/어서（因為…所以…；…之後）',
      form: '語幹＋아서／어서　하다→해서',
      explanation: <String>[
        '表示原因：「因為…所以…」。依 -아요/어요 的規則變化：오다 → 와서，고프다 → 고파서，피곤하다 → 피곤해서。',
        '重要限制：後句不能是命令句（-(으)세요）或提議句（-(으)ㅂ시다／-(으)ㄹ까요?）；前句也不放過去式「-았/었-」。',
        '需要這些時，改用「-(으)니까」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('비가 와[서] 집에 있어요.', '因為下雨，所以待在家裡。', <String>['고', '지만', '으면']),
        GrammarExample('배가 고파[서] 많이 먹었어요.', '因為肚子餓，所以吃了很多。', <String>['고', '지만', '으면']),
        GrammarExample('피곤해[서] 일찍 잤어요.', '因為累了，所以早睡了。', <String>['고', '지만', '으면']),
      ],
    ),
    GrammarPoint(
      id: 'eu_nikka',
      title: '-(으)니까（因為…；既然…）',
      form: '語幹無終聲＋니까　有終聲＋으니까',
      explanation: <String>[
        '表示原因或理由，後句可以是命令句或提議句，這是和 -아서/어서 最大的不同。',
        '語幹沒有終聲接「니까」：오다 → 오니까；有終聲接「으니까」：없다 → 없으니까。',
        '「ㅂ」不規則的形容詞：춥다 → 추우니까（不規則變化會在日後另外整理）。',
      ],
      examples: <GrammarExample>[
        GrammarExample('비가 오[니까] 우산을 가져가세요.', '因為下雨，請帶傘去。', <String>['아서', '고', '지만']),
        GrammarExample('추우[니까] 창문을 닫으세요.', '因為很冷，請關窗戶。', <String>['어서', '고', '지만']),
        GrammarExample('배가 고프[니까] 밥을 먹읍시다.', '肚子餓了，我們吃飯吧。', <String>['아서', '고', '지만']),
      ],
    ),
    GrammarPoint(
      id: 'eu_myeon',
      title: '-(으)면（如果…）',
      form: '語幹無終聲＋면　有終聲＋으면',
      explanation: <String>[
        '表示條件：「如果…的話」。',
        '語幹沒有終聲接「면」：가다 → 가면；有終聲接「으면」：있다 → 있으면。',
      ],
      examples: <GrammarExample>[
        GrammarExample('시간이 있[으면] 같이 가요.', '如果有時間就一起去吧。', <String>['아서', '고', '지만']),
        GrammarExample('비가 오[면] 집에 있어요.', '如果下雨就待在家。', <String>['아서', '고', '지만']),
        GrammarExample('한국에 가[면] 김치를 먹고 싶어요.', '如果去韓國，想吃泡菜。', <String>['아서', '고', '지만']),
      ],
    ),
    GrammarPoint(
      id: 'eu_reo',
      title: '-(으)러 가요/와요（為了…而去／來）',
      form: '語幹無終聲＋러　有終聲＋으러　＋가다／오다',
      explanation: <String>[
        '表示「去／來的目的」，後面一定接「가다」「오다」之類的移動動詞。',
        '語幹沒有終聲接「러」：만나다 → 만나러；有終聲接「으러」：먹다 → 먹으러。',
      ],
      examples: <GrammarExample>[
        GrammarExample('밥을 먹[으러] 가요.', '去吃飯。', <String>['고', '아서', '으면']),
        GrammarExample('친구를 만나[러] 가요.', '去見朋友。', <String>['고', '아서', '으면']),
        GrammarExample('책을 사[러] 서점에 가요.', '去書店買書。', <String>['고', '아서', '으면']),
      ],
    ),
    GrammarPoint(
      id: 'jeon_hu',
      title: '전에 · 후에（…之前、…之後）',
      form: '-기 전에　/　-(으)ㄴ 후에　（名詞＋전에／후에）',
      explanation: <String>[
        '「-기 전에」：在做某事之前。語幹直接接「기 전에」：자다 → 자기 전에。',
        '「-(으)ㄴ 후에」：在做某事之後。語幹無終聲加「ㄴ」，有終聲加「은」：먹다 → 먹은 후에。',
      ],
      examples: <GrammarExample>[
        GrammarExample('밥을 먹은 [후에] 커피를 마셔요.', '吃完飯後喝咖啡。', <String>['전에', '때', '동안']),
        GrammarExample('자기 [전에] 이를 닦아요.', '睡覺前刷牙。', <String>['후에', '때', '동안']),
        GrammarExample('수업이 끝난 [후에] 집에 가요.', '下課後回家。', <String>['전에', '동안', '때문에']),
      ],
    ),
    GrammarPoint(
      id: 'eul_kkayo',
      title: '-(으)ㄹ까요?（要不要…？我們…好嗎？）',
      form: '語幹無終聲＋ㄹ까요?　有終聲＋을까요?',
      explanation: <String>[
        '用來向對方提議，或詢問對方的意見：「我們…好嗎？」「要不要…？」。',
        '語幹沒有終聲加「ㄹ까요」：보다 → 볼까요?；有終聲加「을까요」：먹다 → 먹을까요?。',
      ],
      examples: <GrammarExample>[
        GrammarExample('같이 영화를 [볼까요]?', '我們一起看電影好嗎？', <String>['볼 거예요', '봤어요', '보고 있어요']),
        GrammarExample('뭐 [먹을까요]?', '要吃什麼好呢？', <String>['먹을 거예요', '먹었어요', '먹고 있어요']),
        GrammarExample('어디에서 [만날까요]?', '要在哪裡見面呢？', <String>['만날 거예요', '만났어요', '만나고 있어요']),
      ],
    ),
    GrammarPoint(
      id: 'eu_bsida',
      title: '-(으)ㅂ시다（我們…吧）',
      form: '語幹無終聲＋ㅂ시다　有終聲＋읍시다',
      explanation: <String>[
        '邀請或建議對方一起做某事：「我們…吧」。',
        '語幹沒有終聲：가다 → 갑시다；有終聲：먹다 → 먹읍시다。',
        '這個語尾語氣偏直接，對長輩使用比較不禮貌；對長輩通常改用「-(으)ㄹ까요?」或「-아요/어요」。',
      ],
      examples: <GrammarExample>[
        GrammarExample('같이 [갑시다].', '我們一起去吧。', <String>['갑니다', '가세요', '갔어요']),
        GrammarExample('점심을 [먹읍시다].', '我們吃午餐吧。', <String>['먹습니다', '드세요', '먹었어요']),
        GrammarExample('열심히 [공부합시다].', '我們認真讀書吧。', <String>['공부합니다', '공부하세요', '공부했어요']),
      ],
    ),
  ],
);
