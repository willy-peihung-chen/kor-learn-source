import '../content_models.dart';

const GrammarLessonData grammarBasicSentences = GrammarLessonData(
  id: 'basic_sentences',
  title: '基本句型：是、有與現在式',
  summary: '「是／不是」「有／沒有」，以及動詞與形容詞的現在式（해요體、格式體）。',
  intros: <GrammarIntro>[
    GrammarIntro(
      id: 'dictionary_form',
      title: '辭典形與活用',
      paragraphs: <String>[
        '韓文的動詞和形容詞在辭典裡都以「-다」結尾，例如 가다（去）、먹다（吃）、예쁘다（漂亮）。',
        '去掉「다」剩下的部分叫「語幹」：가、먹、예쁘。語幹後面接不同的語尾，就能表達時態、禮貌程度等。',
        '本課先學最常用的兩種現在式語尾：日常的「-아요/어요」，以及較正式的「-ㅂ니다/습니다」。',
      ],
    ),
    GrammarIntro(
      id: 'haeyo_rule',
      title: '-아요/어요 的接法',
      paragraphs: <String>[
        '看語幹「最後一個母音」：是 ㅏ 或 ㅗ 就接「-아요」，其他母音接「-어요」。',
        '例：앉다 → 앉아요；먹다 → 먹어요。',
        '「하다」類動詞固定變成「해요」：공부하다 → 공부해요。',
        '語幹沒有終聲時，常會縮合：가다 → 가요（가아요 縮成 가요）、오다 → 와요、마시다 → 마셔요、쓰다 → 써요。',
        '少數動詞有不規則變化，之後遇到時會單獨說明。',
      ],
    ),
  ],
  points: <GrammarPoint>[
    GrammarPoint(
      id: 'ieyo',
      title: '이에요/예요（是）',
      form: '名詞＋이에요（有終聲）／예요（無終聲）',
      explanation: <String>[
        '「이다」是「是」，用來說「A 是 B」。',
        '名詞有終聲接「이에요」，沒有終聲接「예요」。',
        '例：학생이에요（是學生）、의사예요（是醫生）。',
      ],
      examples: <GrammarExample>[
        GrammarExample('저는 학생[이에요].', '我是學生。', <String>['예요', '이야요', '아니에요']),
        GrammarExample('아버지는 의사[예요].', '爸爸是醫生。', <String>['이에요', '이야요', '아니에요']),
        GrammarExample('이것은 책[이에요].', '這是書。', <String>['예요', '이야요', '아니에요']),
      ],
    ),
    GrammarPoint(
      id: 'anieyo',
      title: '이/가 아니에요（不是）',
      form: '名詞＋이／가＋아니에요',
      explanation: <String>[
        '「A 是 B」的否定：「A 不是 B」。',
        '前面的名詞要加上主語助詞「이/가」：有終聲加「이」，無終聲加「가」。',
        '例：학생이 아니에요（不是學生）、의사가 아니에요（不是醫生）。',
      ],
      examples: <GrammarExample>[
        GrammarExample('저는 의사가 [아니에요].', '我不是醫生。', <String>['안이에요', '없어요', '아니예요']),
        GrammarExample('이것은 물이 [아니에요].', '這不是水。', <String>['안이에요', '없어요', '아니예요']),
        GrammarExample('저는 중국 사람이 [아니에요].', '我不是中國人。', <String>['안이에요', '없어요', '아니예요']),
      ],
    ),
    GrammarPoint(
      id: 'itda_eopda',
      title: '있어요/없어요（有、沒有；在）',
      form: '名詞＋이／가＋있어요／없어요',
      explanation: <String>[
        '「있다」表示「有」或「在」，「없다」表示「沒有」或「不在」。',
        '主語通常加「이/가」，地點加「에」：「교실에 학생이 있어요.」（教室裡有學生。）',
      ],
      examples: <GrammarExample>[
        GrammarExample('교실에 학생이 [있어요].', '教室裡有學生。', <String>['없어요', '이에요', '아니에요']),
        GrammarExample('오늘은 시간이 [없어요].', '今天沒有時間。', <String>['있어요', '이에요', '아니에요']),
        GrammarExample('집에 고양이가 [있어요].', '家裡有貓。', <String>['없어요', '이에요', '아니에요']),
      ],
    ),
    GrammarPoint(
      id: 'ayo_eoyo',
      title: '-아요/어요（現在式，日常禮貌體）',
      form: '語幹的最後母音是 ㅏ／ㅗ＋아요　其他＋어요　하다→해요',
      explanation: <String>[
        '日常對話最常用的禮貌語尾，可以用在陳述、疑問，語調上揚就是問句。',
        '例：먹어요（吃）、가요（去）、해요（做）。',
        '它表示「現在的事實或習慣」，有時也能表示近期的未來。',
      ],
      examples: <GrammarExample>[
        GrammarExample('학교에 [가요].', '去學校。', <String>['가어요', '가아요', '가다요']),
        GrammarExample('밥을 [먹어요].', '吃飯。', <String>['먹아요', '먹요', '먹다요']),
        GrammarExample('공부를 [해요].', '讀書。', <String>['하아요', '하어요', '하요']),
      ],
    ),
    GrammarPoint(
      id: 'mnida',
      title: '-ㅂ니다/습니다（現在式，正式體）',
      form: '語幹無終聲＋ㅂ니다　有終聲＋습니다　疑問：-ㅂ니까?／-습니까?',
      explanation: <String>[
        '比「-아요/어요」更正式，常用在新聞、報告、演講、職場的正式場合。',
        '語幹沒有終聲，把「ㅂ」加在語幹最後一個字下面再接「니다」：가다 → 갑니다；有終聲則接「습니다」：먹다 → 먹습니다。',
        '疑問句把「니다」換成「니까」：갑니까?、먹습니까?。',
        '「하다」類：감사하다 → 감사합니다。',
      ],
      examples: <GrammarExample>[
        GrammarExample('매일 학교에 [갑니다].', '每天去學校。', <String>['가습니다', '갑니까', '가읍니다']),
        GrammarExample('밥을 [먹습니다].', '吃飯。', <String>['먹읍니다', '먹습니까', '먹니다']),
        GrammarExample('감사[합니다].', '謝謝。', <String>['하습니다', '합니까', '함니다']),
      ],
    ),
  ],
);
