import '../content_models.dart';

const GrammarLessonData grammarTenseAbility = GrammarLessonData(
  id: 'tense_ability',
  title: '時態與能力、義務、許可',
  summary: '過去式、未來／計畫、進行中，以及「會／能」「必須」「可以」。',
  intros: <GrammarIntro>[
    GrammarIntro(
      id: 'tense_intro',
      title: '時態一覽',
      paragraphs: <String>[
        '現在：먹어요（吃）。',
        '過去：먹었어요（吃了）。',
        '計畫、未來：먹을 거예요（要吃、會吃）。',
        '進行中：먹고 있어요（正在吃）。',
        '這四種形式只要把語幹接上不同的語尾即可，不需要像英文那樣改變動詞本身。',
      ],
    ),
  ],
  points: <GrammarPoint>[
    GrammarPoint(
      id: 'at_eot',
      title: '-았/었어요（過去式）',
      form: '語幹最後母音 ㅏ／ㅗ＋았어요　其他＋었어요　하다→했어요',
      explanation: <String>[
        '把現在式「-아요/어요」中的「요」前加上「ㅆ」，就是過去式的語尾。',
        '例：가다 → 갔어요，먹다 → 먹었어요，하다 → 했어요，만나다 → 만났어요。',
      ],
      examples: <GrammarExample>[
        GrammarExample('어제 학교에 [갔어요].', '昨天去了學校。', <String>['가요', '갈 거예요', '가고 있어요']),
        GrammarExample('아침에 밥을 [먹었어요].', '早上吃了飯。', <String>['먹아요', '먹어요', '먹을 거예요']),
        GrammarExample('친구를 [만났어요].', '見了朋友。', <String>['만나요', '만날 거예요', '만나었어요']),
      ],
    ),
    GrammarPoint(
      id: 'eul_geoyeyo',
      title: '-(으)ㄹ 거예요（計畫、推測）',
      form: '語幹無終聲＋ㄹ 거예요　有終聲＋을 거예요',
      explanation: <String>[
        '表示未來的計畫，也可以表示推測，要靠上下文判斷。',
        '語幹沒有終聲，加上「ㄹ」：가다 → 갈 거예요；有終聲加「을」：먹다 → 먹을 거예요。',
        '語幹終聲本來是「ㄹ」的動詞，不需要再加：만들다 → 만들 거예요。',
      ],
      examples: <GrammarExample>[
        GrammarExample('내일 학교에 [갈 거예요].', '明天會去學校。', <String>['갔어요', '가고 있어요', '갈 수 없어요']),
        GrammarExample('저녁에 밥을 [먹을 거예요].', '晚上要吃飯。', <String>['먹었어요', '먹고 있어요', '먹을까요']),
        GrammarExample('주말에 친구를 [만날 거예요].', '週末會見朋友。', <String>['만났어요', '만나고 있어요', '만난 거예요']),
      ],
    ),
    GrammarPoint(
      id: 'go_isseoyo',
      title: '-고 있어요（正在…）',
      form: '語幹＋고 있어요',
      explanation: <String>[
        '表示動作正在進行，相當於中文的「正在…」。',
        '直接接在語幹後面，不需要判斷終聲。',
      ],
      examples: <GrammarExample>[
        GrammarExample('지금 밥을 [먹고 있어요].', '現在正在吃飯。', <String>['먹었어요', '먹을 거예요', '먹고 싶어요']),
        GrammarExample('친구를 [기다리고 있어요].', '正在等朋友。', <String>['기다렸어요', '기다릴 거예요', '기다리고 싶어요']),
        GrammarExample('한국어를 [배우고 있어요].', '正在學韓文。', <String>['배웠어요', '배울 거예요', '배우고 싶어요']),
      ],
    ),
    GrammarPoint(
      id: 'su_isseoyo',
      title: '-(으)ㄹ 수 있어요/없어요（會、能／不會、不能）',
      form: '語幹＋(으)ㄹ 수 있어요／없어요',
      explanation: <String>[
        '表示有（沒有）能力或可能性。',
        '語幹沒有終聲加「ㄹ」，有終聲加「을」：할 수 있어요、먹을 수 없어요。',
      ],
      examples: <GrammarExample>[
        GrammarExample('수영을 할 [수 있어요].', '會游泳。', <String>['수 없어요', '수 싶어요', '수 이에요']),
        GrammarExample('매운 음식을 먹을 [수 없어요].', '不能吃辣的食物。', <String>['수 있어요', '수 싶어요', '수 이에요']),
        GrammarExample('저는 운전할 [수 있어요].', '我會開車。', <String>['수 없어요', '수 싶어요', '수 이에요']),
      ],
    ),
    GrammarPoint(
      id: 'a_eoya_haeyo',
      title: '-아/어야 해요（必須…）',
      form: '語幹＋아／어야 해요（也可說 -아/어야 돼요）',
      explanation: <String>[
        '表示義務或必要：「必須…」「得…」。',
        '前面的動詞依 -아요/어요 的規則變化。',
      ],
      examples: <GrammarExample>[
        GrammarExample('내일 일찍 [일어나야 해요].', '明天必須早起。', <String>['일어나도 돼요', '일어나고 싶어요', '일어날 거예요']),
        GrammarExample('숙제를 [해야 해요].', '必須做作業。', <String>['해도 돼요', '하고 싶어요', '할 거예요']),
        GrammarExample('약을 [먹어야 해요].', '必須吃藥。', <String>['먹어도 돼요', '먹고 싶어요', '먹을 거예요']),
      ],
    ),
    GrammarPoint(
      id: 'a_eodo_dwaeyo',
      title: '-아/어도 돼요（可以…）',
      form: '語幹＋아／어도 돼요',
      explanation: <String>[
        '表示許可：「可以…」。常用來問「可以…嗎？」。',
        '前面的動詞依 -아요/어요 的規則變化：앉다 → 앉아도, 찍다 → 찍어도, 가다 → 가도。',
      ],
      examples: <GrammarExample>[
        GrammarExample('여기에 [앉아도 돼요]?', '可以坐這裡嗎？', <String>['앉아야 해요', '앉고 싶어요', '앉을 거예요']),
        GrammarExample('사진을 [찍어도 돼요]?', '可以拍照嗎？', <String>['찍어야 해요', '찍고 싶어요', '찍을 거예요']),
        GrammarExample('지금 [가도 돼요]?', '現在可以走了嗎？', <String>['가야 해요', '가고 싶어요', '갈 거예요']),
      ],
    ),
  ],
);
