import 'catalog.dart';
import 'course_options.dart';
import 'lessons.dart';
import 'quiz_types.dart';

// 字母課（四）到（六），以及「單元學習」的課程內容。
//
// 原則：
// - 發音卡朗讀的一律是完整的音節或詞，不念單獨的字母（content_test 有測試保證）。
// - 單元用的測驗題，全部來自既有的單字與文法資料（Catalog），沒有另外寫死答案。
// - 這裡的說明與對話句子都是自行整理，尚未對照外部資料查核（見 docs/content_sources.md）。

SoundItem _sound(String text, String zh, [String? tag]) =>
    SoundItem(display: text, speak: text, caption: zh, tag: tag);

SoundItem _line(String speaker, String text, String zh, [String? tag]) =>
    SoundItem(display: text, speak: text, caption: '$speaker　$zh', tag: tag);

/// 文法庫裡的一個文法點，直接當成單元裡的一張卡片（內容只存在文法庫一份）。
LessonCard _grammarCard(String pointId) =>
    LessonCard.grammar(Catalog.grammarPointById(pointId)!);

/// 單字的測驗種子：每個單字出「單字→中文」與「中文→單字」兩種題。
List<QuizSeed> _wordSeeds(List<String> wordIds) => <QuizSeed>[
      for (final id in wordIds) ...<QuizSeed>[
        QuizSeed(QuizKind.wordMeaning, id),
        QuizSeed(QuizKind.meaningWord, id),
      ],
    ];

// ---------------------------------------------------------------------------
// 字母課（四）到（六）
// ---------------------------------------------------------------------------

List<Lesson> buildMoreHangulLessons() => <Lesson>[
      _strengthLesson(),
      _compoundVowelLesson(),
      _finalConsonantLesson(),
    ];

Lesson _strengthLesson() => Lesson(
      id: 'hangul-4',
      group: LessonGroup.hangul,
      title: '韓文字母（四）送氣音與濃音',
      summary: '同一個位置有三種音：平音、送氣音、濃音。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'h4:three',
          title: '同一個位置，三種音',
          paragraphs: const <String>[
            '前面學的 ㄱ ㄷ ㅂ ㅈ 是「平音」。韓文還有兩組和它們成對的音：氣流比較強的「送氣音」（ㅋ ㅌ ㅍ ㅊ），以及喉嚨用力、不送氣的「濃音」（ㄲ ㄸ ㅃ ㅉ）。ㅅ 也有對應的濃音 ㅆ。',
            '中文沒有一模一樣的分法，所以最好的練習是反覆聽、反覆比較。小技巧：拿一張薄紙放在嘴巴前面念，送氣音會讓紙明顯被吹動，平音和濃音幾乎不動。',
            '提醒：App 的聲音是電腦合成的，這三種音的差別可能不夠明顯，請同時搭配真人發音（老師、影片）。羅馬字也無法表示這個差別。',
          ],
        ),
        LessonCard.sound(
          id: 'h4:g_d',
          title: 'ㄱ 與 ㄷ 的三種音',
          paragraphs: const <String>[
            '每一排依序聽：平音 → 送氣音 → 濃音，比較差在哪裡。',
          ],
          items: <SoundItem>[
            _sound('가', '平音'),
            _sound('카', '送氣音'),
            _sound('까', '濃音'),
            _sound('다', '平音'),
            _sound('타', '送氣音'),
            _sound('따', '濃音'),
          ],
        ),
        LessonCard.sound(
          id: 'h4:b_j_s',
          title: 'ㅂ、ㅈ、ㅅ 的三種音',
          paragraphs: const <String>[
            'ㅂ 與 ㅈ 也是平音、送氣音、濃音三種。ㅅ 比較特別，只有「ㅅ」與濃音「ㅆ」兩種。',
          ],
          items: <SoundItem>[
            _sound('바', '平音'),
            _sound('파', '送氣音'),
            _sound('빠', '濃音'),
            _sound('자', '平音'),
            _sound('차', '送氣音'),
            _sound('짜', '濃音'),
            _sound('사', '平音'),
            _sound('싸', '濃音'),
          ],
        ),
        LessonCard.sound(
          id: 'h4:words',
          title: '試著讀這些詞',
          paragraphs: const <String>[
            '先自己拆開唸，再點下去對答案。這些詞都還沒有收尾音，下一堂以後才會學。',
          ],
          items: <SoundItem>[
            _sound('커피', '咖啡'),
            _sound('코', '鼻子'),
            _sound('치마', '裙子'),
            _sound('피자', '披薩'),
            _sound('토마토', '番茄'),
            _sound('카메라', '相機'),
            _sound('아빠', '爸爸'),
            _sound('오빠', '哥哥（女生對哥哥的稱呼）'),
            _sound('토끼', '兔子'),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:커피',
        'word:코',
        'word:치마',
        'word:피자',
        'word:토마토',
        'word:카메라',
        'word:아빠',
        'word:오빠',
        'word:토끼',
      ]),
    );

Lesson _compoundVowelLesson() => Lesson(
      id: 'hangul-5',
      group: LessonGroup.hangul,
      title: '韓文字母（五）複合母音',
      summary: '由兩個母音組合成的母音：ㅐ ㅔ、ㅘ ㅝ、ㅟ ㅢ 等。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'h5:idea',
          title: '兩個規律就夠了',
          paragraphs: const <String>[
            '前面學的母音可以組合成新的母音，叫「複合母音」。不用死背，抓住兩個規律：',
            '規律一：ㅐ 和 ㅔ（以及 ㅒ 和 ㅖ）。標準發音裡兩者不同（ㅐ 嘴巴開得比較大），但現代很多人說話時不太區分，聽起來很接近，所以初學者聽不出差別是正常的。先當成同一個音，字形要靠背單字記住。',
            '規律二：ㅘ ㅝ ㅙ ㅞ ㅚ ㅟ 都像是從 ㅗ 或 ㅜ 的嘴型，快速滑到另一個母音，聽起來像 w 開頭的音：와 像 wa，워 像 wo。ㅙ ㅞ ㅚ 在日常口語裡聽起來都很接近 we，也要靠背單字區分。ㅟ 常聽起來像 wi。',
          ],
        ),
        LessonCard.sound(
          id: 'h5:ae',
          title: 'ㅐ ㅔ ㅒ ㅖ',
          paragraphs: const <String>[
            '依序聽，注意前兩個聽起來差不多：',
          ],
          items: <SoundItem>[
            _sound('애', 'ㅇ + ㅐ'),
            _sound('에', 'ㅇ + ㅔ'),
            _sound('얘', 'ㅇ + ㅒ'),
            _sound('예', 'ㅇ + ㅖ'),
          ],
        ),
        LessonCard.sound(
          id: 'h5:w',
          title: '像 w 開頭的母音',
          paragraphs: const <String>[
            '先聽 와 和 워，再聽 왜、웨、외 這三個很接近的音，最後聽 위。',
          ],
          items: <SoundItem>[
            _sound('와', 'ㅇ + ㅘ'),
            _sound('워', 'ㅇ + ㅝ'),
            _sound('왜', 'ㅇ + ㅙ'),
            _sound('웨', 'ㅇ + ㅞ'),
            _sound('외', 'ㅇ + ㅚ'),
            _sound('위', 'ㅇ + ㅟ'),
          ],
        ),
        LessonCard.sound(
          id: 'h5:ui',
          title: 'ㅢ：比較特別的一個',
          paragraphs: const <String>[
            '의 在詞的開頭（例如 의자、의사）念起來接近「으」快速滑到「이」。先把整個詞聽熟就好。',
            '助詞「의」（…的）通常念成 에，之後學助詞時再說明。',
          ],
          items: <SoundItem>[
            _sound('의자', '椅子'),
            _sound('의사', '醫生'),
          ],
        ),
        LessonCard.sound(
          id: 'h5:words',
          title: '試著讀這些詞',
          paragraphs: const <String>[
            '這些詞都還沒有收尾音。先自己拆開唸，再點下去對答案。',
          ],
          items: <SoundItem>[
            _sound('개', '狗'),
            _sound('새', '鳥'),
            _sound('네', '是；好'),
            _sound('사과', '蘋果'),
            _sound('돼지', '豬'),
            _sound('왜', '為什麼'),
            _sound('회사', '公司'),
            _sound('뭐', '什麼'),
            _sound('귀', '耳朵'),
            _sound('가위', '剪刀'),
            _sound('쉬다', '休息'),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:개#狗',
        'word:새#鳥',
        'word:네',
        'word:사과',
        'word:돼지',
        'word:왜',
        'word:회사',
        'word:뭐',
        'word:귀',
        'word:의자',
        'word:가위',
      ]),
    );

Lesson _finalConsonantLesson() => Lesson(
      id: 'hangul-6',
      group: LessonGroup.hangul,
      title: '韓文字母（六）收尾音',
      summary: '音節最下面的子音（받침）：只有 7 種聲音。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'h6:idea',
          title: '音節還可以有第三層',
          paragraphs: const <String>[
            '一個音節最多由三層組成：子音 ＋ 母音 ＋ 收尾音（받침）。收尾音寫在方塊的最下面，例如 학 ＝ ㅎ ＋ ㅏ ＋ ㄱ。',
            '收尾音雖然有很多種寫法，實際念出來只有 7 種聲音：ㄱ ㄴ ㄷ ㄹ ㅁ ㅂ ㅇ。',
            '其中 ㄱ ㄷ ㅂ 放在音節結尾時，嘴巴直接閉住、不把氣吹出去，念得短而收住。ㅁ ㄴ ㅇ 是鼻音：ㅁ 閉上嘴唇，ㄴ 舌尖頂住上排牙齒後面，ㅇ 的聲音接近中文的「ng」。ㄹ 是舌尖輕輕碰上顎。',
          ],
        ),
        LessonCard.sound(
          id: 'h6:seven',
          title: '七種收尾聲音',
          paragraphs: const <String>[
            '每個詞各示範一種收尾聲音。依序點下去聽，注意最後那個音怎麼收。',
          ],
          items: <SoundItem>[
            _sound('책', 'ㄱ 收尾・書'),
            _sound('산', 'ㄴ 收尾・山'),
            _sound('닫다', 'ㄷ 收尾・關上'),
            _sound('달', 'ㄹ 收尾・月亮'),
            _sound('밤', 'ㅁ 收尾・夜晚'),
            _sound('집', 'ㅂ 收尾・家'),
            _sound('강', 'ㅇ 收尾・河'),
          ],
        ),
        LessonCard.sound(
          id: 'h6:same',
          title: '寫法不同，收尾聲音相同',
          paragraphs: const <String>[
            '收尾音的寫法不只七種，但都會念成上面七種聲音之一：',
            'ㄲ、ㅋ 在結尾念成 ㄱ；ㅅ、ㅆ、ㅈ、ㅊ、ㅌ 在結尾念成 ㄷ；ㅍ 在結尾念成 ㅂ。（ㅎ 當收尾音會有特別的變化，之後再學。）',
          ],
          items: <SoundItem>[
            _sound('밖', '外面・念成 ㄱ 收尾'),
            _sound('부엌', '廚房・念成 ㄱ 收尾'),
            _sound('옷', '衣服・念成 ㄷ 收尾'),
            _sound('낮', '白天・念成 ㄷ 收尾'),
            _sound('꽃', '花・念成 ㄷ 收尾'),
            _sound('앞', '前面・念成 ㅂ 收尾'),
          ],
        ),
        LessonCard.sound(
          id: 'h6:link',
          title: '連音：收尾音遇到母音',
          paragraphs: const <String>[
            '收尾音後面如果接的音節是以 ㅇ（不發音）開頭，收尾子音會「搬」到後面去念。所以聽到的和看到的拆法不一樣，是正常的。',
          ],
          items: <SoundItem>[
            _sound('먹어요', '聽起來像 머거요'),
            _sound('한국어', '聽起來像 한구거'),
            _sound('집이', '聽起來像 지비'),
            _sound('책이', '聽起來像 채기'),
          ],
        ),
        LessonCard.concept(
          id: 'h6:double',
          title: '還有兩個子音疊在一起的收尾音',
          paragraphs: const <String>[
            '像 없（없어요）、앉（앉아요）、읽（읽어요）這類收尾有兩個子音的字，規則比較多。現在先不要深究，遇到時把整個詞聽熟就好，之後再單獨整理。',
          ],
        ),
        LessonCard.sound(
          id: 'h6:words',
          title: '試著讀這些詞',
          paragraphs: const <String>[
            '先自己拆開唸，再點下去對答案。有些詞唸起來會有額外的變化，例如 학교 的 교 聽起來像 꾜，這是之後才學的規則，現在先跟著聽。',
          ],
          items: <SoundItem>[
            _sound('학교', '學校'),
            _sound('학생', '學生'),
            _sound('선생님', '老師'),
            _sound('한국', '韓國'),
            _sound('대만', '台灣'),
            _sound('한국어', '韓文'),
            _sound('사람', '人'),
            _sound('친구', '朋友'),
            _sound('공부', '讀書；學習'),
            _sound('이름', '名字'),
            _sound('안녕하세요', '你好'),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:학교',
        'word:학생',
        'word:선생님',
        'word:한국',
        'word:대만',
        'word:한국어',
        'word:책',
        'word:집',
        'word:산',
        'word:강',
        'word:옷',
        'word:꽃',
        'word:부엌',
        'word:밖',
      ]),
    );

// ---------------------------------------------------------------------------
// 單元學習
// ---------------------------------------------------------------------------

List<Lesson> buildUnitLessons() => <Lesson>[
      _unitIntroduce(),
      _unitWhatIsThis(),
      _unitOrdering(),
      _unitTime(),
      _unitShopping(),
      _unitDirections(),
      _unitTransport(),
      _unitLodging(),
      _unitRepair(),
      _unitFamily(),
      _unitLikes(),
      _unitDaily(),
      _unitPurpose(),
      _unitYesterday(),
      _unitPlans(),
      _unitAppointment(),
      _unitWeather(),
      _unitSick(),
      _unitPermission(),
      _unitClothes(),
      _unitDates(),
      _unitPhone(),
      _unitTaste(),
      _unitBank(),
      _unitLost(),
      _unitDescribe(),
      _unitExperience(),
      _unitCompare(),
      _unitFeelings(),
      _unitWork(),
      _unitGoodbye(),
    ];

Lesson _unitIntroduce() => Lesson(
      id: 'unit-1',
      group: LessonGroup.unit,
      title: '單元 1・自我介紹',
      summary: '說出自己的名字、國籍和身分。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u1:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會用一個句型介紹自己：「저는 ___이에요／예요.」（我是___。）',
            '做法：先認識會用到的詞，再把同一個句型換上不同的詞反覆練，最後聽一段只有 6 句的短對話。',
            '句型裡的「이에요／예요」會用到你剛學的收尾音：前面的詞有收尾音（例如 학생）用「이에요」，沒有收尾音（例如 의사）用「예요」。',
            '單元裡的句子全部是敬語，每個句子下面都標了語氣。半語不在單元裡，另外放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.concept(
          id: 'u1:who',
          title: '先搞清楚：跟陌生人怎麼說才禮貌',
          paragraphs: const <String>[
            '韓語的句尾會隨「對方是誰」改變。跟陌生人、店員、初次見面的人說話，用「해요體」就夠禮貌：句尾是 -이에요／예요、-아요／어요。',
            '「이름이 뭐예요?」雖然也是 해요體，但語氣比較直接，適合年紀相近的人；對明顯比你年長的人，用「이름이 어떻게 되세요?」比較客氣（本單元後面會學）。',
            '店員、櫃檯人員常說更客氣的話，例如「어서 오세요」（歡迎光臨）、「감사합니다」（謝謝），先聽得懂就好。',
            '半語只對很熟的人說，不在單元裡，另外放在「半語（額外學習）」。正式・職場說法（합니다體）與對長輩的進階尊敬說法之後再學。',
            '這些說明是自行整理，尚未對照官方資料查核（見 docs/content_sources.md）。',
          ],
        ),
        LessonCard.sound(
          id: 'u1:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。저 是「我」的謙稱，對初次見面的人、長輩、店員都用它。',
          ],
          items: <SoundItem>[
            _sound('저', '我（謙稱）'),
            _sound('이름', '名字'),
            _sound('학생', '學生'),
            _sound('대학생', '大學生'),
            _sound('선생님', '老師'),
            _sound('회사원', '上班族'),
            _sound('의사', '醫生'),
            _sound('사람', '人'),
            _sound('한국', '韓國'),
            _sound('대만', '台灣'),
            _sound('한국 사람', '韓國人'),
            _sound('대만 사람', '台灣人'),
          ],
        ),
        LessonCard.concept(
          id: 'u1:pattern',
          title: '句型：저는 ___이에요／예요',
          paragraphs: const <String>[
            '這個單元的主要句型用到三個文法：는（談的是…）、이에요／예요（是）、이／가 아니에요（不是）。下面用本單元的句子一個一個說明。',
            '■ 저는：我＋는',
            '저 是「我」的謙稱。後面的 는 表示「這句話要談的是我」，可以想成中文的「至於我…」「我呢…」。中文說「我是學生」，韓文說「저는 학생이에요」。',
            '는 前面的字沒有收尾音時用 는（저는）；有收尾音時改成 은，例如下一個單元的 이것은（這個呢）。',
            '■ 이에요／예요：是',
            '相當於中文的「是」，但放在句尾。저는 학생이에요 照韓文的順序直翻是「我呢　學生　是」。',
            '選哪一個，只看前面名詞的最後一個字有沒有收尾音：',
            '・학생 的「생」有收尾音 ㅇ → 학생이에요',
            '・의사 的「사」沒有收尾音 → 의사예요',
            '問句不用改字，句尾語調往上揚就好：학생이에요?（你是學生嗎？）',
            '■ 이／가 아니에요：不是',
            '否定時，把 이에요／예요 換成 아니에요，前面的名詞再加 이 或 가：有收尾音加 이（학생이 아니에요），沒有收尾音加 가（의사가 아니에요）。',
            '容易寫錯的地方：不要寫成 의사이에요、학생예요、의사이 아니에요；아니에요 也不要寫成 아니예요。',
          ],
          grammarRefs: const <String>['eun_neun', 'ieyo', 'anieyo'],
        ),
        LessonCard.sound(
          id: 'u1:drill1',
          title: '換詞練習・我是…',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。注意每一句用的是「이에요」還是「예요」。',
          ],
          items: <SoundItem>[
            _sound('저는 학생이에요.', '我是學生。', SpeechTag.polite),
            _sound('저는 대학생이에요.', '我是大學生。', SpeechTag.polite),
            _sound('저는 선생님이에요.', '我是老師。', SpeechTag.polite),
            _sound('저는 회사원이에요.', '我是上班族。', SpeechTag.polite),
            _sound('저는 의사예요.', '我是醫生。', SpeechTag.polite),
            _sound('저는 한국 사람이에요.', '我是韓國人。', SpeechTag.polite),
            _sound('저는 대만 사람이에요.', '我是台灣人。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u1:drill2',
          title: '換詞練習・不是…／你是…嗎？',
          paragraphs: const <String>[
            '前一個詞有收尾音用「이 아니에요」，沒有用「가 아니에요」。問句只是把語調往上揚。',
          ],
          items: <SoundItem>[
            _sound('저는 학생이 아니에요.', '我不是學生。', SpeechTag.polite),
            _sound('저는 의사가 아니에요.', '我不是醫生。', SpeechTag.polite),
            _sound('저는 회사원이 아니에요.', '我不是上班族。', SpeechTag.polite),
            _sound('저는 한국 사람이 아니에요.', '我不是韓國人。', SpeechTag.polite),
            _sound('학생이에요?', '你是學生嗎？', SpeechTag.polite),
            _sound('대만 사람이에요?', '你是台灣人嗎？', SpeechTag.polite),
          ],
        ),
        CourseOptions.showHonorific ? _u1NameFourLevels() : _u1NameSimple(),
        LessonCard.sound(
          id: 'u1:greet',
          title: '初次見面的固定說法',
          paragraphs: const <String>[
            '這四句是自我介紹常用的整句，不用拆開學，直接整句背起來。',
            '「안녕하세요」裡其實含有尊敬的 -세요，但它是固定的問候語，對誰都能說，所以本 App 標成日常禮貌。',
          ],
          items: <SoundItem>[
            _sound('안녕하세요.', '你好。', SpeechTag.polite),
            _sound('처음 뵙겠습니다.', '初次見面。', SpeechTag.formal),
            _sound('만나서 반갑습니다.', '很高興見到你。', SpeechTag.formal),
            _sound('잘 부탁드립니다.', '請多指教。', SpeechTag.formal),
          ],
        ),
        if (CourseOptions.showWorkplace)
          LessonCard.concept(
            id: 'u1:formal_note',
            title: '職場／正式版的句尾',
            paragraphs: const <String>[
              '職場、面試、對客人說話時，句尾會換成更正式的 -ㅂ니다／습니다。本單元只要認得 입니다（是）。',
            ],
            grammarRefs: const <String>['mnida'],
          ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u1:formal',
          title: '職場／正式版：입니다',
          paragraphs: const <String>[
            '職場、面試、對客人自我介紹時，把 이에요／예요 換成「입니다」就好，不用分有沒有收尾音。只要認得這一個變化，先聽懂就行，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('저는 민수입니다.', '我是民秀。', SpeechTag.formal),
            _sound('저는 대만 사람입니다.', '我是台灣人。', SpeechTag.formal),
            _sound('저는 회사원입니다.', '我是上班族。', SpeechTag.formal),
          ],
        ),
        if (CourseOptions.showHonorific)
          LessonCard.concept(
            id: 'u1:polite_note',
            title: '對陌生人、長輩的尊敬說法',
            paragraphs: const <String>[
              '句子裡加上 -(으)시-（例如 이세요、세요），表示尊敬對方，比 해요體 更客氣。',
            ],
            grammarRefs: const <String>['speech_si'],
          ),
        if (CourseOptions.showHonorific)
          // 尊敬說法（-(이)세요、주시겠어요）：目前隱藏。
        LessonCard.sound(
          id: 'u1:polite',
          title: '對陌生人、長輩：很禮貌又自然的說法',
          paragraphs: const <String>[
            '問陌生人或年長的人時，把「이에요」換成「이세요」（沒有收尾音時用「세요」）會更客氣，比 합니다體 日常得多，平常用這個就夠了。',
          ],
          items: <SoundItem>[
            _sound('학생이세요?', '請問您是學生嗎？', SpeechTag.honorific),
            _sound('대만 사람이세요?', '請問您是台灣人嗎？', SpeechTag.honorific),
            _sound('선생님이세요?', '請問您是老師嗎？', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u1:dialog',
          title: '短對話：第一次見面',
          paragraphs: const <String>[
            'A 是民秀，B 是剛認識的人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '안녕하세요. 저는 민수예요.', '你好，我是民秀。', SpeechTag.polite),
            _line('B', '안녕하세요. 저는 지아예요.', '你好，我是智雅。', SpeechTag.polite),
            _line('A', '대만 사람이에요?', '你是台灣人嗎？', SpeechTag.polite),
            _line('B', '네, 대만 사람이에요.', '是，我是台灣人。', SpeechTag.polite),
            _line('A', '학생이에요?', '你是學生嗎？', SpeechTag.polite),
            _line('B', '아니요, 회사원이에요.', '不是，我是上班族。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        ..._wordSeeds(const <String>[
          'word:이름',
          'word:학생',
          'word:대학생',
          'word:선생님',
          'word:회사원',
          'word:사람',
          'word:한국 사람',
          'word:대만 사람',
          'word:의사#醫',
          'word:한국',
          'word:대만',
          'word:안녕하세요',
          'word:아니요',
        ]),
      ],
    );

Lesson _unitWhatIsThis() => Lesson(
      id: 'unit-2',
      group: LessonGroup.unit,
      title: '單元 2・這是什麼',
      summary: '用「이것／그것／저것」指東西，並問「這是什麼」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u2:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會指著東西問「這是什麼？」，並回答「這是___。」',
            '會用到上一個單元的「이에요／예요」，再多學三個指示詞（이것、그것、저것）和疑問詞「뭐」（什麼）。',
            '句子全部是敬語，每句都標了語氣。跟陌生人說話用 해요體 就夠禮貌。',
          ],
        ),
        LessonCard.concept(
          id: 'u2:this_that',
          title: '이것・그것・저것：看東西離誰近',
          paragraphs: const <String>[
            '이것＝離說話的人近的東西（這個）。그것＝離聽的人近的東西（那個）。저것＝離兩個人都遠的東西（那個）。',
            '所以你指著自己手上的東西問「이것은 뭐예요?」，對方回答時通常會說「그것은 ○○이에요」，因為對他來說，那個東西在你那邊。這是中文沒有的分法，一開始容易搞混，多聽幾次對話就會習慣。',
            '이것、그것、저것 最後都有收尾音，所以後面接「은」，不是「는」。這就是單元 1 學過的 는：前面有收尾音時改成 은。',
            '「뭐예요?」＝ 뭐（什麼）＋ 예요（是），也是單元 1 的 이에요／예요：뭐 沒有收尾音，所以用 예요。中文說「這是什麼？」，韓文的順序是「이것은 뭐예요?」（這個呢 什麼 是？）。',
            '口語裡常縮短：이것은 → 이건、이것이 → 이게。所以實際上常聽到「이건 뭐예요?」「이게 뭐예요?」。本單元先用完整的 이것은，聽到縮短版時知道是同一個意思就好。',
          ],
        ),
        LessonCard.sound(
          id: 'u2:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '뭐 是「什麼」，日常口語最常用。누구 是「誰」。',
          ],
          items: <SoundItem>[
            _sound('이것', '這個'),
            _sound('그것', '那個'),
            _sound('저것', '那個（遠）'),
            _sound('뭐', '什麼'),
            _sound('누구', '誰'),
            _sound('책', '書'),
            _sound('가방', '包包'),
            _sound('휴대폰', '手機'),
            _sound('물', '水'),
            _sound('커피', '咖啡'),
            _sound('우유', '牛奶'),
            _sound('의자', '椅子'),
            _sound('문', '門'),
          ],
        ),
        LessonCard.sound(
          id: 'u2:drill1',
          title: '換詞練習・這是…',
          paragraphs: const <String>[
            '固定句型：「이것은 ___이에요／예요.」把底線換成不同的東西，也試著把 이것 換成 그것、저것。',
          ],
          items: <SoundItem>[
            _sound('이것은 뭐예요?', '這是什麼？', SpeechTag.polite),
            _sound('그것은 뭐예요?', '那是什麼？', SpeechTag.polite),
            _sound('저것은 뭐예요?', '那個（遠處的）是什麼？', SpeechTag.polite),
            _sound('이것은 책이에요.', '這是書。', SpeechTag.polite),
            _sound('그것은 가방이에요.', '那是包包。', SpeechTag.polite),
            _sound('저것은 휴대폰이에요.', '那個是手機。', SpeechTag.polite),
            _sound('이것은 물이에요.', '這是水。', SpeechTag.polite),
            _sound('그것은 커피예요.', '那是咖啡。', SpeechTag.polite),
            _sound('저것은 우유예요.', '那個是牛奶。', SpeechTag.polite),
            _sound('이것은 의자예요.', '這是椅子。', SpeechTag.polite),
            _sound('저것은 문이에요.', '那個是門。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u2:drill2',
          title: '換詞練習・這不是…',
          paragraphs: const <String>[
            '和單元 1 的 이／가 아니에요 一樣：前一個詞有收尾音用「이 아니에요」（책이 아니에요），沒有用「가 아니에요」（커피가 아니에요）。',
          ],
          items: <SoundItem>[
            _sound('이것은 책이 아니에요.', '這不是書。', SpeechTag.polite),
            _sound('그것은 물이 아니에요.', '那不是水。', SpeechTag.polite),
            _sound('저것은 휴대폰이 아니에요.', '那個不是手機。', SpeechTag.polite),
            _sound('이것은 커피가 아니에요.', '這不是咖啡。', SpeechTag.polite),
            _sound('누구예요?', '是誰？', SpeechTag.polite),
          ],
        ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u2:formal',
          title: '職場／正式版：입니다',
          paragraphs: const <String>[
            '正式場合把 이에요／예요 換成「입니다」，問句換成「입니까?」。先聽懂就好，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('이것은 무엇입니까?', '這是什麼？', SpeechTag.formal),
            _sound('그것은 가방입니다.', '那是包包。', SpeechTag.formal),
            _sound('네, 저것은 휴대폰입니다.', '是，那個是手機。', SpeechTag.formal),
          ],
        ),
        LessonCard.sound(
          id: 'u2:polite',
          title: '對陌生人：很禮貌又自然的說法',
          paragraphs: const <String>[
            '問不認識的人，前面先加一句「실례합니다」（不好意思），後面用 해요體 就夠禮貌。',
          ],
          items: <SoundItem>[
            _sound('실례합니다. 이것은 뭐예요?', '不好意思，這是什麼？', SpeechTag.polite),
            _sound('실례합니다. 저것은 뭐예요?', '不好意思，那個是什麼？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u2:dialog',
          title: '短對話：這是什麼？',
          paragraphs: const <String>[
            'A 指著東西問，B 回答。注意 A 說 이것、B 說 그것。',
          ],
          items: <SoundItem>[
            _line('A', '이것은 뭐예요?', '這是什麼？', SpeechTag.polite),
            _line('B', '그것은 가방이에요.', '那是包包。', SpeechTag.polite),
            _line('A', '저것은 휴대폰이에요?', '那個是手機嗎？', SpeechTag.polite),
            _line('B', '네, 저것은 휴대폰이에요.', '是，那個是手機。', SpeechTag.polite),
            _line('A', '이것은 물이에요?', '這是水嗎？', SpeechTag.polite),
            _line('B', '아니요, 그것은 물이 아니에요. 커피예요.', '不是，那不是水，是咖啡。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        ..._wordSeeds(const <String>[
          'word:이것',
          'word:그것',
          'word:저것',
          'word:뭐',
          'word:누구',
          'word:책',
          'word:가방',
          'word:휴대폰',
          'word:물',
          'word:커피',
          'word:우유',
          'word:의자',
          'word:문',
        ]),
      ],
    );

Lesson _unitOrdering() => Lesson(
      id: 'unit-3',
      group: LessonGroup.unit,
      title: '單元 3・點餐',
      summary: '用「___ 주세요」點東西、說數量，並說要結帳、外帶。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u3:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會在餐廳、咖啡店點東西：「___ 주세요.」（請給我___。）',
            '做法：先認識會用到的詞，再把同一個句型換上不同的食物和數量反覆練，最後聽一段只有 6 句的點餐對話。',
            '「주세요」是 해요體的請求說法，禮貌又自然，對店員、服務生都可以直接用。店員對你說的話會更客氣（句子裡會有「-세요」「-겠습니다」），這些你只要聽得懂就好。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u3:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。「주세요」是「請給我」，後面學的每一句都會用到它。',
          ],
          items: <SoundItem>[
            _sound('주세요', '請給我'),
            _sound('메뉴', '菜單'),
            _sound('물', '水'),
            _sound('커피', '咖啡'),
            _sound('김밥', '紫菜飯卷'),
            _sound('비빔밥', '拌飯'),
            _sound('라면', '泡麵'),
            _sound('하나', '一（個）'),
            _sound('둘', '二（個）'),
            _sound('셋', '三（個）'),
            _sound('잔', '杯'),
            _sound('계산', '結帳'),
            _sound('포장', '外帶'),
          ],
        ),
        LessonCard.concept(
          id: 'u3:pattern',
          title: '句型：___ 주세요',
          paragraphs: const <String>[
            '「___ 주세요」＝ 請給我___。底線放想要的東西，例如 물 주세요（請給我水）。',
            '中文的「請給我」在前面，韓文的 주세요 在後面：물 주세요 → 水 請給我。',
            '東西直接放在 주세요 前面就好，點餐時這樣說最自然。（完整的說法會在東西後面加 을／를，之後的單元會學。）',
            '加上「좀」（一下）語氣會更柔和：메뉴 좀 주세요（請給我一下菜單）。',
            '「더 주세요」＝請再多給我一些。',
          ],
        ),
        LessonCard.sound(
          id: 'u3:drill1',
          title: '換詞練習・請給我…',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('메뉴 좀 주세요.', '請給我菜單。', SpeechTag.polite),
            _sound('물 주세요.', '請給我水。', SpeechTag.polite),
            _sound('커피 주세요.', '請給我咖啡。', SpeechTag.polite),
            _sound('김밥 주세요.', '請給我紫菜飯卷。', SpeechTag.polite),
            _sound('비빔밥 주세요.', '請給我拌飯。', SpeechTag.polite),
            _sound('라면 주세요.', '請給我泡麵。', SpeechTag.polite),
            _sound('영수증 주세요.', '請給我收據。', SpeechTag.polite),
            _sound('더 주세요.', '請再給我一些。', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u3:number',
          title: '說數量：一、二、三',
          paragraphs: const <String>[
            '韓語有兩套數字。點餐、數個數用的是「固有數詞」：하나（1）、둘（2）、셋（3）。',
            '數量放在東西後面：김밥 하나 주세요（請給我一份紫菜飯卷）。',
            '後面接量詞（例如 잔＝杯）時，數字會縮短：하나 → 한、둘 → 두、셋 → 세。所以是「커피 한 잔」「물 두 잔」「콜라 세 잔」。',
            '四以上之後的數字與另一套（일 이 삼…）的用法，之後的單元再學。',
          ],
        ),
        LessonCard.sound(
          id: 'u3:drill2',
          title: '換詞練習・說數量',
          paragraphs: const <String>[
            '東西 ＋ 數量 ＋ 주세요。有量詞「잔」時，用 한／두／세。',
          ],
          items: <SoundItem>[
            _sound('김밥 하나 주세요.', '請給我一份紫菜飯卷。', SpeechTag.polite),
            _sound('비빔밥 하나 주세요.', '請給我一份拌飯。', SpeechTag.polite),
            _sound('라면 둘 주세요.', '請給我兩份泡麵。', SpeechTag.polite),
            _sound('커피 한 잔 주세요.', '請給我一杯咖啡。', SpeechTag.polite),
            _sound('물 두 잔 주세요.', '請給我兩杯水。', SpeechTag.polite),
            _sound('콜라 세 잔 주세요.', '請給我三杯可樂。', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u3:help',
          title: '句型：___해 주세요（請幫我…）',
          paragraphs: const <String>[
            '前面的 주세요 是「請給我（東西）」；把它接在動詞後面，意思就變成「請幫我（做某件事）」。',
            '■ 本單元用到的兩個',
            '・계산하다（結帳）→ 계산해 주세요（請幫我結帳）',
            '・포장하다（外帶、打包）→ 포장해 주세요（請幫我外帶）',
            '■ 怎麼變',
            '계산（結帳）＋ 하다（做）→ 계산하다（結帳這個動作）。這種以 하다 結尾的動詞，接 주세요 時把 하다 換成 해：계산하다 → 계산해 → 계산해 주세요。一般在 해 和 주세요 中間空一格（本 App 一律空格）。',
            '其他不是 하다 結尾的動詞也能這樣用，但變化方式不同，之後的單元遇到時再學。',
            '■ 問價錢',
            '「얼마예요?」＝ 얼마（多少錢）＋ 예요（是），還是單元 1 的 이에요／예요。',
          ],
          grammarRefs: const <String>['a_eo_juseyo'],
        ),
        LessonCard.sound(
          id: 'u3:pay',
          title: '結帳、外帶、問價錢',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('계산해 주세요.', '請幫我結帳。', SpeechTag.polite),
            _sound('포장해 주세요.', '請幫我外帶。', SpeechTag.polite),
            _sound('커피는 얼마예요?', '咖啡多少錢？', SpeechTag.polite),
            _sound('비빔밥은 얼마예요?', '拌飯多少錢？', SpeechTag.polite),
          ],
        ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u3:formal',
          title: '職場／正式版：부탁드립니다',
          paragraphs: const <String>[
            '正式場合（例如商務聚餐）點餐，常用「부탁드립니다」（麻煩您）。先聽懂就好，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('주문하겠습니다.', '我要點餐了。', SpeechTag.formal),
            _sound('물 한 잔 부탁드립니다.', '麻煩給我一杯水。', SpeechTag.formal),
            _sound('계산 부탁드립니다.', '麻煩結帳。', SpeechTag.formal),
          ],
        ),
        if (CourseOptions.showHonorific)
          // 尊敬說法（-(이)세요、주시겠어요）：目前隱藏。
        LessonCard.sound(
          id: 'u3:polite',
          title: '對陌生人、長輩：更客氣的請求',
          paragraphs: const <String>[
            '把「주세요」換成「주시겠어요?」，意思是「可以請您給我…嗎？」，語氣更客氣，跟不認識的人說很合適。',
          ],
          items: <SoundItem>[
            _sound('물 좀 주시겠어요?', '可以請您給我一點水嗎？', SpeechTag.honorific),
            _sound('계산해 주시겠어요?', '可以請您幫我結帳嗎？', SpeechTag.honorific),
            _sound('포장해 주시겠어요?', '可以請您幫我外帶嗎？', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u3:dialog',
          title: '短對話：在餐廳點餐',
          paragraphs: const <String>[
            'A 是店員，B 是客人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。注意店員說的是更客氣的說法。',
          ],
          items: <SoundItem>[
            _line('A', '어서 오세요.', '歡迎光臨。', SpeechTag.honorific),
            _line('B', '메뉴 좀 주세요.', '請給我菜單。', SpeechTag.polite),
            _line('A', '네, 여기 있습니다.', '好的，在這裡。', SpeechTag.formal),
            _line('B', '김밥 하나, 물 두 잔 주세요.', '請給我一份紫菜飯卷、兩杯水。', SpeechTag.polite),
            _line('A', '네, 알겠습니다.', '好的，知道了。', SpeechTag.formal),
            _line('B', '계산해 주세요.', '請幫我結帳。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        ..._wordSeeds(const <String>[
          'word:메뉴',
          'word:물',
          'word:커피',
          'word:김밥',
          'word:비빔밥',
          'word:라면',
          'word:하나',
          'word:둘',
          'word:셋',
          'word:잔',
          'word:계산',
          'word:포장',
          'word:영수증',
          'word:더',
          'word:얼마',
        ]),
      ],
    );

Lesson _unitTime() => Lesson(
      id: 'unit-4',
      group: LessonGroup.unit,
      title: '單元 4・現在幾點',
      summary: '用「지금 ___ 시예요」說現在幾點，並學會問「몇 시예요?」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u4:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會問時間與回答時間：「지금 몇 시예요?」「지금 세 시예요.」',
            '做法：先認識會用到的詞，再把同一個句型換上 1 到 12 點反覆練，最後聽一段只有 5 句的問時間對話。',
            '說「幾點」時用的是「固有數詞」（하나、둘、셋…，和單元 3 學過的一樣）；說「幾分」時用另一套（일、이、삼…）。本單元只用到「오 분」「십 분」。',
            '每個句子底下都有語氣標籤。對陌生人的說法放在對話前面的卡片。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u4:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('지금', '現在'),
            _sound('몇 시', '幾點'),
            _sound('시', '點（鐘）'),
            _sound('분', '分（鐘）'),
            _sound('반', '半'),
            _sound('오전', '上午'),
            _sound('오후', '下午'),
            _sound('아침', '早上；早餐'),
            _sound('점심', '中午；午餐'),
            _sound('저녁', '傍晚；晚餐'),
          ],
        ),
        LessonCard.concept(
          id: 'u4:number',
          title: '說「幾點」：1 到 12',
          paragraphs: const <String>[
            '幾點用固有數詞，後面接「시」。1 到 4 和 11、12 在「시」前面會縮短：',
            '1 點＝한 시、2 點＝두 시、3 點＝세 시、4 點＝네 시。',
            '5 點＝다섯 시、6 點＝여섯 시、7 點＝일곱 시、8 點＝여덟 시、9 點＝아홉 시、10 點＝열 시。',
            '11 點＝열한 시、12 點＝열두 시。',
            '這些數字的形式是自行整理，尚未對照官方資料查核（見 docs/content_sources.md）。',
          ],
        ),
        LessonCard.sound(
          id: 'u4:drill1',
          title: '換詞練習・現在幾點',
          paragraphs: const <String>[
            '句型：지금 ＋ 數字 ＋ 시예요。每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('지금 한 시예요.', '現在一點。', SpeechTag.polite),
            _sound('지금 두 시예요.', '現在兩點。', SpeechTag.polite),
            _sound('지금 세 시예요.', '現在三點。', SpeechTag.polite),
            _sound('지금 네 시예요.', '現在四點。', SpeechTag.polite),
            _sound('지금 다섯 시예요.', '現在五點。', SpeechTag.polite),
            _sound('지금 여섯 시예요.', '現在六點。', SpeechTag.polite),
            _sound('지금 일곱 시예요.', '現在七點。', SpeechTag.polite),
            _sound('지금 여덟 시예요.', '現在八點。', SpeechTag.polite),
            _sound('지금 아홉 시예요.', '現在九點。', SpeechTag.polite),
            _sound('지금 열 시예요.', '現在十點。', SpeechTag.polite),
            _sound('지금 열한 시예요.', '現在十一點。', SpeechTag.polite),
            _sound('지금 열두 시예요.', '現在十二點。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u4:half',
          title: '半點與幾分',
          paragraphs: const <String>[
            '「반」＝半，放在「시」後面：두 시 반＝兩點半。',
            '幾分用另一套數字，這裡先認「오 분」（5 分）和「십 분」（10 分）。',
            '「오전」（上午）、「오후」（下午）放在時間前面。',
          ],
          items: <SoundItem>[
            _sound('두 시 반이에요.', '兩點半。', SpeechTag.polite),
            _sound('일곱 시 반이에요.', '七點半。', SpeechTag.polite),
            _sound('세 시 십 분이에요.', '三點十分。', SpeechTag.polite),
            _sound('여덟 시 오 분이에요.', '八點五分。', SpeechTag.polite),
            _sound('오전 아홉 시예요.', '上午九點。', SpeechTag.polite),
            _sound('오후 세 시예요.', '下午三點。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u4:ask',
          title: '問「幾點」',
          paragraphs: const <String>[
            '「몇 시예요?」＝幾點？可以問現在幾點，也可以問某件事幾點。',
          ],
          items: <SoundItem>[
            _sound('지금 몇 시예요?', '現在幾點？', SpeechTag.polite),
            _sound('아침은 몇 시예요?', '早餐幾點？', SpeechTag.polite),
            _sound('점심은 몇 시예요?', '午餐幾點？', SpeechTag.polite),
            _sound('저녁은 몇 시예요?', '晚餐幾點？', SpeechTag.polite),
          ],
        ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u4:formal',
          title: '職場／正式版：입니다',
          paragraphs: const <String>[
            '正式場合把 이에요／예요 換成「입니다」，問句換成「입니까?」。先聽懂就好，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('지금은 세 시입니다.', '現在是三點。', SpeechTag.formal),
            _sound('지금 몇 시입니까?', '現在幾點？', SpeechTag.formal),
            _sound('두 시 반입니다.', '兩點半。', SpeechTag.formal),
          ],
        ),
        LessonCard.sound(
          id: 'u4:polite',
          title: '對陌生人：很禮貌又自然的說法',
          paragraphs: const <String>[
            '問不認識的人時間，前面先說「실례합니다」（不好意思）或「저기요」（不好意思，叫住對方時用），後面用 해요體 就夠禮貌。',
          ],
          items: <SoundItem>[
            _sound('실례합니다. 지금 몇 시예요?', '不好意思，現在幾點？', SpeechTag.polite),
            _sound('저기요, 지금 몇 시예요?', '不好意思（叫住對方），現在幾點？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u4:dialog',
          title: '短對話：在飯店問時間',
          paragraphs: const <String>[
            'A 是住客，B 是飯店櫃檯人員。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '실례합니다. 지금 몇 시예요?', '不好意思，現在幾點？', SpeechTag.polite),
            _line('B', '오전 열한 시 반이에요.', '上午十一點半。', SpeechTag.polite),
            _line('A', '점심은 몇 시예요?', '午餐是幾點？', SpeechTag.polite),
            _line('B', '열두 시 반이에요.', '十二點半。', SpeechTag.polite),
            _line('A', '감사합니다.', '謝謝。', SpeechTag.formal),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:지금',
        'word:시',
        'word:분#分',
        'word:반#半',
        'word:오전',
        'word:오후',
        'word:아침',
        'word:점심',
        'word:저녁',
        'word:다섯',
        'word:여섯',
        'word:일곱',
        'word:여덟',
        'word:아홉',
        'word:열#十',
      ]),
    );

Lesson _unitShopping() => Lesson(
      id: 'unit-5',
      group: LessonGroup.unit,
      title: '單元 5・購物與價錢',
      summary: '用「___ 얼마예요?」問價錢，聽懂「___ 원이에요」，並說要用卡片或現金付款。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u5:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會在商店問價錢、聽懂價錢、付款：「이거 얼마예요?」「만 원이에요.」',
            '做法：先認識會用到的詞，再把同一個句型換上不同的東西反覆練，最後聽一段只有 6 句的購物對話。',
            '價錢用的是「漢字數詞」（일、이、삼…），和說「幾點」用的固有數詞不同。',
            '每個句子底下都有語氣標籤。對陌生人的說法放在對話前面的卡片。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u5:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('얼마', '多少（錢）'),
            _sound('원', '韓元'),
            _sound('천', '千'),
            _sound('만', '萬'),
            _sound('가게', '商店'),
            _sound('편의점', '便利商店'),
            _sound('비싸요', '貴（비싸다）'),
            _sound('싸요', '便宜（싸다）'),
            _sound('카드', '卡片；信用卡'),
            _sound('현금', '現金'),
            _sound('봉투', '袋子'),
          ],
        ),
        LessonCard.concept(
          id: 'u5:pattern',
          title: '句型：___ 얼마예요?',
          paragraphs: const <String>[
            '「___ 얼마예요?」＝___多少錢？例如 커피는 얼마예요?（咖啡多少錢？）',
            '指著東西問時，口語常說「이거 얼마예요?」（這個多少錢？）。「이거」是「이것」（這個東西）在口語裡的說法。',
            '回答是「___ 원이에요」（是___韓元）。',
          ],
        ),
        LessonCard.sound(
          id: 'u5:drill1',
          title: '換詞練習・多少錢',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('이거 얼마예요?', '這個多少錢？', SpeechTag.polite),
            _sound('커피는 얼마예요?', '咖啡多少錢？', SpeechTag.polite),
            _sound('사과는 얼마예요?', '蘋果多少錢？', SpeechTag.polite),
            _sound('우산은 얼마예요?', '雨傘多少錢？', SpeechTag.polite),
            _sound('이 가방은 얼마예요?', '這個包包多少錢？', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u5:number',
          title: '聽懂價錢：千與萬',
          paragraphs: const <String>[
            '韓國的價錢常是幾千、幾萬韓元。數字用漢字數詞：이（2）、삼（3）、오（5）。',
            '1,000＝천（前面不加「일」），2,000＝이천，5,000＝오천。',
            '10,000＝만（前面也不加「일」），20,000＝이만，15,000＝만 오천。',
            '注意：韓語是以「萬」為單位算的，和中文一樣，不像英文以「千」為單位。',
            '這些數字的說法是自行整理，尚未對照官方資料查核（見 docs/content_sources.md）。',
          ],
        ),
        LessonCard.sound(
          id: 'u5:drill2',
          title: '換詞練習・價錢',
          paragraphs: const <String>[
            '句型：數字 ＋ 원이에요。',
          ],
          items: <SoundItem>[
            _sound('천 원이에요.', '一千韓元。', SpeechTag.polite),
            _sound('이천 원이에요.', '兩千韓元。', SpeechTag.polite),
            _sound('오천 원이에요.', '五千韓元。', SpeechTag.polite),
            _sound('만 원이에요.', '一萬韓元。', SpeechTag.polite),
            _sound('만 오천 원이에요.', '一萬五千韓元。', SpeechTag.polite),
            _sound('이만 원이에요.', '兩萬韓元。', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u5:grammar',
          title: '本單元的兩個新文法',
          paragraphs: const <String>[
            '■ 비싸요、싸요：字典裡的樣子和說話時的樣子',
            '韓文的形容詞和動詞，在字典裡都以 다 結尾，叫「辭典形」：비싸다（貴）、싸다（便宜）。',
            '辭典形不能直接拿來說話。說話時把 다 拿掉（剩下的部分叫「語幹」），再接上禮貌的語尾 아요／어요：',
            '・비싸다 → 語幹 비싸 → 비싸 ＋ 아요 → 비싸요',
            '・싸다 → 語幹 싸 → 싸 ＋ 아요 → 싸요',
            '選 아요 還是 어요，看語幹最後一個字的母音：是 ㅏ 或 ㅗ 接 아요，其他接 어요。비싸、싸 最後的母音都是 ㅏ，所以接 아요；兩個 ㅏ 碰在一起會合成一個，所以寫成 비싸요，不寫 비싸아요。',
            '和中文不同的地方：中文說「這個很貴」，韓文的形容詞本身就能放在句尾，不用加「是」。所以是 좀 비싸요（有點貴），不要寫成 비싸이에요。',
            '■ 카드로、현금으로：用…（付款方式）',
            '로／으로 接在名詞後面，表示「用…」：카드로（用卡片）、현금으로（用現金）。',
            '・前面的字沒有收尾音 → 로：카드 → 카드로',
            '・前面的字有收尾音 → 으로：현금 → 현금으로',
            '・例外：收尾音是 ㄹ 時也用 로，例如 지하철로（搭地鐵），之後的單元會遇到。',
          ],
          grammarRefs: const <String>['basics_dictform', 'ayo_eoyo', 'euro'],
        ),
        LessonCard.sound(
          id: 'u5:pay',
          title: '買下來、付款',
          paragraphs: const <String>[
            '「이거 주세요」＝我要這個（單元 3 學過的 주세요）。',
            '「카드로 계산해 주세요」＝請用卡片結帳：카드로（用卡片）＋ 계산해 주세요（請幫我結帳，單元 3 學過）。',
          ],
          items: <SoundItem>[
            _sound('이거 주세요.', '我要這個。', SpeechTag.polite),
            _sound('카드로 계산해 주세요.', '請用卡片結帳。', SpeechTag.polite),
            _sound('현금으로 계산해 주세요.', '請用現金結帳。', SpeechTag.polite),
            _sound('봉투 하나 주세요.', '請給我一個袋子。', SpeechTag.polite),
            _sound('좀 비싸요.', '有點貴。', SpeechTag.polite),
          ],
        ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u5:formal',
          title: '職場／正式版：입니다',
          paragraphs: const <String>[
            '正式場合把 이에요／예요 換成「입니다」，問句換成「입니까?」。先聽懂就好，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('이것은 얼마입니까?', '這個多少錢？', SpeechTag.formal),
            _sound('만 원입니다.', '一萬韓元。', SpeechTag.formal),
            _sound('카드로 계산하겠습니다.', '我用卡片結帳。', SpeechTag.formal),
          ],
        ),
        LessonCard.sound(
          id: 'u5:polite',
          title: '對陌生人：很禮貌又自然的說法',
          paragraphs: const <String>[
            '前面先說「실례합니다」（不好意思），後面用 해요體 就夠禮貌。',
          ],
          items: <SoundItem>[
            _sound('실례합니다. 이거 얼마예요?', '不好意思，這個多少錢？', SpeechTag.polite),
            if (CourseOptions.showHonorific)
              _sound('봉투 하나 주시겠어요?', '可以請您給我一個袋子嗎？', SpeechTag.honorific),
            if (CourseOptions.showHonorific)
              _sound('카드로 계산해 주시겠어요?', '可以請您幫我用卡片結帳嗎？', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u5:dialog',
          title: '短對話：在商店買東西',
          paragraphs: const <String>[
            'A 是店員，B 是客人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('B', '실례합니다. 이거 얼마예요?', '不好意思，這個多少錢？', SpeechTag.polite),
            _line('A', '만 오천 원이에요.', '一萬五千韓元。', SpeechTag.polite),
            _line('B', '이거 주세요.', '我要這個。', SpeechTag.polite),
            _line('A', '봉투 필요하세요?', '需要袋子嗎？', SpeechTag.honorific),
            _line('B', '아니요, 괜찮아요. 카드로 계산해 주세요.', '不用，沒關係。請用卡片結帳。', SpeechTag.polite),
            _line('A', '네, 감사합니다.', '好的，謝謝。', SpeechTag.formal),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        ..._wordSeeds(const <String>[
          'word:얼마',
          'word:원',
          'word:천',
          'word:만',
          'word:가게',
          'word:편의점',
          'word:비싸다',
          'word:싸다',
          'word:카드',
          'word:현금',
          'word:봉투',
          'word:사과',
          'word:우산',
        ]),
      ],
    );

Lesson _unitDirections() => Lesson(
      id: 'unit-6',
      group: LessonGroup.unit,
      title: '單元 6・問路',
      summary: '用「___ 어디에 있어요?」問地方在哪裡，聽懂左右、前面、旁邊。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u6:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會問地方在哪裡、聽懂簡單的方向：「화장실이 어디에 있어요?」「오른쪽에 있어요.」',
            '做法：先認識會用到的詞，再把同一個句型換上不同的地方反覆練，最後聽一段只有 5 句的問路對話。',
            '每個句子底下都有語氣標籤。對陌生人的說法放在對話前面的卡片。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u6:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('어디', '哪裡'),
            _sound('여기', '這裡'),
            _sound('저기', '那邊'),
            _sound('화장실', '廁所'),
            _sound('역', '車站'),
            _sound('은행', '銀行'),
            _sound('약국', '藥局'),
            _sound('오른쪽', '右邊'),
            _sound('왼쪽', '左邊'),
            _sound('앞', '前面'),
            _sound('옆', '旁邊'),
            _sound('근처', '附近'),
          ],
        ),
        LessonCard.concept(
          id: 'u6:pattern',
          title: '句型：___ 어디에 있어요?',
          paragraphs: const <String>[
            '「地方 ＋ 이／가 어디에 있어요?」＝___在哪裡？這個句型用到三個文法：이／가（標出主角）、에（在某處）、있어요（在）。下面用本單元的句子一個一個說明。',
            '■ 화장실이：地方＋이／가',
            '이／가 接在名詞後面，標出「是誰、是什麼」在這句話裡處在這個狀態。問「廁所在哪裡？」時，廁所是主角，所以說 화장실이。',
            '・有收尾音 → 이：화장실이、은행이、약국이、역이',
            '・沒有收尾音 → 가：카페가',
            '和 은／는 一樣看收尾音，容易記混：有收尾音的是 은 和 이，沒有收尾音的是 는 和 가。',
            '說成 화장실은 어디에 있어요? 也可以，語氣稍有不同；初學先用 이／가 的說法就好。',
            '■ 어디에：地方＋에（在…）',
            '에 接在地方後面，表示「在（那個地方）」，和 있어요 一起用。中文的「在」放在地方前面，韓文的 에 放在地方後面：在右邊 → 오른쪽에 있어요。',
            '에 不受收尾音影響，一律寫 에。',
            '說「在 A 的前面、旁邊」時，順序和中文一樣，最後再加 에：은행 앞에 있어요（在銀行前面）、편의점 옆에 있어요（在便利商店旁邊）。',
            '注意：에 是「在那裡（存在）」。「在那裡做某件事」要用 에서，下一個單元會學。',
            '■ 있어요：在',
            '있어요 的辭典形是 있다，意思是「在」或「有」。這個單元主要用「在」：화장실이 저기에 있어요（廁所在那邊）。',
            '「附近有藥局嗎？」的「有」也是它：근처에 약국 있어요? 口語常把 이／가 省掉。單元 8 會再學「有」和相反詞 없어요（沒有、不在）。',
          ],
          grammarRefs: const <String>['i_ga', 'e', 'itda_eopda'],
        ),
        LessonCard.sound(
          id: 'u6:drill1',
          title: '換詞練習・在哪裡',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('화장실이 어디에 있어요?', '廁所在哪裡？', SpeechTag.polite),
            _sound('역이 어디에 있어요?', '車站在哪裡？', SpeechTag.polite),
            _sound('은행이 어디에 있어요?', '銀行在哪裡？', SpeechTag.polite),
            _sound('약국이 어디에 있어요?', '藥局在哪裡？', SpeechTag.polite),
            _sound('편의점이 어디에 있어요?', '便利商店在哪裡？', SpeechTag.polite),
            _sound('카페가 어디에 있어요?', '咖啡店在哪裡？', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u6:go',
          title: '聽懂指路：___으로 가세요（請往___走）',
          paragraphs: const <String>[
            '對方指路時常說「오른쪽으로 가세요」（請往右邊走），由兩個部分組成。',
            '■ 오른쪽으로：方向＋로／으로（往…）',
            '單元 5 的 로／으로 是「用…」（카드로）；接在方向後面時是「往…」。接法一樣：有收尾音用 으로（오른쪽으로、왼쪽으로），沒有收尾音或收尾音是 ㄹ 用 로。',
            '■ 가세요：請（您）…',
            '가다（去、走）去掉 다 剩下 가，接上 세요，就是客氣地請對方做事：가세요＝請走、請去。它還是 해요體 的句尾，只是多了表示尊敬的 -(으)시-（세요 是 -시- 和 -어요 合在一起的固定寫法，不要自己拼成 가시어요），所以比一般的 해요 說法更尊敬對方，標籤是「尊敬說法」。',
            '單元 3 店員說的「어서 오세요」（歡迎光臨）也是同一個形式：오다（來）→ 오세요。',
            '語幹有收尾音時要多一個 으（-으세요），本單元還用不到。',
            '這個說法多半是路人、店員對你說的，先學會聽懂。自己問路時用 해요體 就夠禮貌，例如 오른쪽이에요?（是右邊嗎？）',
          ],
          grammarRefs: const <String>['euseyo'],
        ),
        LessonCard.sound(
          id: 'u6:drill2',
          title: '換詞練習・聽懂位置',
          paragraphs: const <String>[
            '「___에 있어요」＝在___。「___으로／로 가세요」＝請往___走。',
          ],
          items: <SoundItem>[
            _sound('저기에 있어요.', '在那邊。', SpeechTag.polite),
            _sound('오른쪽에 있어요.', '在右邊。', SpeechTag.polite),
            _sound('왼쪽에 있어요.', '在左邊。', SpeechTag.polite),
            _sound('은행 앞에 있어요.', '在銀行前面。', SpeechTag.polite),
            _sound('편의점 옆에 있어요.', '在便利商店旁邊。', SpeechTag.polite),
            _sound('오른쪽으로 가세요.', '請往右邊走。', SpeechTag.honorific),
            _sound('왼쪽으로 가세요.', '請往左邊走。', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u6:near',
          title: '附近有沒有',
          paragraphs: const <String>[
            '「근처에 ___ 있어요?」＝附近有___嗎？口語常省略 이／가。',
          ],
          items: <SoundItem>[
            _sound('근처에 약국 있어요?', '附近有藥局嗎？', SpeechTag.polite),
            _sound('근처에 편의점 있어요?', '附近有便利商店嗎？', SpeechTag.polite),
            _sound('네, 역 앞에 있어요.', '有，在車站前面。', SpeechTag.polite),
          ],
        ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u6:formal',
          title: '職場／正式版：있습니다',
          paragraphs: const <String>[
            '正式場合把「있어요」換成「있습니다」，問句換成「있습니까?」。先聽懂就好，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('화장실은 어디에 있습니까?', '請問洗手間在哪裡？', SpeechTag.formal),
            _sound('저기에 있습니다.', '在那邊。', SpeechTag.formal),
            _sound('역은 오른쪽에 있습니다.', '車站在右邊。', SpeechTag.formal),
          ],
        ),
        LessonCard.sound(
          id: 'u6:polite',
          title: '對陌生人：很禮貌又自然的說法',
          paragraphs: const <String>[
            '在路上問陌生人，前面先說「실례합니다」（不好意思），後面用 해요體 就夠禮貌。',
          ],
          items: <SoundItem>[
            _sound('실례합니다. 화장실이 어디에 있어요?', '不好意思，廁所在哪裡？', SpeechTag.polite),
            _sound('실례합니다. 이 근처에 약국 있어요?', '不好意思，這附近有藥局嗎？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u6:dialog',
          title: '短對話：在路上問路',
          paragraphs: const <String>[
            '先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '실례합니다. 역이 어디에 있어요?', '不好意思，車站在哪裡？', SpeechTag.polite),
            _line('B', '저기 은행 앞에 있어요.', '在那邊銀行的前面。', SpeechTag.polite),
            _line('A', '오른쪽이에요?', '是右邊嗎？', SpeechTag.polite),
            _line('B', '네, 오른쪽으로 가세요.', '對，請往右邊走。', SpeechTag.honorific),
            _line('A', '감사합니다.', '謝謝。', SpeechTag.formal),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        ..._wordSeeds(const <String>[
          'word:어디',
          'word:여기',
          'word:저기',
          'word:화장실',
          'word:역',
          'word:은행',
          'word:약국',
          'word:오른쪽',
          'word:왼쪽',
          'word:앞',
          'word:옆',
          'word:근처',
        ]),
      ],
    );

Lesson _unitTransport() => Lesson(
      id: 'unit-7',
      group: LessonGroup.unit,
      title: '單元 7・交通',
      summary: '用「___에 어떻게 가요?」問怎麼去，聽懂「지하철로 가요」，並學搭計程車的說法。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u7:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會問怎麼去某個地方、聽懂要搭什麼：「공항에 어떻게 가요?」「지하철로 가요.」',
            '做法：先認識會用到的詞，再把同一個句型換上不同的地方與交通工具反覆練，最後聽一段只有 6 句的對話。',
            '每個句子底下都有語氣標籤。對陌生人的說法放在對話前面的卡片。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u7:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('어떻게', '怎麼'),
            _sound('지하철', '地鐵'),
            _sound('버스', '公車'),
            _sound('택시', '計程車'),
            _sound('기차', '火車'),
            _sound('공항', '機場'),
            _sound('정류장', '公車站'),
            _sound('출구', '出口'),
            _sound('교통카드', '交通卡'),
            _sound('표', '票'),
            _sound('타요', '搭（타다）'),
            _sound('내려요', '下車（내리다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u7:pattern',
          title: '句型：___에 어떻게 가요?',
          paragraphs: const <String>[
            '「地方 ＋ 에 어떻게 가요?」＝怎麼去___？回答是「交通工具 ＋ 로 가요」（搭___去）或「交通工具 ＋ 을／를 타세요」（請搭___）。新的文法是 을／를，另外兩個是學過的文法換一種用法。',
            '■ 공항에 가요：地方＋에（到…）',
            '單元 6 的 에 是「在（某處）」；接在要去的地方後面、和 가요（去）一起用時，表示「到…去」：공항에 가요（去機場）。',
            '어떻게＝怎麼。공항에 어떻게 가요? 照韓文順序直翻是「機場－到　怎麼　去？」。',
            '■ 지하철로 가요：交通工具＋로／으로（搭…）',
            '單元 5 的 로／으로（用…）接在交通工具後面，就是「搭…」：버스로、택시로、기차로。지하철 的收尾音是 ㄹ，所以也用 로：지하철로。',
            '■ 지하철을 타세요：東西＋을／를',
            '을／를 接在名詞後面，標出動作的對象。中文是「搭＋地鐵」，動詞在前；韓文是「지하철을＋타요」，名詞在前、動詞放在句尾。',
            '・有收尾音 → 을：지하철을',
            '・沒有收尾音 → 를：버스를',
            '타세요＝請搭：타다（搭）的語幹 타 接上單元 6 的 세요。',
            '口語裡 을／를 常省略，例如單元 3 的 커피 주세요。',
          ],
          grammarRefs: const <String>['eul_reul'],
        ),
        LessonCard.sound(
          id: 'u7:drill1',
          title: '換詞練習・怎麼去',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('공항에 어떻게 가요?', '怎麼去機場？', SpeechTag.polite),
            _sound('서울역에 어떻게 가요?', '怎麼去首爾站？', SpeechTag.polite),
            _sound('시청에 어떻게 가요?', '怎麼去市政府？', SpeechTag.polite),
            _sound('호텔에 어떻게 가요?', '怎麼去飯店？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u7:drill2',
          title: '換詞練習・搭什麼去',
          paragraphs: const <String>[
            '句型：交通工具 ＋ 로 가요，或 交通工具 ＋ 을／를 타세요。',
          ],
          items: <SoundItem>[
            _sound('지하철로 가요.', '搭地鐵去。', SpeechTag.polite),
            _sound('버스로 가요.', '搭公車去。', SpeechTag.polite),
            _sound('택시로 가요.', '搭計程車去。', SpeechTag.polite),
            _sound('기차로 가요.', '搭火車去。', SpeechTag.polite),
            _sound('지하철을 타세요.', '請搭地鐵。', SpeechTag.honorific),
            _sound('버스를 타세요.', '請搭公車。', SpeechTag.honorific),
          ],
        ),
        LessonCard.concept(
          id: 'u7:ride_grammar',
          title: '搭車時會用到的文法',
          paragraphs: const <String>[
            '■ 여기서：在這裡（做某件事）',
            '에서 接在地方後面，表示「在那裡做某件事」。여기서 是 여기에서（在這裡）的縮短說法，口語很常用。',
            '和單元 6 的 에 比較：에 是「在那裡（存在）」，和 있어요 一起用；에서 是「在那裡做動作」，和 내리다（下車）這類動作一起用。',
            '・여기에 있어요.（在這裡。）',
            '・여기서 내려 주세요.（請讓我在這裡下車。）',
            '에서 也可以表示「從…」，之後的單元會遇到。',
            '■ 가 주세요、내려 주세요：請幫我…',
            '單元 3 學過 하다 結尾的「___해 주세요」（請幫我…）；這裡學一般動詞的接法：變法和單元 5 的 아요／어요 一樣，只是把 요 換成「空格＋주세요」：',
            '・가다 → 가요 → 가 주세요（請載我到…）',
            '・내리다 → 내려요 → 내려 주세요（請讓我下車）。語幹最後是 ㅣ 時，ㅣ＋어 會合成 ㅕ：내리＋어 → 내려。',
            '■ 버스도：也',
            '도 接在名詞後面，表示「也」：버스도 있어요（也有公車）。不受收尾音影響，一律寫 도。',
            '도 會取代原本的 이／가、을／를：버스가 있어요 → 버스도 있어요，不要疊在一起寫成 버스가도。',
          ],
          grammarRefs: const <String>['eseo', 'do'],
        ),
        LessonCard.sound(
          id: 'u7:ride',
          title: '搭車時用得到的話',
          paragraphs: const <String>[
            '搭計程車時說「地方 ＋ 에 가 주세요」（請到___）。',
            '上公車前可以問「이 버스 ___에 가요?」（這班公車到___嗎？）。',
            '搭計程車要下車時說「여기서 내려 주세요」（請讓我在這裡下車）。',
            '跟司機說目的地時，也常聽到「공항으로 가 주세요」或直接說「공항 가 주세요」，意思一樣。',
          ],
          items: <SoundItem>[
            _sound('공항에 가 주세요.', '請到機場。', SpeechTag.polite),
            _sound('서울역에 가 주세요.', '請到首爾站。', SpeechTag.polite),
            _sound('이 버스 공항에 가요?', '這班公車到機場嗎？', SpeechTag.polite),
            _sound('여기서 내려 주세요.', '請讓我在這裡下車。', SpeechTag.polite),
          ],
        ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u7:formal',
          title: '職場／正式版：갑니다',
          paragraphs: const <String>[
            '正式場合把「가요」換成「갑니다」，問句換成「갑니까?」。先聽懂就好，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('공항에 어떻게 갑니까?', '請問怎麼去機場？', SpeechTag.formal),
            _sound('지하철로 갑니다.', '搭地鐵去。', SpeechTag.formal),
            _sound('버스를 탑니다.', '搭公車。', SpeechTag.formal),
          ],
        ),
        LessonCard.sound(
          id: 'u7:polite',
          title: '對陌生人：很禮貌又自然的說法',
          paragraphs: const <String>[
            '問路人時先說「실례합니다」（不好意思），後面用 해요體 就夠禮貌。',
          ],
          items: <SoundItem>[
            _sound('실례합니다. 공항에 어떻게 가요?', '不好意思，怎麼去機場？', SpeechTag.polite),
            if (CourseOptions.showHonorific)
              _sound('공항에 가 주시겠어요?', '可以請您載我到機場嗎？', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u7:dialog',
          title: '短對話：問怎麼去機場',
          paragraphs: const <String>[
            '先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '실례합니다. 공항에 어떻게 가요?', '不好意思，怎麼去機場？', SpeechTag.polite),
            _line('B', '지하철로 가요.', '搭地鐵去。', SpeechTag.polite),
            _line('A', '버스는요?', '那公車呢？', SpeechTag.polite),
            _line('B', '버스도 있어요. 정류장은 저기에 있어요.', '也有公車。公車站在那邊。', SpeechTag.polite),
            _line('A', '감사합니다.', '謝謝。', SpeechTag.formal),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        ..._wordSeeds(const <String>[
          'word:어떻게',
          'word:지하철',
          'word:버스',
          'word:택시',
          'word:기차',
          'word:공항',
          'word:정류장',
          'word:출구',
          'word:교통카드',
          'word:표',
          'word:타다',
          'word:내리다',
        ]),
      ],
    );

Lesson _unitLodging() => Lesson(
      id: 'unit-8',
      group: LessonGroup.unit,
      title: '單元 8・住宿',
      summary: '用「___ 있어요?」問有沒有，辦理入住、問樓層與設施。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u8:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會在飯店問有沒有某樣東西、辦理入住：「수건 있어요?」「방은 오 층이에요.」',
            '做法：先認識會用到的詞，再把同一個句型換上不同的東西反覆練，最後聽一段只有 6 句的入住對話。',
            '每個句子底下都有語氣標籤。對陌生人的說法放在對話前面的卡片。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u8:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('호텔', '飯店'),
            _sound('숙소', '住宿的地方'),
            _sound('방', '房間'),
            _sound('예약', '預約；訂房'),
            _sound('열쇠', '鑰匙'),
            _sound('수건', '毛巾'),
            _sound('칫솔', '牙刷'),
            _sound('엘리베이터', '電梯'),
            _sound('층', '樓；層'),
            _sound('바꿔요', '換（바꾸다）'),
            _sound('있어요', '有；在'),
            _sound('없어요', '沒有；不在'),
          ],
        ),
        LessonCard.concept(
          id: 'u8:pattern',
          title: '句型：___ 있어요?',
          paragraphs: const <String>[
            '「___ 있어요?」＝有___嗎？口語常省略 이／가：방 있어요?（有房間嗎？）',
            '回答：「네, 있어요.」（有）／「아니요, 없어요.」（沒有）。',
            '「있어요」在單元 6 是「在」，這裡是「有」，同一個詞兩種意思。',
          ],
        ),
        LessonCard.sound(
          id: 'u8:drill1',
          title: '換詞練習・有沒有',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('오늘 방 있어요?', '今天有房間嗎？', SpeechTag.polite),
            _sound('수건 있어요?', '有毛巾嗎？', SpeechTag.polite),
            _sound('칫솔 있어요?', '有牙刷嗎？', SpeechTag.polite),
            _sound('엘리베이터 있어요?', '有電梯嗎？', SpeechTag.polite),
            _sound('네, 있어요.', '有。', SpeechTag.polite),
            _sound('아니요, 없어요.', '沒有。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u8:floor',
          title: '樓層與設施',
          paragraphs: const <String>[
            '樓層用漢字數詞 ＋ 층：일 층（1 樓）、삼 층（3 樓）、오 층（5 樓）。',
            '「몇 층」＝幾樓。',
          ],
          items: <SoundItem>[
            _sound('방은 몇 층이에요?', '房間在幾樓？', SpeechTag.polite),
            _sound('오 층이에요.', '五樓。', SpeechTag.polite),
            _sound('식당은 일 층에 있어요.', '餐廳在一樓。', SpeechTag.polite),
            _sound('엘리베이터는 저기에 있어요.', '電梯在那邊。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u8:checkin',
          title: '辦理入住',
          paragraphs: const <String>[
            '「예약했어요」＝我有訂房（已經預約了）。「했어요」是過去式，下一張卡片說明。',
          ],
          items: <SoundItem>[
            _sound('예약했어요.', '我有訂房。', SpeechTag.polite),
            _sound('이름은 민수예요.', '名字是民秀。', SpeechTag.polite),
            _sound('열쇠 주세요.', '請給我鑰匙。', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u8:past',
          title: '文法：예약했어요（過去式）',
          paragraphs: const <String>[
            '■ 一句話',
            '說已經發生的事，要把句尾改成過去式。예약했어요＝預約了（所以中文可以說「我有訂房」）。',
            '■ 怎麼變',
            '先變成現在式，再把最後的 요 換成 ㅆ어요，ㅆ 寫在前一個字的下面。現在式的變法：一般動詞照單元 5 的 아요／어요；하다 結尾的動詞把 하다 換成 해요（和單元 3 的 계산해 주세요 一樣把 하다 換成 해）。',
            '・예약하다 → 예약해요 → 예약했어요（預約了）',
            '・가다 → 가요 → 갔어요（去了）',
            '・먹다 → 먹어요 → 먹었어요（吃了）',
            '不管現在式是 아요 還是 어요，過去式的結尾一律是 ㅆ어요。',
            '■ 跟中文比',
            '中文加「了」「已經」，動詞本身不變；韓文是改句尾。',
            '■ 常見錯誤',
            '不要寫成 했요、갔아요、먹았어요。',
            '這個方法只適用於 아요／어요 結尾的動詞、形容詞。이에요／예요（是）、아니에요（不是），以及單元 6 的 -(으)세요，過去式變法不一樣，之後再學。',
          ],
          grammarRefs: const <String>['at_eot'],
        ),
        if (CourseOptions.showWorkplace)
          // 職場／正式版：目前隱藏，之後要加回時把開關改成 true。
        LessonCard.sound(
          id: 'u8:formal',
          title: '職場／正式版：있습니다',
          paragraphs: const <String>[
            '正式場合把「있어요／없어요」換成「있습니다／없습니다」。先聽懂就好，不用現在會說。',
          ],
          items: <SoundItem>[
            _sound('예약했습니다.', '我有訂房。', SpeechTag.formal),
            _sound('방 있습니까?', '請問有房間嗎？', SpeechTag.formal),
            _sound('수건이 없습니다.', '沒有毛巾。', SpeechTag.formal),
          ],
        ),
        LessonCard.sound(
          id: 'u8:polite',
          title: '對陌生人：很禮貌又自然的說法',
          paragraphs: const <String>[
            '找櫃檯人員時，前面先說「실례합니다」（不好意思），後面用 해요體 就夠禮貌。',
          ],
          items: <SoundItem>[
            if (CourseOptions.showHonorific)
              _sound('수건 좀 더 주시겠어요?', '可以請您再給我一些毛巾嗎？', SpeechTag.honorific),
            if (CourseOptions.showHonorific)
              _sound('방 좀 바꿔 주시겠어요?', '可以請您幫我換房間嗎？', SpeechTag.honorific),
            _sound('실례합니다. 엘리베이터가 어디에 있어요?', '不好意思，電梯在哪裡？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u8:dialog',
          title: '短對話：在飯店入住',
          paragraphs: const <String>[
            'A 是櫃檯人員，B 是客人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '어서 오세요.', '歡迎光臨。', SpeechTag.honorific),
            _line('B', '안녕하세요. 예약했어요. 이름은 민수예요.', '您好。我有訂房，名字是民秀。', SpeechTag.polite),
            _line('A', '네, 방은 오 층이에요.', '好的，房間在五樓。', SpeechTag.polite),
            _line('B', '엘리베이터가 어디에 있어요?', '電梯在哪裡？', SpeechTag.polite),
            _line('A', '저기 오른쪽에 있어요.', '在那邊右手邊。', SpeechTag.polite),
            _line('B', '감사합니다.', '謝謝。', SpeechTag.formal),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        ..._wordSeeds(const <String>[
          'word:호텔',
          'word:숙소',
          'word:방',
          'word:예약',
          'word:열쇠',
          'word:수건',
          'word:칫솔',
          'word:엘리베이터',
          'word:층',
          'word:몇',
          'word:식당',
          'word:바꾸다',
        ]),
      ],
    );

Lesson _unitRepair() => Lesson(
      id: 'unit-9',
      group: LessonGroup.unit,
      title: '單元 9・聽不懂的時候',
      summary: '請對方說慢一點、再說一次，說自己韓文不太好，問對方會不會說英文。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u9:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '跟韓國人說話時，一定會遇到聽不懂的時候。這個單元學的句子，是讓對話可以繼續下去的「救命句」。',
            '做法：先認識會用到的詞，再練「請對方怎麼做」和「說自己的狀況」，最後聽一段問路時聽不懂的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u9:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('한국어', '韓文、韓語'),
            _sound('영어', '英文'),
            _sound('중국어', '中文'),
            _sound('조금', '一點點'),
            _sound('천천히', '慢慢地'),
            _sound('다시', '再、重新'),
            _sound('말해요', '說（말하다）'),
            _sound('써요', '寫（쓰다）'),
            _sound('모르겠어요', '不知道、不太懂'),
            _sound('알겠어요', '知道了、明白了'),
            _sound('잠시만요', '請等一下'),
          ],
        ),
        LessonCard.concept(
          id: 'u9:pattern',
          title: '句型：請對方怎麼做、說自己的狀況',
          paragraphs: const <String>[
            '■ 請對方幫忙：-아／어 주세요',
            '單元 3 學過的「請幫我…」：말하다 → 말해 주세요。천천히 말해 주세요＝請說慢一點；다시 말해 주세요＝請再說一次。',
            '쓰다（寫）→ 써 주세요（請寫）：語幹最後是 ㅡ 時，ㅡ 會被省略，和 써요 的變法一樣。',
            '■ 說自己會一點：한국어를 조금 해요',
            '＝我會一點韓文。說「會講某種語言」，韓文常直接用 하다（做）：한국어를 해요。한국어를 的 를 是單元 7 學過的 을／를。',
            '■ 說自己不太會：한국어를 잘 못해요',
            '＝我韓文不太好。못 是「沒辦法、做不到」的意思，用法分兩種，寫法也不同：',
            '・못＋動詞，中間空一格：못 가요（去不了）。',
            '・못하다 連寫是一個詞，意思是「做不好、不擅長」：한국어를 잘 못해요。잘 是「好好地」。',
            '注意 잘못하다 連寫是「做錯」，意思完全不同，所以 잘 和 못해요 中間要空格。',
            '■ 不知道的時候：잘 모르겠어요',
            '聽不懂或不知道時，說「잘 모르겠어요」比直接說「몰라요」委婉，對陌生人比較合適。',
          ],
          grammarRefs: const <String>['mot'],
        ),
        LessonCard.sound(
          id: 'u9:drill1',
          title: '練習・請對方幫忙',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('천천히 말해 주세요.', '請說慢一點。', SpeechTag.polite),
            _sound('조금 천천히 말해 주세요.', '請稍微說慢一點。', SpeechTag.polite),
            _sound('다시 말해 주세요.', '請再說一次。', SpeechTag.polite),
            _sound('한 번 더 말해 주세요.', '請再說一遍。', SpeechTag.polite),
            _sound('여기에 써 주세요.', '請寫在這裡。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u9:drill2',
          title: '練習・說自己的狀況',
          paragraphs: const <String>[
            '「뜻」是「意思」，「무슨」是「什麼（樣的）」；「무슨 뜻이에요?」很常用，先整句記住。',
          ],
          items: <SoundItem>[
            _sound('저는 한국어를 조금 해요.', '我會一點韓文。', SpeechTag.polite),
            _sound('저는 한국어를 잘 못해요.', '我韓文不太好。', SpeechTag.polite),
            _sound('잘 모르겠어요.', '我不太懂。／我不太清楚。', SpeechTag.polite),
            _sound('무슨 뜻이에요?', '是什麼意思？', SpeechTag.polite),
            _sound('아, 알겠어요.', '啊，我明白了。', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u9:can',
          title: '句型：할 수 있어요?（會…嗎？）',
          paragraphs: const <String>[
            '■ 一句話',
            '「할 수 있어요」＝會做、能做；語調上揚變成問句「할 수 있어요?」＝會…嗎？相反是「할 수 없어요」（不會、不能）。',
            '■ 怎麼接',
            '動詞語幹沒有收尾音時接 ㄹ 수 있어요：하다 → 語幹 하 → 할 수 있어요。',
            '語幹有收尾音時是 을 수 있어요，本單元還用不到。',
            '할、수、있어요 之間都要空格，不要寫成 할수있어요。',
            '■ 跟中文比',
            '字面上是「（做的）可能　有」：수 是「辦法、可能」，後面接單元 6 的 있어요。中文一個「會」或「能」，韓文要說完整串。',
            '問對方會不會說某種語言：영어 할 수 있어요?（你會說英文嗎？）這裡省略了 을／를（영어를）。',
          ],
          grammarRefs: const <String>['su_isseoyo'],
        ),
        LessonCard.sound(
          id: 'u9:ask',
          title: '練習・問對方',
          paragraphs: const <String>[
            '「한국어로」＝用韓文：單元 5 的 로／으로（用…），한국어 沒有收尾音，所以用 로。',
          ],
          items: <SoundItem>[
            _sound('영어 할 수 있어요?', '你會說英文嗎？', SpeechTag.polite),
            _sound('중국어 할 수 있어요?', '你會說中文嗎？', SpeechTag.polite),
            _sound('이거 한국어로 뭐예요?', '這個用韓文怎麼說？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u9:polite',
          title: '對陌生人：很禮貌又自然的說法',
          paragraphs: const <String>[
            '聽不懂時先道個歉再請對方幫忙，語氣會更客氣。需要時間想一想，就說「잠시만요」。',
            '「죄송합니다」「감사합니다」是固定的客氣話，和 해요體 的句子一起用很自然，整句的語氣仍算日常禮貌。',
          ],
          items: <SoundItem>[
            _sound('죄송합니다. 한국어를 잘 못해요.', '不好意思，我韓文不太好。', SpeechTag.polite),
            _sound('죄송합니다. 다시 말해 주세요.', '不好意思，請再說一次。', SpeechTag.polite),
            _sound('잠시만요.', '請等一下。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u9:dialog',
          title: '短對話：問路時聽不懂',
          paragraphs: const <String>[
            'A 是你，B 是路人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '실례합니다. 이 근처에 약국 있어요?', '不好意思，這附近有藥局嗎？', SpeechTag.polite),
            _line('B', '네, 저기 은행 옆에 있어요.', '有，在那邊銀行的旁邊。', SpeechTag.polite),
            _line('A', '죄송합니다. 천천히 말해 주세요.', '不好意思，請說慢一點。', SpeechTag.polite),
            _line('B', '은행 옆에 있어요.', '在銀行旁邊。', SpeechTag.polite),
            _line('A', '아, 알겠어요. 감사합니다.', '啊，我明白了。謝謝。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:한국어',
        'word:영어',
        'word:중국어',
        'word:조금',
        'word:천천히',
        'word:다시',
        'word:말하다',
        'word:쓰다#寫',
        'word:모르겠어요',
        'word:알겠어요',
        'word:잠시만요',
        'word:죄송합니다',
      ]),
    );

Lesson _unitFamily() => Lesson(
      id: 'unit-10',
      group: LessonGroup.unit,
      title: '單元 10・家人',
      summary: '問家裡有幾個人，說自己有哪些家人，介紹家人的職業。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u10:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會問和回答「家裡有幾個人？」，說自己有哥哥、姊姊或弟弟妹妹，並簡單介紹家人。',
            '做法：先認識家人的稱呼，再練「幾個人」「有誰」「家人是做什麼的」，最後聽一段聊家人的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u10:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '韓文的哥哥、姊姊要看「說話的人是男生還是女生」：男生叫哥哥「형」、姊姊「누나」；女生叫哥哥「오빠」、姊姊「언니」。',
          ],
          items: <SoundItem>[
            _sound('가족', '家人、家庭'),
            _sound('부모님', '父母'),
            _sound('아버지', '父親'),
            _sound('어머니', '母親'),
            _sound('형', '哥哥（男生說）'),
            _sound('누나', '姊姊（男生說）'),
            _sound('오빠', '哥哥（女生說）'),
            _sound('언니', '姊姊（女生說）'),
            _sound('남동생', '弟弟'),
            _sound('여동생', '妹妹'),
            _sound('형제', '兄弟姊妹'),
            _sound('명', '…個人（數人的量詞）'),
            _sound('결혼했어요', '結婚了（결혼하다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u10:pattern',
          title: '句型：가족이 몇 명이에요?',
          paragraphs: const <String>[
            '這個單元沒有很難的新文法，主要是把學過的句型用在家人身上。',
            '■ 가족이 몇 명이에요?：幾個人',
            '가족（家人）＋ 이 ＋ 몇（幾）＋ 명（…個人）＋ 이에요（是）＝家裡有幾個人？回答「네 명이에요」（四個人）。',
            '數人用固有數詞＋명。和單元 3 的 한 잔、두 잔 一樣，하나、둘、셋、넷 後面接量詞時會變短：한 명、두 명、세 명、네 명；다섯 명 不變。',
            '對長輩常聽到更客氣的「가족이 어떻게 되세요?」，先聽懂就好。',
            '■ 형이 있어요：有___',
            '單元 6 的 이／가 ＋ 單元 8 的 있어요（有）：___이／가 있어요；沒有就說 없어요。人數放在 있어요 前面：남동생이 한 명 있어요（我有一個弟弟）。',
            '■ 결혼했어요：結婚了',
            '單元 8 學過的過去式：결혼하다 → 결혼해요 → 결혼했어요。',
            '■ 介紹長輩',
            '談論自己的長輩時，韓國人常加尊敬說法（例如 회사원이세요）。本單元先用簡單的 이에요／예요。',
          ],
        ),
        LessonCard.sound(
          id: 'u10:drill1',
          title: '練習・家裡有幾個人',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('가족이 몇 명이에요?', '你家有幾個人？', SpeechTag.polite),
            _sound('세 명이에요.', '三個人。', SpeechTag.polite),
            _sound('네 명이에요.', '四個人。', SpeechTag.polite),
            _sound('다섯 명이에요.', '五個人。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u10:drill2',
          title: '練習・有哪些家人',
          paragraphs: const <String>[
            '「___이／가 있어요」＝有___；後面加「한 명」「두 명」說人數。',
          ],
          items: <SoundItem>[
            _sound('형이 있어요.', '我有哥哥。（男生說）', SpeechTag.polite),
            _sound('언니가 있어요.', '我有姊姊。（女生說）', SpeechTag.polite),
            _sound('남동생이 한 명 있어요.', '我有一個弟弟。', SpeechTag.polite),
            _sound('여동생이 두 명 있어요.', '我有兩個妹妹。', SpeechTag.polite),
            _sound('형제가 없어요.', '我沒有兄弟姊妹。', SpeechTag.polite),
            _sound('형제가 있어요?', '你有兄弟姊妹嗎？', SpeechTag.polite),
          ],
        ),
        LessonCard.concept(
          id: 'u10:my',
          title: '文法：제、우리（我的）',
          paragraphs: const <String>[
            '■ 의：…的',
            '의 接在名詞後面，表示「…的」，位置和中文的「的」一樣：친구의 가방（朋友的包包）。不受收尾音影響，一律寫 의。',
            '■ 제＝저의',
            '「我的」本來是 저의，口語幾乎都縮成 제：제 동생（我的弟弟／妹妹）、제 누나（我的姊姊）。單元 1 的 제 이름（我的名字）也是它。',
            '■ 우리：說自己的家人、家',
            '說自己的家人或家，韓國人常說 우리（我們），也不加 의：우리 아버지（我爸爸）、우리 가족（我的家人）。中文說「我爸爸」，韓文習慣說「我們（的）爸爸」。',
            '對長輩或正式場合會說得更謙虛（저희），之後再學。',
            '■ 發音',
            '의 當助詞時，標準發音也允許念成 [에]，口語很常聽到 [에]。',
          ],
          grammarRefs: const <String>['ui'],
        ),
        LessonCard.sound(
          id: 'u10:intro',
          title: '練習・介紹家人',
          paragraphs: const <String>[
            '職業的說法單元 1 學過。',
          ],
          items: <SoundItem>[
            _sound('우리 아버지는 회사원이에요.', '我爸爸是上班族。', SpeechTag.polite),
            _sound('우리 어머니는 선생님이에요.', '我媽媽是老師。', SpeechTag.polite),
            _sound('이 사람은 제 동생이에요.', '這是我弟弟（妹妹）。', SpeechTag.polite),
            _sound('제 누나는 결혼했어요.', '我姊姊結婚了。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u10:dialog',
          title: '短對話：聊家人',
          paragraphs: const <String>[
            'A、B 都是男生。對話裡的「형」是指 B 的哥哥。「무슨 일」＝什麼工作。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '가족이 몇 명이에요?', '你家有幾個人？', SpeechTag.polite),
            _line('B', '네 명이에요. 아버지, 어머니, 형, 그리고 저예요.', '四個人。爸爸、媽媽、哥哥，還有我。', SpeechTag.polite),
            _line('A', '형은 무슨 일을 해요?', '你哥哥是做什麼工作的？', SpeechTag.polite),
            _line('B', '형은 회사원이에요. 형제가 있어요?', '我哥哥是上班族。你有兄弟姊妹嗎？', SpeechTag.polite),
            _line('A', '네, 여동생이 한 명 있어요.', '有，我有一個妹妹。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:가족',
        'word:부모님',
        'word:아버지',
        'word:어머니',
        'word:형',
        'word:누나',
        'word:오빠',
        'word:언니',
        'word:남동생',
        'word:여동생',
        'word:형제',
        'word:명',
        'word:결혼하다',
      ]),
    );

Lesson _unitLikes() => Lesson(
      id: 'unit-11',
      group: LessonGroup.unit,
      title: '單元 11・喜歡與不喜歡',
      summary: '說自己喜歡什麼、不太喜歡什麼，問對方的興趣。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u11:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會聊興趣：「취미가 뭐예요?」「저는 등산을 좋아해요.」，以及委婉地說不太喜歡。',
            '做法：先認識興趣的詞，再把同一個句型換上不同的東西反覆練，最後聽一段聊興趣的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u11:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('취미', '興趣、嗜好'),
            _sound('운동', '運動'),
            _sound('축구', '足球'),
            _sound('음악', '音樂'),
            _sound('영화', '電影'),
            _sound('드라마', '連續劇'),
            _sound('노래', '歌'),
            _sound('등산', '爬山'),
            _sound('산책', '散步'),
            _sound('여행', '旅行'),
            _sound('좋아해요', '喜歡（좋아하다）'),
            _sound('싫어해요', '討厭（싫어하다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u11:pattern',
          title: '句型：___을／를 좋아해요',
          paragraphs: const <String>[
            '「___을／를 좋아해요」＝喜歡___。有收尾音用「을」（음악을），沒有用「를」（영화를）。',
            '問對方：「취미가 뭐예요?」（你的興趣是什麼？）、「영화 좋아해요?」（你喜歡電影嗎？口語常省略 를）。',
            '「싫어해요」（討厭）說起來很直接，跟不熟的人說「별로 안 좋아해요」（不太喜歡）比較委婉。「별로」當「不怎麼…」用時，後面幾乎都接否定；口語也常單獨說「별로예요」，意思是「不怎麼樣」。',
          ],
        ),
        _grammarCard('an'),
        LessonCard.sound(
          id: 'u11:drill1',
          title: '練習・我喜歡…',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('저는 음악을 좋아해요.', '我喜歡音樂。', SpeechTag.polite),
            _sound('저는 영화를 좋아해요.', '我喜歡電影。', SpeechTag.polite),
            _sound('저는 축구를 좋아해요.', '我喜歡足球。', SpeechTag.polite),
            _sound('저는 등산을 좋아해요.', '我喜歡爬山。', SpeechTag.polite),
            _sound('저는 한국 드라마를 좋아해요.', '我喜歡韓劇。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u11:drill2',
          title: '練習・不太喜歡',
          paragraphs: const <String>[
            '「안」放在動詞前面表示「不」。加上「별로」語氣更委婉。注意「名詞＋하다」的動詞要說「운동 안 해요」，不說「안 운동해요」。',
          ],
          items: <SoundItem>[
            _sound('운동을 안 좋아해요.', '我不喜歡運動。', SpeechTag.polite),
            _sound('노래를 별로 안 좋아해요.', '我不太喜歡聽歌。', SpeechTag.polite),
            _sound('커피를 별로 안 좋아해요.', '我不太喜歡咖啡。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u11:ask',
          title: '練習・問與答',
          paragraphs: const <String>[
            '「어떤」＝什麼樣的。',
          ],
          items: <SoundItem>[
            _sound('취미가 뭐예요?', '你的興趣是什麼？', SpeechTag.polite),
            _sound('영화 좋아해요?', '你喜歡電影嗎？', SpeechTag.polite),
            _sound('어떤 음악을 좋아해요?', '你喜歡什麼樣的音樂？', SpeechTag.polite),
            _sound('제 취미는 여행이에요.', '我的興趣是旅行。', SpeechTag.polite),
            _sound('제 취미는 산책이에요.', '我的興趣是散步。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u11:dialog',
          title: '短對話：聊興趣',
          paragraphs: const <String>[
            '先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '취미가 뭐예요?', '你的興趣是什麼？', SpeechTag.polite),
            _line('B', '저는 등산을 좋아해요.', '我喜歡爬山。', SpeechTag.polite),
            _line('A', '아, 저도 등산을 좋아해요.', '啊，我也喜歡爬山。', SpeechTag.polite),
            _line('B', '축구도 좋아해요?', '你也喜歡足球嗎？', SpeechTag.polite),
            _line('A', '아니요, 축구는 별로 안 좋아해요.', '不，我不太喜歡足球。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:취미',
        'word:운동',
        'word:축구',
        'word:음악',
        'word:영화',
        'word:드라마',
        'word:노래',
        'word:등산',
        'word:산책',
        'word:여행',
        'word:좋아하다',
        'word:싫어하다',
        'word:어떤',
      ]),
    );

Lesson _unitDaily() => Lesson(
      id: 'unit-12',
      group: LessonGroup.unit,
      title: '單元 12・每天做什麼',
      summary: '說自己每天的作息，問對方現在在做什麼，用 -고 把兩件事連起來。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u12:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說一天的作息（幾點起床、幾點睡覺），回答「지금 뭐 하고 있어요?」（你現在在做什麼？）。',
            '做法：先認識常用動詞，再練作息、正在做的事、把兩件事連起來，最後聽一段對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u12:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '動詞先學 해요體 的樣子，括號裡是原形（辭典形）。',
          ],
          items: <SoundItem>[
            _sound('일어나요', '起床（일어나다）'),
            _sound('먹어요', '吃（먹다）'),
            _sound('마셔요', '喝（마시다）'),
            _sound('공부해요', '讀書（공부하다）'),
            _sound('일해요', '工作（일하다）'),
            _sound('쉬어요', '休息（쉬다）'),
            _sound('자요', '睡覺（자다）'),
            _sound('기다려요', '等（기다리다）'),
            _sound('매일', '每天'),
            _sound('보통', '通常'),
            _sound('회사', '公司'),
            _sound('밥', '飯'),
          ],
        ),
        LessonCard.concept(
          id: 'u12:pattern',
          title: '句型：몇 시에 ___아요／어요?',
          paragraphs: const <String>[
            '時間後面加「에」：일곱 시에 일어나요（七點起床）。幾點的說法單元 4 學過。',
            '「-고 있어요」＝正在…：밥을 먹고 있어요（正在吃飯）。',
            '「-고」＝…然後…，把兩件事連起來：아침을 먹고 회사에 가요（吃完早餐然後去公司）。',
            '注意：「先去某個地方，再在那裡做事」不用 -고，要用 -아서／어서（회사에 가서 일해요），單元 17 的 -아서／어서 文法卡會說明（它也有「…之後」的用法）。',
          ],
        ),
        _grammarCard('go_isseoyo'),
        _grammarCard('go'),
        _grammarCard('go_sipeoyo'),
        _grammarCard('buteo_kkaji'),
        LessonCard.sound(
          id: 'u12:drill1',
          title: '練習・一天的作息',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('저는 매일 일곱 시에 일어나요.', '我每天七點起床。', SpeechTag.polite),
            _sound('아침에 커피를 마셔요.', '早上喝咖啡。', SpeechTag.polite),
            _sound('아홉 시부터 여섯 시까지 일해요.', '從九點工作到六點。', SpeechTag.polite),
            _sound('저녁에 집에서 쉬어요.', '晚上在家休息。', SpeechTag.polite),
            _sound('보통 열두 시에 자요.', '通常十二點睡覺。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u12:drill2',
          title: '練習・現在正在做什麼',
          paragraphs: const <String>[
            '動詞語幹＋고 있어요。',
          ],
          items: <SoundItem>[
            _sound('지금 뭐 하고 있어요?', '你現在在做什麼？', SpeechTag.polite),
            _sound('지금 밥을 먹고 있어요.', '我現在正在吃飯。', SpeechTag.polite),
            _sound('한국어를 공부하고 있어요.', '我正在讀韓文。', SpeechTag.polite),
            _sound('친구를 기다리고 있어요.', '我正在等朋友。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u12:drill3',
          title: '練習・用 -고 連起來',
          paragraphs: const <String>[
            '前一件事＋고＋後一件事。',
          ],
          items: <SoundItem>[
            _sound('아침을 먹고 회사에 가요.', '吃完早餐去公司。', SpeechTag.polite),
            _sound('저녁을 먹고 드라마를 봐요.', '吃完晚餐看連續劇。', SpeechTag.polite),
            _sound('회사에서 일하고 집에 가요.', '在公司工作完回家。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u12:dialog',
          title: '短對話：你現在在做什麼？',
          paragraphs: const <String>[
            '先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '지금 뭐 하고 있어요?', '你現在在做什麼？', SpeechTag.polite),
            _line('B', '한국어를 공부하고 있어요.', '我正在讀韓文。', SpeechTag.polite),
            _line('A', '매일 공부해요?', '你每天都讀嗎？', SpeechTag.polite),
            _line('B', '네, 보통 저녁을 먹고 공부해요.', '對，我通常吃完晚餐讀書。', SpeechTag.polite),
            _line('A', '저도 한국어를 공부하고 싶어요.', '我也想學韓文。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:일어나다',
        'word:먹다',
        'word:마시다',
        'word:공부하다',
        'word:일하다',
        'word:쉬다',
        'word:자다',
        'word:기다리다',
        'word:매일',
        'word:보통',
        'word:회사',
        'word:밥',
      ]),
    );

Lesson _unitPurpose() => Lesson(
      id: 'unit-13',
      group: LessonGroup.unit,
      title: '單元 13・去哪裡做什麼',
      summary: '用「___(으)러 가요」說去某個地方做什麼，以及在某個地方做什麼。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u13:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說「去哪裡做什麼」：영화를 보러 영화관에 가요（去電影院看電影）。',
            '做法：先認識地點，再練「去哪裡」「去做什麼」「在哪裡做什麼」，最後聽一段在路上遇到朋友的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u13:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('도서관', '圖書館'),
            _sound('공원', '公園'),
            _sound('영화관', '電影院'),
            _sound('체육관', '體育館'),
            _sound('시장', '市場'),
            _sound('백화점', '百貨公司'),
            _sound('우체국', '郵局'),
            _sound('빵집', '麵包店'),
            _sound('책', '書'),
            _sound('편지', '信'),
            _sound('사요', '買（사다）'),
            _sound('읽어요', '讀、看（書）（읽다）'),
            _sound('보내요', '寄、送（보내다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u13:pattern',
          title: '句型：___(으)러 가요',
          paragraphs: const <String>[
            '「動詞語幹＋(으)러 가요」＝去做…。語幹沒有收尾音或收尾音是 ㄹ 用「러」（보러、사러），其他收尾音用「으러」（먹으러、읽으러）。',
            '完整的句子：做什麼＋(으)러＋地點＋에 가요。例：책을 읽으러 도서관에 가요。地點放前面也很自然：도서관에 책을 읽으러 가요。',
            '-(으)러 後面只能接「移動」的動詞，例如 가요、와요。有少數不規則的動詞（例如 듣다 → 들으러）之後再學。',
            '在某個地方做事用「에서」（單元 7 學過）：백화점에서 옷을 사요（在百貨公司買衣服）。',
          ],
        ),
        _grammarCard('eu_reo'),
        LessonCard.sound(
          id: 'u13:drill1',
          title: '練習・去哪裡',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('어디에 가요?', '你要去哪裡？', SpeechTag.polite),
            _sound('도서관에 가요.', '我去圖書館。', SpeechTag.polite),
            _sound('시장에 가요.', '我去市場。', SpeechTag.polite),
            _sound('공원에 가요.', '我去公園。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u13:drill2',
          title: '練習・去做什麼',
          paragraphs: const <String>[
            '做什麼＋(으)러＋地點＋에 가요。',
          ],
          items: <SoundItem>[
            _sound('책을 읽으러 도서관에 가요.', '我去圖書館看書。', SpeechTag.polite),
            _sound('영화를 보러 영화관에 가요.', '我去電影院看電影。', SpeechTag.polite),
            _sound('운동하러 체육관에 가요.', '我去體育館運動。', SpeechTag.polite),
            _sound('빵을 사러 빵집에 가요.', '我去麵包店買麵包。', SpeechTag.polite),
            _sound('산책하러 공원에 가요.', '我去公園散步。', SpeechTag.polite),
            _sound('밥을 먹으러 식당에 가요.', '我去餐廳吃飯。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u13:drill3',
          title: '練習・在哪裡做什麼',
          paragraphs: const <String>[
            '地點＋에서＋做的事。',
          ],
          items: <SoundItem>[
            _sound('우체국에서 편지를 보내요.', '在郵局寄信。', SpeechTag.polite),
            _sound('백화점에서 옷을 사요.', '在百貨公司買衣服。', SpeechTag.polite),
            _sound('도서관에서 공부해요.', '在圖書館讀書。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u13:dialog',
          title: '短對話：在路上遇到朋友',
          paragraphs: const <String>[
            'A 是민수（民秀）。「씨」接在名字後面，是對人的客氣稱呼。口語常把「어디에 가요?」說成「어디 가요?」。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '어디에 가요?', '你要去哪裡？', SpeechTag.polite),
            _line('B', '시장에 가요.', '我去市場。', SpeechTag.polite),
            _line('A', '뭐 사러 가요?', '你要去買什麼？', SpeechTag.polite),
            _line('B', '과일을 사러 가요. 민수 씨는 어디 가요?', '我去買水果。民秀你要去哪裡？', SpeechTag.polite),
            _line('A', '저는 운동하러 체육관에 가요.', '我要去體育館運動。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:도서관',
        'word:공원',
        'word:영화관',
        'word:체육관',
        'word:시장',
        'word:백화점',
        'word:우체국',
        'word:빵집',
        'word:책',
        'word:편지',
        'word:사다',
        'word:읽다',
        'word:보내다',
      ]),
    );

Lesson _unitYesterday() => Lesson(
      id: 'unit-14',
      group: LessonGroup.unit,
      title: '單元 14・昨天做了什麼',
      summary: '用過去式說昨天、週末做了什麼，說事情的先後，以及給了誰什麼。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u14:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會回答「어제 뭐 했어요?」（昨天做了什麼？）、「주말에 뭐 했어요?」（週末做了什麼？）。',
            '過去式「-았／었어요」單元 8 學過（예약했어요）。這個單元練更多動詞，並學「…之前」「…之後」和「給某人」。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u14:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '動詞先學過去式的樣子，括號裡是原形。',
          ],
          items: <SoundItem>[
            _sound('어제', '昨天'),
            _sound('지난주', '上週'),
            _sound('주말', '週末'),
            _sound('작년', '去年'),
            _sound('친구', '朋友'),
            _sound('선물', '禮物'),
            _sound('만났어요', '見了面（만나다）'),
            _sound('봤어요', '看了（보다）'),
            _sound('줬어요', '給了（주다）'),
            _sound('전화했어요', '打了電話（전화하다）'),
            _sound('끝났어요', '結束了（끝나다）'),
            _sound('재미있었어요', '很有趣（재미있다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u14:pattern',
          title: '句型：어제 뭐 했어요?',
          paragraphs: const <String>[
            '過去式：看語幹最後一個音節的母音。是 ㅏ、ㅗ 加「았어요」，其他加「었어요」（먹었어요、기다렸어요），하다 變成「했어요」。',
            '有些會縮短：만나＋았어요 → 만났어요、보＋았어요 → 봤어요、주＋었어요 → 줬어요。',
            '「-기 전에」＝…之前：자기 전에（睡覺之前）。「-(으)ㄴ 후에」＝…之後：먹은 후에（吃完之後）。',
            '「한테」＝給（某人）、對（某人），口語常用：친구한테 선물을 줬어요。',
          ],
        ),
        _grammarCard('jeon_hu'),
        _grammarCard('ege_hante'),
        LessonCard.sound(
          id: 'u14:drill1',
          title: '練習・做了什麼',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('어제 뭐 했어요?', '你昨天做了什麼？', SpeechTag.polite),
            _sound('친구를 만났어요.', '我和朋友見面了。', SpeechTag.polite),
            _sound('영화를 봤어요.', '我看了電影。', SpeechTag.polite),
            _sound('집에서 쉬었어요.', '我在家休息。', SpeechTag.polite),
            _sound('지난주에 부산에 갔어요.', '我上週去了釜山。', SpeechTag.polite),
            _sound('작년에 한국에 갔어요.', '我去年去了韓國。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u14:drill2',
          title: '練習・之前、之後',
          paragraphs: const <String>[
            '語幹＋기 전에；語幹＋(으)ㄴ 후에。',
          ],
          items: <SoundItem>[
            _sound('밥을 먹은 후에 산책했어요.', '吃完飯之後去散步了。', SpeechTag.polite),
            _sound('자기 전에 책을 읽었어요.', '睡覺之前看了書。', SpeechTag.polite),
            _sound('수업이 끝난 후에 친구를 만났어요.', '下課之後和朋友見面了。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u14:drill3',
          title: '練習・給誰',
          paragraphs: const <String>[
            '人＋한테＋東西＋을／를＋動詞。',
          ],
          items: <SoundItem>[
            _sound('친구한테 선물을 줬어요.', '我送了朋友禮物。', SpeechTag.polite),
            _sound('어머니한테 전화했어요.', '我打了電話給媽媽。', SpeechTag.polite),
            _sound('동생한테 편지를 보냈어요.', '我寄了信給弟弟（妹妹）。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u14:dialog',
          title: '短對話：週末做了什麼？',
          paragraphs: const <String>[
            '先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '주말에 뭐 했어요?', '你週末做了什麼？', SpeechTag.polite),
            _line('B', '친구하고 영화를 봤어요.', '我和朋友看了電影。', SpeechTag.polite),
            _line('A', '영화가 재미있었어요?', '電影好看嗎？', SpeechTag.polite),
            _line('B', '네, 정말 재미있었어요. 영화를 본 후에 같이 밥을 먹었어요.', '嗯，真的很好看。看完電影之後一起吃了飯。', SpeechTag.polite),
            _line('A', '저는 집에서 쉬었어요.', '我在家休息。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:어제',
        'word:지난주',
        'word:주말',
        'word:작년',
        'word:친구',
        'word:선물',
        'word:만나다',
        'word:보다',
        'word:주다',
        'word:전화하다',
        'word:끝나다',
        'word:재미있다',
      ]),
    );

Lesson _unitPlans() => Lesson(
      id: 'unit-15',
      group: LessonGroup.unit,
      title: '單元 15・週末計畫',
      summary: '用「-(으)ㄹ 거예요」說週末、放假要做什麼，問對方的計畫。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u15:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說之後要做的事：「주말에 뭐 할 거예요?」「바다에 갈 거예요.」',
            '做法：先認識時間和地點的詞，再把同一個句型換上不同的計畫反覆練，最後聽一段聊週末的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u15:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('내일', '明天'),
            _sound('모레', '後天'),
            _sound('이번 주', '這週'),
            _sound('다음 주', '下週'),
            _sound('방학', '放假（寒暑假）'),
            _sound('휴가', '休假'),
            _sound('바다', '海'),
            _sound('산', '山'),
            _sound('캠핑', '露營'),
            _sound('제주도', '濟州島'),
            _sound('시간', '時間'),
            _sound('언제', '什麼時候'),
            _sound('여행할 거예요', '要去旅行（여행하다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u15:pattern',
          title: '句型：___(으)ㄹ 거예요',
          paragraphs: const <String>[
            '「動詞語幹＋(으)ㄹ 거예요」＝要…、打算…。語幹沒有收尾音加「ㄹ 거예요」（갈 거예요、볼 거예요），有收尾音加「을 거예요」（먹을 거예요）。',
            '語幹收尾是 ㄹ 時直接加「거예요」：놀다 → 놀 거예요。',
            '問對方：「주말에 뭐 할 거예요?」（週末要做什麼？）、「언제 갈 거예요?」（什麼時候去？）。',
            '「-(으)ㄹ 거예요」說別人或天氣時也可以表示推測（例如 비가 올 거예요＝應該會下雨），之後再學。',
          ],
        ),
        _grammarCard('eul_geoyeyo'),
        LessonCard.sound(
          id: 'u15:drill1',
          title: '練習・要做什麼',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('주말에 뭐 할 거예요?', '你週末要做什麼？', SpeechTag.polite),
            _sound('친구를 만날 거예요.', '我要和朋友見面。', SpeechTag.polite),
            _sound('집에서 쉴 거예요.', '我要在家休息。', SpeechTag.polite),
            _sound('내일 영화를 볼 거예요.', '我明天要看電影。', SpeechTag.polite),
            _sound('저녁에 친구하고 놀 거예요.', '我晚上要和朋友玩。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u15:drill2',
          title: '練習・去哪裡',
          paragraphs: const <String>[
            '地點＋에 갈 거예요。活動名稱則用 을／를：캠핑을 가다、여행을 가다。',
          ],
          items: <SoundItem>[
            _sound('이번 주말에 바다에 갈 거예요.', '這週末我要去海邊。', SpeechTag.polite),
            _sound('다음 주에 제주도에 갈 거예요.', '我下週要去濟州島。', SpeechTag.polite),
            _sound('방학에 한국에 갈 거예요.', '放假時我要去韓國。', SpeechTag.polite),
            _sound('모레 산에 갈 거예요.', '後天我要去山上。', SpeechTag.polite),
            _sound('휴가에 캠핑을 갈 거예요.', '休假時我要去露營。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u15:ask',
          title: '練習・問對方的計畫',
          paragraphs: const <String>[
            '「시간 있어요?」＝有空嗎？',
          ],
          items: <SoundItem>[
            _sound('이번 주말에 시간 있어요?', '這週末有空嗎？', SpeechTag.polite),
            _sound('내일 뭐 할 거예요?', '你明天要做什麼？', SpeechTag.polite),
            _sound('언제 갈 거예요?', '你什麼時候要去？', SpeechTag.polite),
            _sound('누구하고 여행할 거예요?', '你要和誰去旅行？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u15:dialog',
          title: '短對話：週末要做什麼？',
          paragraphs: const <String>[
            '「어느」＝哪個；「그래요?」＝是喔？（聽到對方的話時的回應）。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '이번 주말에 뭐 할 거예요?', '這週末你要做什麼？', SpeechTag.polite),
            _line('B', '친구하고 바다에 갈 거예요.', '我要和朋友去海邊。', SpeechTag.polite),
            _line('A', '어느 바다에 갈 거예요?', '要去哪個海邊？', SpeechTag.polite),
            _line('B', '부산에 갈 거예요. 부산 바다가 정말 예뻐요.', '要去釜山。釜山的海真的很漂亮。', SpeechTag.polite),
            _line('A', '그래요? 저는 집에서 쉴 거예요.', '是喔？我要在家休息。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:내일',
        'word:모레',
        'word:이번 주',
        'word:다음 주',
        'word:방학',
        'word:휴가',
        'word:바다',
        'word:산',
        'word:캠핑',
        'word:제주도',
        'word:시간',
        'word:언제',
        'word:여행하다',
      ]),
    );

Lesson _unitAppointment() => Lesson(
      id: 'unit-16',
      group: LessonGroup.unit,
      title: '單元 16・約時間',
      summary: '用「-(으)ㄹ까요?」約對方一起做事，決定時間地點，有禮貌地拒絕。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u16:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會約人：「같이 영화 볼까요?」（要不要一起看電影？），決定「몇 시에」「어디에서」見面，以及有禮貌地說沒空。',
            '做法：先認識星期和約會的詞，再練邀約、回答、定時間地點，最後聽一段約看電影的對話。',
            '「-(으)ㅂ시다」（一起…吧）對長輩或不熟的人不夠禮貌，所以這裡只學「-(으)ㄹ까요?」，也可以直接用 해요體 說「같이 가요」。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u16:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('같이', '一起'),
            _sound('금요일', '星期五'),
            _sound('토요일', '星期六'),
            _sound('일요일', '星期日'),
            _sound('좋아요', '好啊（좋다）'),
            _sound('미안해요', '對不起、不好意思'),
            _sound('왜요', '怎麼了？為什麼？'),
            _sound('앞', '前面'),
            _sound('전화번호', '電話號碼'),
            _sound('약속', '約、約定（약속하다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u16:pattern',
          title: '句型：같이 ___(으)ㄹ까요?',
          paragraphs: const <String>[
            '「動詞語幹＋(으)ㄹ까요?」＝要不要…？、…好嗎？語幹沒有收尾音加「ㄹ까요」（볼까요、갈까요），有收尾音加「을까요」（먹을까요）。語幹收尾是 ㄹ 時直接加「까요」：놀다 → 놀까요。',
            '定時間地點：「몇 시에 만날까요?」（幾點見？）、「어디에서 만날까요?」（在哪裡見？）。',
            '回答：答應說「좋아요」；沒空時說「미안해요. ___에 약속이 있어요」（不好意思，___有約了），再提別的時間。',
          ],
        ),
        _grammarCard('eul_kkayo'),
        LessonCard.sound(
          id: 'u16:drill1',
          title: '練習・邀約',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('같이 영화 볼까요?', '要不要一起看電影？', SpeechTag.polite),
            _sound('같이 밥 먹을까요?', '要不要一起吃飯？', SpeechTag.polite),
            _sound('같이 커피 마실까요?', '要不要一起喝咖啡？', SpeechTag.polite),
            _sound('토요일에 만날까요?', '星期六見面好嗎？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u16:drill2',
          title: '練習・回答',
          paragraphs: const <String>[
            '拒絕時先說「미안해요」，再說原因或提別的時間。對長輩或不熟的人說「죄송해요」更有禮貌。',
          ],
          items: <SoundItem>[
            _sound('좋아요.', '好啊。', SpeechTag.polite),
            _sound('미안해요. 토요일에 약속이 있어요.', '不好意思，我星期六有約了。', SpeechTag.polite),
            _sound('일요일은 어때요?', '星期日怎麼樣？', SpeechTag.polite),
            _sound('금요일 저녁은 괜찮아요.', '星期五晚上可以。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u16:drill3',
          title: '練習・決定時間和地點',
          paragraphs: const <String>[
            '決定好之後，用 해요體 說「___에서 만나요」（在___見）就可以了。',
          ],
          items: <SoundItem>[
            _sound('몇 시에 만날까요?', '我們幾點見？', SpeechTag.polite),
            _sound('어디에서 만날까요?', '我們在哪裡見？', SpeechTag.polite),
            _sound('세 시에 만나요.', '三點見。', SpeechTag.polite),
            _sound('역 앞에서 만나요.', '在車站前面見。', SpeechTag.polite),
            _sound('전화번호가 뭐예요?', '你的電話號碼是多少？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u16:dialog',
          title: '短對話：約看電影',
          paragraphs: const <String>[
            '先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '토요일에 시간 있어요?', '你星期六有空嗎？', SpeechTag.polite),
            _line('B', '네, 있어요. 왜요?', '有啊。怎麼了？', SpeechTag.polite),
            _line('A', '같이 영화 볼까요?', '要不要一起看電影？', SpeechTag.polite),
            _line('B', '좋아요. 몇 시에 만날까요?', '好啊。我們幾點見？', SpeechTag.polite),
            _line('A', '두 시에 영화관 앞에서 만나요.', '兩點在電影院前面見。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:같이',
        'word:금요일',
        'word:토요일',
        'word:일요일',
        'word:좋다',
        'word:미안해요',
        'word:왜',
        'word:앞',
        'word:전화번호',
        'word:영화관',
      ]),
    );

Lesson _unitWeather() => Lesson(
      id: 'unit-17',
      group: LessonGroup.unit,
      title: '單元 17・天氣與季節',
      summary: '說今天的天氣和季節，用 -아서／어서 說原因，用 -(으)면 說「如果…」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u17:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會聊天氣：「날씨가 어때요?」「오늘은 추워요.」，這是跟陌生人閒聊最常見的話題。',
            '做法：先認識天氣和季節的詞，再練天氣、季節、原因與「如果」，最後聽一段下雨天的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u17:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '形容詞先學 해요體 的樣子，括號裡是原形。',
          ],
          items: <SoundItem>[
            _sound('날씨', '天氣'),
            _sound('봄', '春天'),
            _sound('여름', '夏天'),
            _sound('가을', '秋天'),
            _sound('겨울', '冬天'),
            _sound('더워요', '熱（덥다）'),
            _sound('추워요', '冷（춥다）'),
            _sound('따뜻해요', '溫暖（따뜻하다）'),
            _sound('시원해요', '涼爽（시원하다）'),
            _sound('비', '雨'),
            _sound('눈', '雪（也有「眼睛」的意思）'),
            _sound('바람', '風'),
          ],
        ),
        LessonCard.concept(
          id: 'u17:pattern',
          title: '句型：날씨가 어때요?',
          paragraphs: const <String>[
            '「날씨가 어때요?」＝天氣怎麼樣？「어때요」是「怎麼樣」，先整句記住。',
            '덥다、춥다 的 ㅂ 會變成 우：덥다 → 더워요、춥다 → 추워요（ㅂ 不規則）。不是所有 ㅂ 收尾都這樣變，例如 입다 → 입어요。',
            '下雨、下雪用「오다」（來）：비가 와요、눈이 와요。颳風用「불다」：바람이 불어요。',
            '「-아서／어서」＝因為…所以…：추워서 코트를 입었어요。前面不加過去式（說 추워서，不說 추웠어서），後面也不接請求或邀約；要請對方做事時用單元 18 的 -(으)니까。',
            '「-(으)면」＝如果…：비가 오면 집에 있어요。',
          ],
        ),
        _grammarCard('a_eoseo'),
        _grammarCard('eu_myeon'),
        LessonCard.sound(
          id: 'u17:drill1',
          title: '練習・今天的天氣',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('날씨가 어때요?', '天氣怎麼樣？', SpeechTag.polite),
            _sound('오늘은 더워요.', '今天很熱。', SpeechTag.polite),
            _sound('오늘은 추워요.', '今天很冷。', SpeechTag.polite),
            _sound('날씨가 좋아요.', '天氣很好。', SpeechTag.polite),
            _sound('비가 와요.', '在下雨。', SpeechTag.polite),
            _sound('눈이 와요.', '在下雪。', SpeechTag.polite),
            _sound('바람이 많이 불어요.', '風很大。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u17:drill2',
          title: '練習・季節',
          paragraphs: const <String>[
            '季節＋에는＝在…的時候（에＋는）。',
          ],
          items: <SoundItem>[
            _sound('봄에는 따뜻해요.', '春天很溫暖。', SpeechTag.polite),
            _sound('여름에는 더워요.', '夏天很熱。', SpeechTag.polite),
            _sound('가을에는 시원해요.', '秋天很涼爽。', SpeechTag.polite),
            _sound('겨울에는 추워요.', '冬天很冷。', SpeechTag.polite),
            _sound('저는 가을을 좋아해요.', '我喜歡秋天。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u17:drill3',
          title: '練習・原因與如果',
          paragraphs: const <String>[
            '原因＋아서／어서＋結果；如果＋(으)면＋做什麼。',
          ],
          items: <SoundItem>[
            _sound('추워서 코트를 입었어요.', '因為冷，所以穿了大衣。', SpeechTag.polite),
            _sound('더워서 아이스크림을 먹었어요.', '因為熱，所以吃了冰淇淋。', SpeechTag.polite),
            _sound('비가 오면 집에 있어요.', '如果下雨，我就待在家。', SpeechTag.polite),
            _sound('날씨가 좋으면 산책해요.', '如果天氣好，我就去散步。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u17:dialog',
          title: '短對話：下雨天',
          paragraphs: const <String>[
            '先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。「그럼」是「그러면」（那麼）的口語。',
          ],
          items: <SoundItem>[
            _line('A', '오늘 날씨가 어때요?', '今天天氣怎麼樣？', SpeechTag.polite),
            _line('B', '비가 많이 와요. 우산 있어요?', '雨下得很大。你有雨傘嗎？', SpeechTag.polite),
            _line('A', '아니요, 없어요.', '沒有。', SpeechTag.polite),
            _line('B', '그럼 제 우산을 같이 써요.', '那我們一起撐我的傘吧。', SpeechTag.polite),
            _line('A', '고마워요.', '謝謝。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:날씨',
        'word:봄',
        'word:여름',
        'word:가을',
        'word:겨울',
        'word:덥다',
        'word:춥다',
        'word:따뜻하다',
        'word:시원하다',
        'word:비#雨',
        'word:눈#雪',
        'word:바람',
      ]),
    );

Lesson _unitSick() => Lesson(
      id: 'unit-18',
      group: LessonGroup.unit,
      title: '單元 18・身體不舒服',
      summary: '說哪裡痛、有什麼症狀，在藥局買藥，用 -아／어야 해요 說「必須…」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u18:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會在藥局或醫院說明狀況：「머리가 아파요.」「열이 있어요.」',
            '做法：先認識身體和症狀的詞，再練說症狀、說「必須…」、在藥局買藥，最後聽一段藥局的對話。',
            '藥師或醫生常用尊敬說法問你（例如「어디가 아프세요?」），先聽得懂就好。',
            '這個單元只是語言練習，不是醫療建議；真的不舒服請找醫生或藥師。',
          ],
        ),
        LessonCard.sound(
          id: 'u18:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '「배」也有「梨子」「船」的意思，「목」包含脖子和喉嚨，「열」也可以是數字十，要看前後文。',
          ],
          items: <SoundItem>[
            _sound('아파요', '痛、不舒服（아프다）'),
            _sound('머리', '頭'),
            _sound('배', '肚子'),
            _sound('목', '喉嚨、脖子'),
            _sound('열', '發燒、熱度'),
            _sound('감기', '感冒'),
            _sound('기침', '咳嗽'),
            _sound('두통', '頭痛'),
            _sound('약', '藥'),
            _sound('병원', '醫院'),
            _sound('일찍', '早、提早'),
          ],
        ),
        LessonCard.concept(
          id: 'u18:pattern',
          title: '句型：___이／가 아파요',
          paragraphs: const <String>[
            '「身體部位＋이／가 아파요」＝___痛：머리가 아파요（頭痛）、배가 아파요（肚子痛）。',
            '「열이 있어요」＝發燒；「기침을 해요」＝咳嗽；「감기에 걸렸어요」＝感冒了（先整句記住）。',
            '「-아／어야 해요」＝必須…：병원에 가야 해요（必須去醫院）。',
            '「-(으)니까」＝因為…（後面常接建議或請求）：열이 있으니까 병원에 가세요。',
          ],
        ),
        _grammarCard('a_eoya_haeyo'),
        _grammarCard('eu_nikka'),
        LessonCard.sound(
          id: 'u18:drill1',
          title: '練習・說症狀',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('머리가 아파요.', '我頭痛。', SpeechTag.polite),
            _sound('배가 아파요.', '我肚子痛。', SpeechTag.polite),
            _sound('목이 아파요.', '我喉嚨痛。', SpeechTag.polite),
            _sound('열이 있어요.', '我發燒了。', SpeechTag.polite),
            _sound('기침을 해요.', '我在咳嗽。', SpeechTag.polite),
            _sound('감기에 걸렸어요.', '我感冒了。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u18:drill2',
          title: '練習・必須…',
          paragraphs: const <String>[
            '語幹＋아／어야 해요。',
          ],
          items: <SoundItem>[
            _sound('병원에 가야 해요.', '我必須去醫院。', SpeechTag.polite),
            _sound('약을 먹어야 해요.', '我必須吃藥。', SpeechTag.polite),
            _sound('오늘은 집에서 쉬어야 해요.', '我今天必須在家休息。', SpeechTag.polite),
            _sound('아프니까 오늘은 일찍 자야 해요.', '因為不舒服，今天得早點睡。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u18:pharmacy',
          title: '練習・在藥局',
          paragraphs: const <String>[
            '「감기약」＝感冒藥、「두통약」＝頭痛藥（症狀＋약）。「하루에 세 번」＝一天三次。',
          ],
          items: <SoundItem>[
            _sound('감기약 있어요?', '有感冒藥嗎？', SpeechTag.polite),
            _sound('두통약 주세요.', '請給我頭痛藥。', SpeechTag.polite),
            _sound('하루에 몇 번 먹어요?', '一天吃幾次？', SpeechTag.polite),
            _sound('하루에 세 번 먹어요.', '一天吃三次。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u18:dialog',
          title: '短對話：在藥局',
          paragraphs: const <String>[
            'A 是藥師，B 是客人。藥師說的「드세요」是「먹으세요」（請吃）的尊敬說法，藥師、醫生很常這樣說，先聽得懂就好。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '어디가 아프세요?', '您哪裡不舒服？', SpeechTag.honorific),
            _line('B', '머리가 아프고 열이 있어요.', '我頭痛，還有發燒。', SpeechTag.polite),
            _line('A', '감기약 여기 있어요. 하루에 세 번 드세요.', '感冒藥在這裡。一天吃三次。', SpeechTag.honorific),
            _line('B', '얼마예요?', '多少錢？', SpeechTag.polite),
            _line('A', '오천 원이에요. 열이 있으니까 오늘은 쉬세요.', '五千韓元。您在發燒，今天請好好休息。', SpeechTag.honorific),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:아프다',
        'word:머리',
        'word:배#腹',
        'word:목',
        'word:열#熱',
        'word:감기',
        'word:기침',
        'word:두통',
        'word:약',
        'word:병원',
      ]),
    );

Lesson _unitPermission() => Lesson(
      id: 'unit-19',
      group: LessonGroup.unit,
      title: '單元 19・可以嗎？不可以',
      summary: '用「-아／어도 돼요?」問可不可以，聽懂「-지 마세요」（請不要…）。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u19:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '在博物館、餐廳、別人家裡，常需要先問「可以…嗎？」。這個單元學會有禮貌地問，並聽懂「請不要…」的告示和提醒。',
            '做法：先認識會用到的詞，再練問可不可以、回答、聽懂禁止，最後聽一段在博物館的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u19:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('사진', '照片'),
            _sound('찍어요', '拍（照）（찍다）'),
            _sound('들어가요', '進去（들어가다）'),
            _sound('앉아요', '坐（앉다）'),
            _sound('열어요', '打開（열다）'),
            _sound('창문', '窗戶'),
            _sound('박물관', '博物館'),
            _sound('미술관', '美術館'),
            _sound('밖', '外面'),
            _sound('괜찮아요', '沒關係、可以'),
          ],
        ),
        LessonCard.concept(
          id: 'u19:pattern',
          title: '句型：___아／어도 돼요?',
          paragraphs: const <String>[
            '「動詞語幹＋아／어도 돼요?」＝可以…嗎？：사진을 찍어도 돼요?（可以拍照嗎？）',
            '回答可以：「네, 괜찮아요」或「네, ___아／어도 돼요」；不可以：「아니요, 안 돼요」。',
            '「-지 마세요」＝請不要…：사진을 찍지 마세요（請不要拍照）。告示、店員、工作人員常這樣說。',
          ],
        ),
        _grammarCard('a_eodo_dwaeyo'),
        _grammarCard('ji_maseyo'),
        LessonCard.sound(
          id: 'u19:drill1',
          title: '練習・可以…嗎？',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('사진을 찍어도 돼요?', '可以拍照嗎？', SpeechTag.polite),
            _sound('여기 앉아도 돼요?', '可以坐這裡嗎？', SpeechTag.polite),
            _sound('들어가도 돼요?', '可以進去嗎？', SpeechTag.polite),
            _sound('창문을 열어도 돼요?', '可以開窗戶嗎？', SpeechTag.polite),
            _sound('이거 먹어도 돼요?', '這個可以吃嗎？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u19:drill2',
          title: '練習・回答',
          paragraphs: const <String>[
            '對方回答你時常聽到的說法。',
          ],
          items: <SoundItem>[
            _sound('네, 괜찮아요.', '可以，沒關係。', SpeechTag.polite),
            _sound('네, 찍어도 돼요.', '可以，可以拍。', SpeechTag.polite),
            _sound('아니요, 안 돼요.', '不，不可以。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u19:drill3',
          title: '練習・請不要…',
          paragraphs: const <String>[
            '語幹＋지 마세요。「-세요」是尊敬說法，工作人員對客人常這樣說。',
          ],
          items: <SoundItem>[
            _sound('여기에서 사진을 찍지 마세요.', '請不要在這裡拍照。', SpeechTag.honorific),
            _sound('들어가지 마세요.', '請不要進去。', SpeechTag.honorific),
            _sound('여기에 앉지 마세요.', '請不要坐在這裡。', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u19:dialog',
          title: '短對話：在博物館',
          paragraphs: const <String>[
            'A 是遊客，B 是工作人員。「실례합니다」「죄송합니다」是固定的客氣話（합니다體），常和 해요體 一起用。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '실례합니다. 여기에서 사진을 찍어도 돼요?', '不好意思，這裡可以拍照嗎？', SpeechTag.polite),
            _line('B', '아니요, 박물관 안에서는 사진을 찍지 마세요.', '不行，在博物館裡面請不要拍照。', SpeechTag.honorific),
            _line('A', '아, 죄송합니다. 밖에서는 괜찮아요?', '啊，對不起。在外面可以嗎？', SpeechTag.polite),
            _line('B', '네, 밖에서는 찍어도 돼요.', '可以，在外面可以拍。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:사진',
        'word:찍다',
        'word:들어가다',
        'word:앉다',
        'word:열다',
        'word:창문',
        'word:박물관',
        'word:미술관',
        'word:밖',
        'word:괜찮아요',
      ]),
    );

Lesson _unitClothes() => Lesson(
      id: 'unit-20',
      group: LessonGroup.unit,
      title: '單元 20・買衣服',
      summary: '在服飾店問能不能試穿、有沒有別的尺寸和顏色，用 -지만 說「雖然…但是…」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u20:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會在服飾店說：「입어 봐도 돼요?」（可以試穿嗎？）、「다른 사이즈 있어요?」（有別的尺寸嗎？）。',
            '做法：先認識衣服的詞，再練試穿、說大小、問尺寸顏色、用 -지만 比較，最後聽一段買褲子的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u20:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('옷', '衣服'),
            _sound('바지', '褲子'),
            _sound('치마', '裙子'),
            _sound('신발', '鞋子'),
            _sound('사이즈', '尺寸'),
            _sound('색깔', '顏色'),
            _sound('입어요', '穿（입다）'),
            _sound('커요', '大（크다）'),
            _sound('작아요', '小（작다）'),
            _sound('예뻐요', '漂亮（예쁘다）'),
            _sound('어울려요', '適合、好看（어울리다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u20:pattern',
          title: '句型：다른 ___ 있어요?',
          paragraphs: const <String>[
            '「다른 ___ 있어요?」＝有別的___嗎？「다른」是「別的、不同的」。',
            '「입어 봐도 돼요?」＝可以試穿嗎？「-아／어 보다」是「試試看」，「-아／어도 돼요?」上一個單元學過，先整句記住。',
            '크다、예쁘다 的 ㅡ 會脫落：크다 → 커요、예쁘다 → 예뻐요。',
            '「-지만」＝雖然…但是…：예쁘지만 좀 비싸요（雖然漂亮，但有點貴）。',
          ],
        ),
        _grammarCard('jiman'),
        LessonCard.sound(
          id: 'u20:drill1',
          title: '練習・試穿與尺寸',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('이 바지 입어 봐도 돼요?', '這條褲子可以試穿嗎？', SpeechTag.polite),
            _sound('좀 커요.', '有點大。', SpeechTag.polite),
            _sound('좀 작아요.', '有點小。', SpeechTag.polite),
            _sound('다른 사이즈 있어요?', '有別的尺寸嗎？', SpeechTag.polite),
            _sound('다른 색깔 있어요?', '有別的顏色嗎？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u20:drill2',
          title: '練習・雖然…但是…',
          paragraphs: const <String>[
            '前半句＋지만＋後半句。',
          ],
          items: <SoundItem>[
            _sound('예쁘지만 좀 비싸요.', '雖然漂亮，但有點貴。', SpeechTag.polite),
            _sound('색깔은 좋지만 사이즈가 작아요.', '顏色很好，但是尺寸有點小。', SpeechTag.polite),
            _sound('이 신발은 싸지만 좋아요.', '這雙鞋雖然便宜，但是很好。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u20:buy',
          title: '練習・決定要買',
          paragraphs: const <String>[
            '第一句和第三句是你說的，「잘 어울려요」是店員說的（店員實際上也常說更客氣的「잘 어울리세요」）。「이걸로 주세요」＝我要這個（이것으로 的口語）。',
          ],
          items: <SoundItem>[
            _sound('이 치마 예뻐요.', '這件裙子很漂亮。', SpeechTag.polite),
            _sound('잘 어울려요.', '很適合您。', SpeechTag.polite),
            _sound('이걸로 주세요.', '我要這個。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u20:dialog',
          title: '短對話：買褲子',
          paragraphs: const <String>[
            'A 是店員，B 是客人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '어서 오세요.', '歡迎光臨。', SpeechTag.honorific),
            _line('B', '이 바지 입어 봐도 돼요?', '這條褲子可以試穿嗎？', SpeechTag.polite),
            _line('A', '네, 입어 보세요.', '可以，請試穿。', SpeechTag.honorific),
            _line('B', '좀 작아요. 다른 사이즈 있어요?', '有點小。有別的尺寸嗎？', SpeechTag.polite),
            _line('A', '네, 여기 있어요.', '有，在這裡。', SpeechTag.polite),
            _line('B', '이건 잘 맞아요.', '這件很合身。', SpeechTag.polite),
            _line('A', '잘 어울려요.', '很適合您。', SpeechTag.polite),
            _line('B', '이걸로 주세요.', '我要這個。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:옷',
        'word:바지',
        'word:치마',
        'word:신발',
        'word:사이즈',
        'word:색깔',
        'word:입다',
        'word:크다',
        'word:작다',
        'word:예쁘다',
        'word:어울리다',
      ]),
    );

Lesson _unitDates() => Lesson(
      id: 'unit-21',
      group: LessonGroup.unit,
      title: '單元 21・日期與生日',
      summary: '問今天幾號、星期幾、生日是什麼時候，並用 -네요 說「…呢！」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u21:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會問：「오늘이 며칠이에요?」（今天幾號？）、「생일이 언제예요?」（生日是什麼時候？）。',
            '做法：先認識日期和星期的詞，再練說日期、生日，學會用 -네요 表達驚訝和感嘆，最後聽一段聊生日的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u21:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('날짜', '日期'),
            _sound('며칠', '幾號；幾天'),
            _sound('생일', '生日'),
            _sound('요일', '星期（幾）'),
            _sound('월요일', '星期一'),
            _sound('화요일', '星期二'),
            _sound('수요일', '星期三'),
            _sound('목요일', '星期四'),
            _sound('올해', '今年'),
            _sound('내년', '明年'),
            _sound('생일 축하해요', '生日快樂'),
          ],
        ),
        LessonCard.concept(
          id: 'u21:pattern',
          title: '句型：오늘이 몇 월 며칠이에요?',
          paragraphs: const <String>[
            '日期用漢字數詞：월（月）、일（日）。「몇 월 며칠」＝幾月幾號。',
            '「며칠」是「幾號」的正確拼寫，不要寫成「몇일」。',
            '有兩個月份要特別記：6 月是「유월」，10 月是「시월」（不是 육월、십월）。其他月份照數字念：일월、이월、삼월…십이월。',
            '星期：월요일、화요일、수요일、목요일、금요일、토요일、일요일。問「星期幾」：「무슨 요일이에요?」',
            '「-네요」＝…呢！聽到新消息或親眼看到時的感嘆：오늘이 생일이네요!（今天是你生日呢！）',
          ],
        ),
        _grammarCard('ne_yo'),
        LessonCard.sound(
          id: 'u21:drill1',
          title: '練習・問日期與星期',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('오늘이 며칠이에요?', '今天幾號？', SpeechTag.polite),
            _sound('오늘은 시월 오 일이에요.', '今天是十月五號。', SpeechTag.polite),
            _sound('오늘 날짜가 어떻게 돼요?', '今天的日期是幾月幾號？', SpeechTag.polite),
            _sound('오늘은 무슨 요일이에요?', '今天星期幾？', SpeechTag.polite),
            _sound('수요일이에요.', '星期三。', SpeechTag.polite),
            _sound('내일은 목요일이에요.', '明天是星期四。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u21:drill2',
          title: '練習・生日',
          paragraphs: const <String>[
            '「언제」＝什麼時候。「생일을 보내다」＝過生日。',
          ],
          items: <SoundItem>[
            _sound('생일이 언제예요?', '你的生日是什麼時候？', SpeechTag.polite),
            _sound('제 생일은 삼월 십 일이에요.', '我的生日是三月十號。', SpeechTag.polite),
            _sound('다음 주 화요일이 제 생일이에요.', '下週二是我的生日。', SpeechTag.polite),
            _sound('생일 축하해요!', '生日快樂！', SpeechTag.polite),
            _sound('올해 생일에 뭐 할 거예요?', '今年生日要做什麼？', SpeechTag.polite),
            _sound('내년에는 한국에서 생일을 보내고 싶어요.', '明年想在韓國過生日。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u21:drill3',
          title: '練習・…呢！（-네요）',
          paragraphs: const <String>[
            '語幹＋네요，不分有沒有終聲。名詞後面用「(이)네요」。',
          ],
          items: <SoundItem>[
            _sound('오늘이 생일이네요!', '今天是你生日呢！', SpeechTag.polite),
            _sound('벌써 금요일이네요.', '已經星期五了呢。', SpeechTag.polite),
            _sound('시간이 정말 빠르네요.', '時間過得真快呢。', SpeechTag.polite),
            _sound('날씨가 좋네요.', '天氣真好呢。', SpeechTag.polite),
            _sound('사람이 많네요.', '人好多呢。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u21:dialog',
          title: '短對話：今天是生日',
          paragraphs: const <String>[
            'A 和 B 是剛認識的朋友。「생일이었네요」的 -었네요＝原來…啊（剛剛才知道的事）。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '오늘이 며칠이에요?', '今天幾號？', SpeechTag.polite),
            _line('B', '시월 오 일이에요. 왜요?', '十月五號。怎麼了？', SpeechTag.polite),
            _line('A', '아, 오늘이 제 생일이에요.', '啊，今天是我的生日。', SpeechTag.polite),
            _line('B', '아, 오늘이 생일이었네요! 생일 축하해요.', '啊，原來今天是你生日呢！生日快樂。', SpeechTag.polite),
            _line('A', '고마워요.', '謝謝。', SpeechTag.polite),
            _line('B', '제 생일은 다음 달이에요.', '我的生日在下個月。', SpeechTag.polite),
            _line('A', '그래요? 며칠이에요?', '是嗎？幾號？', SpeechTag.polite),
            _line('B', '십일월 이십 일이에요.', '十一月二十號。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:날짜',
        'word:며칠',
        'word:생일',
        'word:요일',
        'word:월요일',
        'word:화요일',
        'word:수요일',
        'word:목요일',
        'word:올해',
        'word:내년',
        'word:생일 축하해요',
      ]),
    );

Lesson _unitPhone() => Lesson(
      id: 'unit-22',
      group: LessonGroup.unit,
      title: '單元 22・打電話與聯絡',
      summary: '接電話、問電話號碼和聯絡方式，用 -지요?／-죠? 確認「…對吧？」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u22:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說：「여보세요?」（喂？）、「전화번호가 어떻게 돼요?」（你的電話號碼是多少？），並用「-죠?」確認約定。',
            '做法：先認識手機與聯絡的詞，再練接電話、念號碼、確認事情，最後聽一段確認約定的電話對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u22:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('전화', '電話'),
            _sound('번호', '號碼'),
            _sound('문자', '簡訊；文字'),
            _sound('메시지', '訊息'),
            _sound('이메일', '電子郵件'),
            _sound('주소', '地址'),
            _sound('스마트폰', '智慧型手機'),
            _sound('배터리', '電池'),
            _sound('충전기', '充電器'),
            _sound('연락해요', '聯絡（연락하다）'),
            _sound('나중에', '之後；以後'),
          ],
        ),
        LessonCard.concept(
          id: 'u22:pattern',
          title: '句型：전화번호가 어떻게 돼요?',
          paragraphs: const <String>[
            '接電話、打電話的第一句都是「여보세요?」（喂？）。',
            '「전화번호가 어떻게 돼요?」＝你的電話號碼是多少？比「전화번호가 뭐예요?」柔和。',
            '電話號碼用漢字數詞一個一個念，0 念「공」：010-1234-5678 → 공일공, 일이삼사, 오육칠팔。',
            '「-지요?」＝…對吧？口語常縮成「-죠?」：세 시죠?（是三點，對吧？）。回答：「네, 맞아요.」',
          ],
        ),
        _grammarCard('ji_yo'),
        LessonCard.sound(
          id: 'u22:drill1',
          title: '練習・接電話',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。「통화」＝通話、講電話。',
          ],
          items: <SoundItem>[
            _sound('여보세요?', '喂？', SpeechTag.polite),
            _sound('여보세요? 저 민수예요.', '喂？我是民秀。', SpeechTag.polite),
            _sound('지금 통화 괜찮아요?', '現在方便講電話嗎？', SpeechTag.polite),
            _sound('잘 안 들려요. 다시 말해 주세요.', '聽不太清楚。請再說一次。', SpeechTag.polite),
            _sound('나중에 다시 전화해 주세요.', '請之後再打給我。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u22:drill2',
          title: '練習・號碼與聯絡方式',
          paragraphs: const <String>[
            '號碼可以分段念，中間稍微停一下。',
          ],
          items: <SoundItem>[
            _sound('전화번호가 어떻게 돼요?', '你的電話號碼是多少？', SpeechTag.polite),
            _sound('공일공, 일이삼사, 오육칠팔이에요.', '010-1234-5678。', SpeechTag.polite),
            _sound('이메일 주소가 어떻게 돼요?', '你的電子郵件地址是什麼？', SpeechTag.polite),
            _sound('문자로 보내 주세요.', '請用簡訊傳給我。', SpeechTag.polite),
            _sound('메시지로 연락해 주세요.', '請傳訊息聯絡我。', SpeechTag.polite),
            _sound('충전기 있어요?', '有充電器嗎？', SpeechTag.polite),
            _sound('스마트폰 배터리가 없어요.', '手機沒電了。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u22:drill3',
          title: '練習・確認（-지요?／-죠?）',
          paragraphs: const <String>[
            '覺得對方也知道或會同意時，用「-죠?」確認。',
          ],
          items: <SoundItem>[
            _sound('민수 씨죠?', '是民秀先生吧？', SpeechTag.polite),
            _sound('내일 세 시죠?', '明天是三點，對吧？', SpeechTag.polite),
            _sound('이 번호 맞지요?', '這個號碼沒錯吧？', SpeechTag.polite),
            _sound('메시지 받았지요?', '有收到訊息吧？', SpeechTag.polite),
            _sound('한국어 어렵죠?', '韓文很難吧？', SpeechTag.polite),
            _sound('네, 맞아요.', '對，沒錯。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u22:dialog',
          title: '短對話：確認約定',
          paragraphs: const <String>[
            'A 是智秀，B 是民秀，B 打電話給 A。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '여보세요?', '喂？', SpeechTag.polite),
            _line('B', '여보세요? 지수 씨죠? 저 민수예요.', '喂？是智秀小姐吧？我是民秀。', SpeechTag.polite),
            _line('A', '아, 민수 씨, 안녕하세요.', '啊，民秀先生，你好。', SpeechTag.polite),
            _line('B', '지금 통화 괜찮아요?', '現在方便講電話嗎？', SpeechTag.polite),
            _line('A', '네, 괜찮아요.', '可以，沒問題。', SpeechTag.polite),
            _line('B', '내일 약속 세 시 맞죠?', '明天的約是三點，沒錯吧？', SpeechTag.polite),
            _line('A', '네, 맞아요. 학교 앞 카페에서 만나요.', '對，沒錯。在學校前面的咖啡店見。', SpeechTag.polite),
            _line('B', '좋아요. 그럼 내일 봐요.', '好。那明天見。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:전화',
        'word:번호',
        'word:문자',
        'word:메시지',
        'word:이메일',
        'word:주소',
        'word:스마트폰',
        'word:배터리',
        'word:충전기',
        'word:연락하다',
        'word:나중에',
      ]),
    );

Lesson _unitTaste() => Lesson(
      id: 'unit-23',
      group: LessonGroup.unit,
      title: '單元 23・吃吃看・說味道',
      summary: '說辣、甜、鹹、淡，用 -아/어 보세요 請人試試看，並學會 ㅂ 不規則（맵다 → 매워요）。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u23:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說：「좀 매워요.」（有點辣。）、「이거 먹어 보세요.」（請吃吃看這個。）。',
            '做法：先認識味道的詞，再學 ㅂ 不規則和「試試看」，練習說味道、點餐時說口味，最後聽一段在餐廳的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u23:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。맛있어요 常讀作 [마시써요]，맛없어요 讀作 [마덥써요]。',
          ],
          items: <SoundItem>[
            _sound('맛', '味道'),
            _sound('음식', '食物；料理'),
            _sound('김치', '泡菜'),
            _sound('떡볶이', '辣炒年糕'),
            _sound('매워요', '辣（맵다）'),
            _sound('달아요', '甜（달다）'),
            _sound('짜요', '鹹（짜다）'),
            _sound('싱거워요', '淡（싱겁다）'),
            _sound('뜨거워요', '燙；熱（뜨겁다）'),
            _sound('차가워요', '冰涼（차갑다）'),
            _sound('맛있어요', '好吃（맛있다）'),
            _sound('맛없어요', '不好吃（맛없다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u23:pattern',
          title: '句型：맛이 어때요?／___아/어 보세요',
          paragraphs: const <String>[
            '「맛이 어때요?」＝味道怎麼樣？',
            '맵다、싱겁다、뜨겁다、차갑다 都是 ㅂ 不規則：ㅂ 遇到 -아요/어요 變成 우：매워요、싱거워요、뜨거워요、차가워요。',
            '「-아/어 보세요」＝請試試看；「-아/어 봤어요」＝試過了。單元 20 的「입어 봐도 돼요?」就是這個說法。',
            '「너무」＝太…：너무 매워요（太辣了）。「좀」＝有點：좀 짜요（有點鹹）。',
            '「맛없어요」當面對店員或做菜的人說很失禮。想委婉一點，可以說「제 입에는 좀 안 맞아요.」（不太合我的口味）。',
          ],
        ),
        _grammarCard('b_irregular'),
        _grammarCard('a_eo_boda'),
        LessonCard.sound(
          id: 'u23:drill1',
          title: '練習・說味道',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('이 김치는 좀 매워요.', '這個泡菜有點辣。', SpeechTag.polite),
            _sound('떡볶이가 너무 매워요.', '辣炒年糕太辣了。', SpeechTag.polite),
            _sound('국이 좀 싱거워요.', '湯有點淡。', SpeechTag.polite),
            _sound('이 케이크는 너무 달아요.', '這個蛋糕太甜了。', SpeechTag.polite),
            _sound('좀 짜요.', '有點鹹。', SpeechTag.polite),
            _sound('물이 차가워요.', '水很冰。', SpeechTag.polite),
            _sound('커피가 뜨거워요. 조심하세요.', '咖啡很燙，請小心。', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u23:drill2',
          title: '練習・吃吃看（-아/어 보다）',
          paragraphs: const <String>[
            '請別人試試看用「-아/어 보세요」，說自己試過用「-아/어 봤어요」。',
          ],
          items: <SoundItem>[
            _sound('이거 한번 먹어 보세요.', '請吃吃看這個。', SpeechTag.honorific),
            _sound('김치도 먹어 보세요.', '泡菜也請吃吃看。', SpeechTag.honorific),
            _sound('저도 먹어 봐도 돼요?', '我也可以吃吃看嗎？', SpeechTag.polite),
            _sound('떡볶이를 처음 먹어 봤어요.', '我第一次吃辣炒年糕。', SpeechTag.polite),
            _sound('한국 음식을 다 먹어 보고 싶어요.', '我想把韓國菜都吃吃看。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u23:order',
          title: '練習・點餐時說口味',
          paragraphs: const <String>[
            '「덜」＝比較不…。「덜 맵게 해 주세요」＝請做得不要那麼辣，先整句記住。',
          ],
          items: <SoundItem>[
            _sound('많이 매워요?', '很辣嗎？', SpeechTag.polite),
            _sound('덜 맵게 해 주세요.', '請做得不要那麼辣。', SpeechTag.polite),
            _sound('맛이 어때요?', '味道怎麼樣？', SpeechTag.polite),
            _sound('정말 맛있네요!', '真的很好吃呢！', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u23:dialog',
          title: '短對話：在小吃店',
          paragraphs: const <String>[
            'A 是店員，B 是客人。「뭐 드릴까요?」（您要點什麼？）和「맛있게 드세요.」（請慢用）是店員常說的話，先聽懂就好。',
          ],
          items: <SoundItem>[
            _line('A', '뭐 드릴까요?', '您要點什麼？', SpeechTag.polite),
            _line('B', '떡볶이 하나 주세요. 많이 매워요?', '請給我一份辣炒年糕。很辣嗎？', SpeechTag.polite),
            _line('A', '네, 좀 매워요.', '對，有點辣。', SpeechTag.polite),
            _line('B', '그럼 덜 맵게 해 주세요.', '那請做得不要那麼辣。', SpeechTag.polite),
            _line('A', '네, 알겠어요.', '好的，知道了。', SpeechTag.polite),
            _line('A', '여기 있어요. 맛있게 드세요.', '來，您的餐點。請慢用。', SpeechTag.honorific),
            _line('B', '와, 맛있네요!', '哇，好好吃呢！', SpeechTag.polite),
            _line('A', '이 김치도 한번 먹어 보세요.', '這個泡菜也請吃吃看。', SpeechTag.honorific),
            _line('B', '김치는 좀 맵지만 정말 맛있어요.', '泡菜雖然有點辣，但是真的很好吃。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:맛',
        'word:음식',
        'word:김치',
        'word:떡볶이',
        'word:맵다',
        'word:달다#甜',
        'word:짜다',
        'word:싱겁다',
        'word:뜨겁다',
        'word:차갑다',
        'word:맛있다',
        'word:맛없다',
      ]),
    );

Lesson _unitBank() => Lesson(
      id: 'unit-24',
      group: LessonGroup.unit,
      title: '單元 24・在銀行換錢',
      summary: '在銀行說明來做什麼（換錢、開戶、領錢），用 -(으)려고 해요 說「我打算…」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u24:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會在銀行櫃台說：「돈을 바꾸려고 해요.」（我想換錢。），並聽懂行員常說的話。',
            '做法：先認識銀行的詞，再練說明來意、聽懂櫃台的指示，最後聽一段換錢的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u24:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('돈', '錢'),
            _sound('통장', '存摺；帳戶'),
            _sound('신용카드', '信用卡'),
            _sound('여권', '護照'),
            _sound('비밀번호', '密碼'),
            _sound('서류', '文件'),
            _sound('은행원', '銀行行員'),
            _sound('저금', '存錢'),
            _sound('필요해요', '需要（필요하다）'),
            _sound('찾아요', '尋找；領取（찾다）'),
            _sound('받아요', '收到；接受（받다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u24:pattern',
          title: '句型：___(으)려고 해요',
          paragraphs: const <String>[
            '「-(으)려고 해요」＝我打算…、我想要…。到銀行或郵局，先說明來做什麼：돈을 바꾸려고 해요（我想換錢）。',
            '無終聲加 -려고：바꾸다 → 바꾸려고。有終聲加 -으려고：찾다 → 찾으려고。ㄹ 終聲加 -려고：만들다 → 만들려고。',
            '「돈을 찾다」＝領錢。「통장을 만들다」＝開戶。',
            '換錢通常要出示護照；開戶通常還需要外國人登錄證（외국인등록증）等文件，短期旅客可能無法開戶。實際以銀行的說明為準。',
          ],
        ),
        _grammarCard('euryeogo'),
        LessonCard.sound(
          id: 'u24:drill1',
          title: '練習・說明來做什麼',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('돈을 바꾸려고 해요.', '我想換錢。', SpeechTag.polite),
            _sound('미국 돈을 한국 돈으로 바꾸려고 해요.', '我想把美金換成韓元。', SpeechTag.polite),
            _sound('통장을 만들려고 해요.', '我想開戶。', SpeechTag.polite),
            _sound('돈을 찾으려고 해요.', '我想領錢。', SpeechTag.polite),
            _sound('돈을 대만에 보내려고 해요.', '我想匯錢到台灣。', SpeechTag.polite),
            _sound('매달 조금씩 저금하려고 해요.', '我打算每個月存一點錢。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u24:drill2',
          title: '練習・櫃台常聽到、常問的話',
          paragraphs: const <String>[
            '前三句是行員常說的，先聽懂就好；後三句是你可以問的。',
          ],
          items: <SoundItem>[
            _sound('여권 좀 보여 주세요.', '請給我看一下護照。', SpeechTag.polite),
            _sound('여기에 이름을 써 주세요.', '請在這裡寫名字。', SpeechTag.polite),
            _sound('비밀번호를 눌러 주세요.', '請按密碼。', SpeechTag.polite),
            _sound('어떤 서류가 필요해요?', '需要什麼文件？', SpeechTag.polite),
            _sound('신용카드도 만들 수 있어요?', '也可以辦信用卡嗎？', SpeechTag.polite),
            _sound('여기 있어요.', '在這裡。（遞東西時說）', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u24:dialog',
          title: '短對話：在銀行換錢',
          paragraphs: const <String>[
            'A 是銀行行員，B 是客人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '어서 오세요.', '歡迎光臨。', SpeechTag.honorific),
            _line('B', '안녕하세요. 돈을 바꾸려고 해요.', '您好。我想換錢。', SpeechTag.polite),
            _line('A', '어느 나라 돈이에요?', '是哪個國家的錢？', SpeechTag.polite),
            _line('B', '미국 돈이에요. 한국 돈으로 바꾸려고 해요.', '是美金。我想換成韓元。', SpeechTag.polite),
            _line('A', '여권 좀 보여 주세요.', '請給我看一下護照。', SpeechTag.polite),
            _line('B', '네, 여기 있어요.', '好，在這裡。', SpeechTag.polite),
            _line('A', '여기에 이름을 써 주세요.', '請在這裡寫名字。', SpeechTag.polite),
            _line('B', '네, 알겠어요.', '好，知道了。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:돈',
        'word:통장',
        'word:신용카드',
        'word:여권',
        'word:비밀번호',
        'word:서류',
        'word:은행원',
        'word:저금',
        'word:필요하다',
        'word:찾다',
        'word:받다',
      ]),
    );

Lesson _unitLost() => Lesson(
      id: 'unit-25',
      group: LessonGroup.unit,
      title: '單元 25・東西不見了',
      summary: '說明東西弄丟了、描述顏色和裡面有什麼，用 -(으)ㄹ게요 說「我會…」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u25:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說：「지갑을 잃어버렸어요.」（我的錢包弄丟了。）、「도와주세요.」（請幫幫我。）。',
            '做法：先認識遺失物和顏色的詞，再練說明東西不見、描述東西，學會用 -(으)ㄹ게요 承諾，最後聽一段在車站的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u25:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('지갑', '錢包'),
            _sound('잃어버렸어요', '弄丟了（잃어버리다）'),
            _sound('도와주세요', '請幫幫我'),
            _sound('경찰서', '警察局'),
            _sound('색', '顏色'),
            _sound('검은색', '黑色'),
            _sound('하얀색', '白色'),
            _sound('파란색', '藍色'),
            _sound('안', '裡面'),
            _sound('위', '上面'),
            _sound('놓았어요', '放了（놓다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u25:pattern',
          title: '句型：___을/를 잃어버렸어요',
          paragraphs: const <String>[
            '東西不見時先說：「지갑을 잃어버렸어요.」（我的錢包弄丟了。）需要幫忙時說：「도와주세요.」',
            '描述東西：「무슨 색이에요?」（什麼顏色？）→「검은색이에요.」',
            '「-(으)ㄹ게요」＝我會…、我來…，是對對方的承諾：찾으면 연락할게요（找到的話我會聯絡你）。拼寫是「게」，不是「께」。',
            '在韓國，地鐵、公車上遺失的東西可以向車站或失物招領中心詢問；錢包、護照遺失也可以到警察局（경찰서）報案。',
          ],
        ),
        _grammarCard('eul_geyo'),
        LessonCard.sound(
          id: 'u25:drill1',
          title: '練習・說明東西不見了',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('실례합니다. 도와주세요.', '不好意思，請幫幫我。', SpeechTag.polite),
            _sound('지갑을 잃어버렸어요.', '我的錢包弄丟了。', SpeechTag.polite),
            _sound('지하철에서 잃어버렸어요.', '在地鐵上弄丟了。', SpeechTag.polite),
            _sound('검은색 지갑이에요.', '是黑色的錢包。', SpeechTag.polite),
            _sound('안에 신용카드하고 돈이 있어요.', '裡面有信用卡和錢。', SpeechTag.polite),
            _sound('가방을 의자 위에 놓았어요.', '我把包包放在椅子上了。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u25:drill2',
          title: '練習・我會…（-(으)ㄹ게요）',
          paragraphs: const <String>[
            '只用在說話者自己，回應對方時用。',
          ],
          items: <SoundItem>[
            _sound('여기에서 기다릴게요.', '我在這裡等。', SpeechTag.polite),
            _sound('제가 찾아 볼게요.', '我來找找看。', SpeechTag.polite),
            _sound('찾으면 연락할게요.', '找到的話我會聯絡你。', SpeechTag.polite),
            _sound('전화번호를 여기에 쓸게요.', '我把電話號碼寫在這裡。', SpeechTag.polite),
            _sound('내일 다시 올게요.', '我明天會再來。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u25:dialog',
          title: '短對話：在車站找錢包',
          paragraphs: const <String>[
            'A 是旅客，B 是車站站務員。「연락드릴게요」是「연락할게요」的謙讓說法，工作人員對客人常這樣說，先聽懂就好。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '실례합니다. 지갑을 잃어버렸어요.', '不好意思，我的錢包弄丟了。', SpeechTag.polite),
            _line('B', '어디에서 잃어버렸어요?', '在哪裡弄丟的？', SpeechTag.polite),
            _line('A', '지하철에서요. 삼십 분 전에요.', '在地鐵上。三十分鐘前。', SpeechTag.polite),
            _line('B', '무슨 색이에요?', '什麼顏色？', SpeechTag.polite),
            _line('A', '검은색이에요. 안에 신용카드가 있어요.', '黑色的。裡面有信用卡。', SpeechTag.polite),
            _line('B', '여기에 이름하고 전화번호를 써 주세요. 찾으면 연락드릴게요.', '請在這裡寫名字和電話號碼。找到的話我會聯絡您。', SpeechTag.polite),
            _line('A', '네, 감사합니다. 연락 기다릴게요.', '好，謝謝。我等您的聯絡。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:지갑',
        'word:잃어버리다',
        'word:도와주세요',
        'word:경찰서',
        'word:색',
        'word:검은색',
        'word:하얀색',
        'word:파란색',
        'word:안#裡',
        'word:위',
        'word:놓다',
      ]),
    );

Lesson _unitDescribe() => Lesson(
      id: 'unit-26',
      group: LessonGroup.unit,
      title: '單元 26・描述人和東西',
      summary: '用「形容詞＋(으)ㄴ＋名詞」描述人的樣子和東西，例如「키가 큰 남자」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u26:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說：「키가 큰 남자예요.」（是個子高的男生。）、「조용한 카페를 좋아해요.」（我喜歡安靜的咖啡店。）。',
            '做法：先認識描述人和東西的詞，再學形容詞放在名詞前面的變化，練習描述人、東西和地方，最後聽一段在機場找人的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u26:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('남자', '男生；男人'),
            _sound('여자', '女生；女人'),
            _sound('키', '身高；個子'),
            _sound('안경', '眼鏡'),
            _sound('모자', '帽子'),
            _sound('길어요', '長（길다）'),
            _sound('짧아요', '短（짧다）'),
            _sound('친절해요', '親切（친절하다）'),
            _sound('조용해요', '安靜（조용하다）'),
            _sound('깨끗해요', '乾淨（깨끗하다）'),
            _sound('귀여워요', '可愛（귀엽다）'),
            _sound('멋있어요', '帥氣；有型（멋있다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u26:pattern',
          title: '句型：키가 큰 사람',
          paragraphs: const <String>[
            '形容詞放在名詞前面時要變形：크다 → 큰（큰 가방）、작다 → 작은（작은 방）。',
            '無終聲加 ㄴ、有終聲加 은；있다／없다 結尾加 는（멋있는 사람）；ㄹ 終聲去掉 ㄹ 再加 ㄴ（긴 머리）；ㅂ 不規則變成「운」（귀여운 강아지）。',
            '「키가 커요」＝個子高（韓文說身高「大」）。「키가 큰 사람」＝個子高的人。',
            '戴眼鏡、戴帽子都用「쓰다」：안경을 써요、모자를 써요。「쓰고 있어요」＝正戴著。',
            '「머리」可以指頭，也可以指頭髮：머리가 길어요（頭髮很長）。',
          ],
        ),
        _grammarCard('adj_eun'),
        LessonCard.sound(
          id: 'u26:drill1',
          title: '練習・描述人',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('키가 커요.', '個子很高。', SpeechTag.polite),
            _sound('키가 큰 남자예요.', '是個子高的男生。', SpeechTag.polite),
            _sound('머리가 짧은 여자예요.', '是短頭髮的女生。', SpeechTag.polite),
            _sound('안경을 쓰고 있어요.', '戴著眼鏡。', SpeechTag.polite),
            _sound('모자를 쓰고 있어요.', '戴著帽子。', SpeechTag.polite),
            _sound('아주 친절한 사람이에요.', '是非常親切的人。', SpeechTag.polite),
            _sound('정말 멋있는 사람이에요.', '是很帥氣的人。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u26:drill2',
          title: '練習・描述東西和地方',
          paragraphs: const <String>[
            '注意每個形容詞放在名詞前面的形狀。',
          ],
          items: <SoundItem>[
            _sound('조용한 카페를 좋아해요.', '我喜歡安靜的咖啡店。', SpeechTag.polite),
            _sound('깨끗한 호텔을 찾고 있어요.', '我在找乾淨的飯店。', SpeechTag.polite),
            _sound('작은 가방이에요.', '是小的包包。', SpeechTag.polite),
            _sound('긴 치마를 사고 싶어요.', '我想買長裙。', SpeechTag.polite),
            _sound('귀여운 강아지네요!', '好可愛的小狗呢！', SpeechTag.polite),
            _sound('맛있는 식당 알아요?', '你知道好吃的餐廳嗎？', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u26:dialog',
          title: '短對話：在機場找人',
          paragraphs: const <String>[
            'A 和 B 在機場等 B 的朋友。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '친구가 어디에 있어요?', '你的朋友在哪裡？', SpeechTag.polite),
            _line('B', '저기 있어요. 키가 큰 남자예요.', '在那裡。是個子高的男生。', SpeechTag.polite),
            _line('A', '모자를 쓰고 있어요?', '他戴著帽子嗎？', SpeechTag.polite),
            _line('B', '아니요, 안경을 쓰고 있어요.', '沒有，他戴的是眼鏡。', SpeechTag.polite),
            _line('A', '아, 저 사람이요? 멋있네요.', '啊，是那個人嗎？很帥氣呢。', SpeechTag.polite),
            _line('B', '네, 아주 친절한 사람이에요.', '對，是非常親切的人。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:남자',
        'word:여자',
        'word:키',
        'word:안경',
        'word:모자',
        'word:길다',
        'word:짧다',
        'word:친절하다',
        'word:조용하다',
        'word:깨끗하다',
        'word:귀엽다',
        'word:멋있다',
      ]),
    );

Lesson _unitExperience() => Lesson(
      id: 'unit-27',
      group: LessonGroup.unit,
      title: '單元 27・你去過嗎？',
      summary: '用 -(으)ㄴ 적이 있어요 問和說經驗：去過哪裡、吃過什麼、做過什麼。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u27:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會問和回答：「부산에 가 본 적이 있어요?」（你去過釜山嗎？）→「네, 있어요.／아니요, 없어요.」',
            '做法：先認識國家、城市和旅行的詞，再練問經驗、說自己的經驗，最後聽一段聊旅行的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u27:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('경험', '經驗'),
            _sound('외국', '外國；國外'),
            _sound('비행기', '飛機'),
            _sound('일본', '日本'),
            _sound('미국', '美國'),
            _sound('중국', '中國'),
            _sound('서울', '首爾'),
            _sound('부산', '釜山'),
            _sound('고향', '故鄉；家鄉'),
            _sound('관광', '觀光'),
            _sound('배워요', '學習（배우다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u27:pattern',
          title: '句型：___(으)ㄴ 적이 있어요?',
          paragraphs: const <String>[
            '「-(으)ㄴ 적이 있어요?」＝你曾經…過嗎？回答：「네, 있어요.」「아니요, 없어요.」',
            '常和「-아/어 보다」合在一起：가 본 적이 있어요?（去過嗎？）、먹어 본 적이 있어요?（吃過嗎？）。',
            '「처음」＝第一次：「한국은 처음이에요.」＝第一次來韓國。',
            '「몇 번」＝幾次：「두 번 와 봤어요.」＝來過兩次。「두 번째」＝第二次。',
          ],
        ),
        _grammarCard('eun_jeok'),
        LessonCard.sound(
          id: 'u27:drill1',
          title: '練習・問經驗',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('한국에 와 본 적이 있어요?', '你來過韓國嗎？', SpeechTag.polite),
            _sound('네, 두 번 와 봤어요.', '有，來過兩次。', SpeechTag.polite),
            _sound('부산에 가 본 적이 있어요?', '你去過釜山嗎？', SpeechTag.polite),
            _sound('아니요, 아직 없어요.', '沒有，還沒去過。', SpeechTag.polite),
            _sound('외국에서 살아 본 적이 있어요?', '你在國外住過嗎？', SpeechTag.polite),
            _sound('저는 비행기를 타 본 적이 없어요.', '我沒搭過飛機。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u27:drill2',
          title: '練習・說自己的經驗',
          paragraphs: const <String>[
            '台灣的地名，韓文依華語發音拼寫：타이중（台中）、타이베이（台北）。',
          ],
          items: <SoundItem>[
            _sound('일본에 가 본 적이 있어요.', '我去過日本。', SpeechTag.polite),
            _sound('중국 음식을 만들어 본 적이 있어요.', '我做過中國菜。', SpeechTag.polite),
            _sound('미국에서 영어를 배운 적이 있어요.', '我在美國學過英文。', SpeechTag.polite),
            _sound('한국은 처음이에요.', '這是我第一次來韓國。', SpeechTag.polite),
            _sound('제 고향은 타이중이에요.', '我的家鄉是台中。', SpeechTag.polite),
            _sound('서울 관광을 하고 싶어요.', '我想在首爾觀光。', SpeechTag.polite),
            _sound('좋은 경험이었어요.', '是很好的經驗。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u27:dialog',
          title: '短對話：聊旅行經驗',
          paragraphs: const <String>[
            'A 是韓國人，B 是來韓國旅行的人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '한국은 처음이에요?', '你是第一次來韓國嗎？', SpeechTag.polite),
            _line('B', '아니요, 두 번째예요. 작년에 서울에 왔어요.', '不是，是第二次。去年來過首爾。', SpeechTag.polite),
            _line('A', '부산에 가 본 적이 있어요?', '你去過釜山嗎？', SpeechTag.polite),
            _line('B', '아니요, 없어요. 이번에 가 보고 싶어요.', '沒有。這次想去看看。', SpeechTag.polite),
            _line('A', '부산 바다가 정말 예뻐요. 꼭 가 보세요.', '釜山的海真的很美。一定要去看看。', SpeechTag.honorific),
            _line('B', '네, 꼭 가 볼게요.', '好，我一定會去看看。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:경험',
        'word:외국',
        'word:비행기',
        'word:일본',
        'word:미국',
        'word:중국',
        'word:서울',
        'word:부산',
        'word:고향',
        'word:관광',
        'word:배우다',
      ]),
    );

Lesson _unitCompare() => Lesson(
      id: 'unit-28',
      group: LessonGroup.unit,
      title: '單元 28・比一比、選一個',
      summary: '用 보다 (더)、제일 比較和選擇，並學會 ㄷ・르 不規則（빠르다 → 빨라요）。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u28:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說：「지하철이 버스보다 더 빨라요.」（地鐵比公車快。）、「뭐가 제일 맛있어요?」（什麼最好吃？）。',
            '做法：先認識比較用的形容詞，再學 보다、제일 和 르 不規則，練習比較、選最好的，最後聽一段問怎麼去機場的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u28:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('제일', '最'),
            _sound('가장', '最'),
            _sound('빨라요', '快（빠르다）'),
            _sound('느려요', '慢（느리다）'),
            _sound('가까워요', '近（가깝다）'),
            _sound('멀어요', '遠（멀다）'),
            _sound('무거워요', '重（무겁다）'),
            _sound('가벼워요', '輕（가볍다）'),
            _sound('비슷해요', '相似（비슷하다）'),
            _sound('달라요', '不同（다르다）'),
            _sound('골라요', '挑選（고르다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u28:pattern',
          title: '句型：A가 B보다 더 ___',
          paragraphs: const <String>[
            '「A가 B보다 더 …」＝A 比 B 更…：지하철이 버스보다 더 빨라요。「더」可以省略。',
            '「제일／가장」＝最：택시가 제일 비싸요。口語比較常用「제일」。',
            '兩個選一個時問：「뭐가 더 좋아요?」（哪個比較好？）',
            '빠르다、다르다、고르다 是「르」不規則：빨라요、달라요、골라요。가깝다、무겁다、가볍다 是單元 23 學過的 ㅂ 不規則：가까워요、무거워요、가벼워요。',
            'ㄷ 不規則：걷다 → 걸어요、걸어서（走路）。對話裡的「걸어서 오 분」＝走路五分鐘。',
          ],
        ),
        _grammarCard('boda_deo'),
        _grammarCard('d_reu_irregular'),
        LessonCard.sound(
          id: 'u28:drill1',
          title: '練習・比較',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('지하철이 버스보다 빨라요.', '地鐵比公車快。', SpeechTag.polite),
            _sound('택시가 지하철보다 더 비싸요.', '計程車比地鐵更貴。', SpeechTag.polite),
            _sound('이 가방이 저 가방보다 가벼워요.', '這個包包比那個包包輕。', SpeechTag.polite),
            _sound('호텔이 공항에서 멀어요?', '飯店離機場遠嗎？', SpeechTag.polite),
            _sound('아니요, 아주 가까워요.', '不會，很近。', SpeechTag.polite),
            _sound('두 개가 비슷해요.', '兩個很像。', SpeechTag.polite),
            _sound('이것하고 저것은 색깔이 달라요.', '這個和那個顏色不一樣。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u28:drill2',
          title: '練習・最…（제일、가장）',
          paragraphs: const <String>[
            '「인기가 많아요」＝很受歡迎。「중에서」＝…之中。',
          ],
          items: <SoundItem>[
            _sound('뭐가 제일 맛있어요?', '什麼最好吃？', SpeechTag.polite),
            _sound('이게 제일 인기가 많아요.', '這個最受歡迎。', SpeechTag.polite),
            _sound('이 가방이 제일 무거워요.', '這個包包最重。', SpeechTag.polite),
            _sound('한국 음식 중에서 불고기를 가장 좋아해요.', '韓國菜裡我最喜歡韓式烤肉。', SpeechTag.polite),
            _sound('버스는 좀 느려요.', '公車有點慢。', SpeechTag.polite),
            _sound('천천히 골라 보세요.', '請慢慢挑。', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u28:dialog',
          title: '短對話：怎麼去機場比較快',
          paragraphs: const <String>[
            'A 是旅客，B 是飯店櫃台人員。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '공항에 어떻게 가요? 버스가 더 빨라요, 지하철이 더 빨라요?', '去機場要怎麼去？公車快還是地鐵快？', SpeechTag.polite),
            _line('B', '지하철이 버스보다 더 빨라요.', '地鐵比公車快。', SpeechTag.polite),
            _line('A', '택시는요?', '計程車呢？', SpeechTag.polite),
            _line('B', '택시가 제일 편하지만 제일 비싸요.', '計程車最方便，但是最貴。', SpeechTag.polite),
            _line('A', '그럼 지하철로 갈게요. 지하철역이 여기에서 가까워요?', '那我搭地鐵去。地鐵站離這裡近嗎？', SpeechTag.polite),
            _line('B', '네, 아주 가까워요. 걸어서 오 분 걸려요.', '對，很近。走路五分鐘。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:제일',
        'word:가장',
        'word:빠르다',
        'word:느리다',
        'word:가깝다',
        'word:멀다',
        'word:무겁다',
        'word:가볍다',
        'word:비슷하다',
        'word:다르다',
        'word:고르다',
      ]),
    );

Lesson _unitFeelings() => Lesson(
      id: 'unit-29',
      group: LessonGroup.unit,
      title: '單元 29・心情與狀態',
      summary: '說自己累、餓、想睡、心情好不好，並用 -겠어요 回應對方：「一定很累吧」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u29:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說：「좀 피곤해요.」（有點累。），以及回應對方：「정말 피곤하겠어요.」（一定很累吧。）。',
            '做法：先認識心情和狀態的詞，再練說自己的狀態、用 -겠어요 回應對方，最後聽一段關心朋友的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u29:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('기분', '心情'),
            _sound('피곤해요', '疲倦（피곤하다）'),
            _sound('바빠요', '忙（바쁘다）'),
            _sound('배고파요', '肚子餓（배고프다）'),
            _sound('목말라요', '口渴（목마르다）'),
            _sound('졸려요', '想睡（졸리다）'),
            _sound('기뻐요', '高興（기쁘다）'),
            _sound('슬퍼요', '悲傷（슬프다）'),
            _sound('걱정해요', '擔心（걱정하다）'),
            _sound('괜찮아요', '沒關係；還好（괜찮다）'),
            _sound('새벽', '凌晨'),
          ],
        ),
        LessonCard.concept(
          id: 'u29:pattern',
          title: '句型：기분이 어때요?／___겠어요',
          paragraphs: const <String>[
            '「기분이 어때요?」＝心情怎麼樣？「괜찮아요?」＝你還好嗎？「기분이 좋아요／안 좋아요」＝心情好／不好。',
            'ㅡ 脫落：바쁘다 → 바빠요、배고프다 → 배고파요、기쁘다 → 기뻐요、슬프다 → 슬퍼요。목마르다 是「르」不規則：목말라요。',
            '聽到對方的狀況，用「-겠어요」回應：피곤하겠어요（一定很累吧）、좋겠어요（真好、真替你高興）。',
            '「-지 마세요」（單元 19）＝請不要…：걱정하지 마세요（別擔心）。',
          ],
        ),
        _grammarCard('gesseoyo'),
        LessonCard.sound(
          id: 'u29:drill1',
          title: '練習・說自己的狀態',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('오늘 좀 피곤해요.', '今天有點累。', SpeechTag.polite),
            _sound('요즘 많이 바빠요.', '最近很忙。', SpeechTag.polite),
            _sound('배고파요. 밥 먹으러 가요.', '肚子餓了。去吃飯吧。', SpeechTag.polite),
            _sound('목말라요. 물 좀 주세요.', '口渴了。請給我一點水。', SpeechTag.polite),
            _sound('너무 졸려요.', '好想睡。', SpeechTag.polite),
            _sound('오늘은 기분이 좋아요.', '今天心情很好。', SpeechTag.polite),
            _sound('걱정하지 마세요.', '請別擔心。', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u29:drill2',
          title: '練習・回應對方（-겠어요）',
          paragraphs: const <String>[
            '聽到對方的狀況時，用 -겠어요 表示理解。',
          ],
          items: <SoundItem>[
            _sound('정말 피곤하겠어요.', '一定很累吧。', SpeechTag.polite),
            _sound('배고프겠어요. 같이 밥 먹을까요?', '應該餓了吧。要一起吃飯嗎？', SpeechTag.polite),
            _sound('와, 정말 기쁘겠어요.', '哇，一定很高興吧。', SpeechTag.polite),
            _sound('정말 좋겠어요!', '真好！', SpeechTag.polite),
            _sound('많이 슬프겠어요.', '一定很難過吧。', SpeechTag.polite),
            _sound('괜찮아요? 좀 쉬세요.', '你還好嗎？請休息一下。', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u29:dialog',
          title: '短對話：朋友好像很累',
          paragraphs: const <String>[
            'A 和 B 是朋友。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '괜찮아요? 기분이 안 좋아요?', '你還好嗎？心情不好嗎？', SpeechTag.polite),
            _line('B', '아니요, 그냥 좀 졸려요. 어제 새벽 두 시에 잤어요.', '不是，只是有點想睡。昨天凌晨兩點才睡。', SpeechTag.polite),
            _line('A', '왜요?', '為什麼？', SpeechTag.polite),
            _line('B', '일이 많아서요.', '因為工作很多。', SpeechTag.polite),
            _line('A', '와, 정말 피곤하겠어요.', '哇，一定很累吧。', SpeechTag.polite),
            _line('B', '네, 그리고 배도 고파요.', '對，而且肚子也餓了。', SpeechTag.polite),
            _line('A', '그럼 같이 점심 먹으러 갈까요?', '那要一起去吃午餐嗎？', SpeechTag.polite),
            _line('B', '좋아요. 고마워요.', '好啊。謝謝。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:기분',
        'word:피곤하다',
        'word:바쁘다',
        'word:배고프다',
        'word:목마르다',
        'word:졸리다',
        'word:기쁘다',
        'word:슬프다',
        'word:걱정하다',
        'word:괜찮다',
        'word:새벽',
      ]),
    );

Lesson _unitWork() => Lesson(
      id: 'unit-30',
      group: LessonGroup.unit,
      title: '單元 30・學校與工作',
      summary: '問和說工作、主修，用「動詞＋는＋名詞」說「我工作的公司」「我喜歡的課」。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u30:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會問：「무슨 일을 해요?」（你做什麼工作？）、「전공이 뭐예요?」（你主修什麼？），並用 -는 修飾名詞。',
            '做法：先認識學校和工作的詞，再練說工作、說學校生活，最後聽一段認識新朋友的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u30:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('직업', '職業'),
            _sound('사무실', '辦公室'),
            _sound('동료', '同事'),
            _sound('전공', '主修；專業'),
            _sound('대학교', '大學'),
            _sound('수업', '上課；課程'),
            _sound('시험', '考試'),
            _sound('숙제', '作業'),
            _sound('가르쳐요', '教（가르치다）'),
            _sound('출근', '上班'),
            _sound('퇴근', '下班'),
          ],
        ),
        LessonCard.concept(
          id: 'u30:pattern',
          title: '句型：무슨 일을 해요?／動詞＋는＋名詞',
          paragraphs: const <String>[
            '問職業：「무슨 일을 해요?」（你做什麼工作？）比「직업이 뭐예요?」柔和。對初次見面、年紀比你大的人，常說更禮貌的「무슨 일 하세요?」。',
            '回答：「저는 회사원이에요.」「회사에서 일해요.」',
            '「動詞＋는＋名詞」＝正在…的、常…的：제가 일하는 회사（我工作的公司）、같이 일하는 동료（一起工作的同事）。',
            '「있다」也用 -는：서울에 있는 회사（在首爾的公司）。',
            '「동료」讀作 [동뇨]。上班、下班：「출근해요」「퇴근해요」。',
          ],
        ),
        _grammarCard('verb_neun'),
        LessonCard.sound(
          id: 'u30:drill1',
          title: '練習・工作',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。',
          ],
          items: <SoundItem>[
            _sound('무슨 일을 해요?', '你做什麼工作？', SpeechTag.polite),
            _sound('무슨 일 하세요?', '請問您做什麼工作？（更禮貌）', SpeechTag.honorific),
            _sound('저는 회사원이에요.', '我是上班族。', SpeechTag.polite),
            _sound('제가 일하는 회사는 서울에 있어요.', '我工作的公司在首爾。', SpeechTag.polite),
            _sound('사무실은 삼 층에 있어요.', '辦公室在三樓。', SpeechTag.polite),
            _sound('같이 일하는 동료예요.', '是一起工作的同事。', SpeechTag.polite),
            _sound('보통 아홉 시에 출근해요.', '我通常九點上班。', SpeechTag.polite),
            _sound('여섯 시에 퇴근해요.', '我六點下班。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u30:drill2',
          title: '練習・學校',
          paragraphs: const <String>[
            '「제가 좋아하는 …」＝我喜歡的…。',
          ],
          items: <SoundItem>[
            _sound('전공이 뭐예요?', '你主修什麼？', SpeechTag.polite),
            _sound('대학교에서 경제학을 공부해요.', '我在大學讀經濟學。', SpeechTag.polite),
            _sound('제가 좋아하는 수업은 한국어 수업이에요.', '我喜歡的課是韓文課。', SpeechTag.polite),
            _sound('다음 주에 시험이 있어요.', '下週有考試。', SpeechTag.polite),
            _sound('숙제가 너무 많아요.', '作業太多了。', SpeechTag.polite),
            _sound('한국어를 가르치는 선생님이에요.', '是教韓文的老師。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u30:dialog',
          title: '短對話：認識新朋友',
          paragraphs: const <String>[
            'A 是智秀，B 是剛認識的人。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '무슨 일을 해요?', '你做什麼工作？', SpeechTag.polite),
            _line('B', '저는 디자이너예요. 서울에 있는 회사에서 일해요.', '我是設計師。在首爾的公司工作。', SpeechTag.polite),
            _line('A', '와, 멋있네요.', '哇，好帥氣呢。', SpeechTag.polite),
            _line('B', '지수 씨는 무슨 일을 해요?', '智秀小姐做什麼工作？', SpeechTag.polite),
            _line('A', '저는 대학생이에요. 경제학을 공부하고 있어요.', '我是大學生。正在讀經濟學。', SpeechTag.polite),
            _line('B', '학교생활은 어때요?', '學校生活怎麼樣？', SpeechTag.polite),
            _line('A', '재미있지만 숙제가 많아요.', '很有趣，但是作業很多。', SpeechTag.polite),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:직업',
        'word:사무실',
        'word:동료',
        'word:전공',
        'word:대학교',
        'word:수업',
        'word:시험',
        'word:숙제',
        'word:가르치다',
        'word:출근',
        'word:퇴근',
      ]),
    );

Lesson _unitGoodbye() => Lesson(
      id: 'unit-31',
      group: LessonGroup.unit,
      title: '單元 31・好久不見與道別',
      summary: '說好久不見、道謝和道別，用 -(으)ㄹ 때 說「…的時候」，約好保持聯絡。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'u31:goal',
          title: '這個單元要學會什麼',
          paragraphs: const <String>[
            '學會說：「오랜만이에요.」（好久不見。）、「시간이 있을 때 연락해 주세요.」（有空的時候請聯絡我。），並分清楚兩種「再見」。',
            '做法：先認識見面和道別的說法，再練好久不見、「…的時候」、道別，最後聽一段回國前道別的對話。',
            '每個句子底下都有語氣標籤。半語版放在「半語（額外學習）」。',
          ],
        ),
        LessonCard.sound(
          id: 'u31:words',
          title: '先認識這些詞',
          paragraphs: const <String>[
            '點每一個聽三次，跟著念。',
          ],
          items: <SoundItem>[
            _sound('오랜만이에요', '好久不見'),
            _sound('잘 지내요', '過得很好'),
            _sound('안녕히 가세요', '請慢走（對要離開的人說）'),
            _sound('안녕히 계세요', '再見（對留下的人說）'),
            _sound('조심하세요', '請小心'),
            _sound('보고 싶어요', '想念；想見（보고 싶다）'),
            _sound('고마워요', '感謝（고맙다）'),
            _sound('미안해요', '抱歉（미안하다）'),
            _sound('또', '又；再'),
            _sound('기억해요', '記得（기억하다）'),
            _sound('돌아가요', '回去（돌아가다）'),
          ],
        ),
        LessonCard.concept(
          id: 'u31:pattern',
          title: '句型：___(으)ㄹ 때 연락해 주세요',
          paragraphs: const <String>[
            '「-(으)ㄹ 때」＝…的時候：시간이 있을 때（有空的時候）、한국에 올 때（來韓國的時候）。',
            '道別要看誰走、誰留：對要離開的人說「안녕히 가세요」，對留下來的人說「안녕히 계세요」。兩個人都要離開時，都說「안녕히 가세요」。',
            '很久沒見：「오랜만이에요.」問近況：「잘 지냈어요?」（這段時間過得好嗎？）回答：「네, 잘 지냈어요.」「잘 지내요」是「現在過得很好」。',
            '「고마웠어요」＝（那段時間）謝謝你了，用在回顧已經過去的事。',
          ],
        ),
        _grammarCard('eul_ttae'),
        LessonCard.sound(
          id: 'u31:drill1',
          title: '練習・好久不見',
          paragraphs: const <String>[
            '每句點一下聽，再自己大聲念一次。「그럼요」＝當然。',
          ],
          items: <SoundItem>[
            _sound('오랜만이에요.', '好久不見。', SpeechTag.polite),
            _sound('잘 지냈어요?', '過得好嗎？', SpeechTag.polite),
            _sound('네, 잘 지냈어요.', '嗯，過得很好。', SpeechTag.polite),
            _sound('정말 보고 싶었어요.', '真的很想你。', SpeechTag.polite),
            _sound('저를 기억해요?', '你記得我嗎？', SpeechTag.polite),
            _sound('그럼요, 기억해요.', '當然記得。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u31:drill2',
          title: '練習・…的時候（-(으)ㄹ 때）',
          paragraphs: const <String>[
            '無終聲加 ㄹ 때、有終聲加 을 때、ㄹ 終聲直接加 때（살 때）。',
          ],
          items: <SoundItem>[
            _sound('시간이 있을 때 연락해 주세요.', '有空的時候請聯絡我。', SpeechTag.polite),
            _sound('한국에 올 때 꼭 연락해 주세요.', '來韓國的時候一定要聯絡我。', SpeechTag.polite),
            _sound('심심할 때 전화해 주세요.', '無聊的時候請打電話給我。', SpeechTag.polite),
            _sound('밖에 나갈 때 우산을 가져가세요.', '出門的時候請帶雨傘。', SpeechTag.honorific),
            _sound('자주 연락 못 해서 미안해요.', '對不起，沒常常聯絡你。', SpeechTag.polite),
          ],
        ),
        LessonCard.sound(
          id: 'u31:drill3',
          title: '練習・道別',
          paragraphs: const <String>[
            '「조심해서 가세요」＝路上小心。',
          ],
          items: <SoundItem>[
            _sound('그동안 정말 고마웠어요.', '這段時間真的謝謝你。', SpeechTag.polite),
            _sound('또 만나요.', '下次再見。', SpeechTag.polite),
            _sound('조심해서 가세요.', '路上小心。', SpeechTag.honorific),
            _sound('안녕히 가세요.', '請慢走。（對要離開的人說）', SpeechTag.honorific),
            _sound('안녕히 계세요.', '再見。（對留下的人說）', SpeechTag.honorific),
          ],
        ),
        LessonCard.sound(
          id: 'u31:dialog',
          title: '短對話：回國前的道別',
          paragraphs: const <String>[
            'A 明天要回台灣，B 是在韓國認識的朋友。最後 A 離開、B 留下。先照順序聽一遍，再遮住中文，試著只靠聲音聽懂。',
          ],
          items: <SoundItem>[
            _line('A', '저는 내일 대만에 돌아가요.', '我明天要回台灣了。', SpeechTag.polite),
            _line('B', '벌써요? 정말 아쉽네요.', '已經要回去了？真可惜呢。', SpeechTag.polite),
            _line('A', '그동안 정말 고마웠어요.', '這段時間真的謝謝你。', SpeechTag.polite),
            _line('B', '저도요. 대만에 갈 때 꼭 연락할게요.', '我也是。去台灣的時候一定會聯絡你。', SpeechTag.polite),
            _line('A', '네, 꼭 연락해 주세요.', '好，一定要聯絡我喔。', SpeechTag.polite),
            _line('B', '조심해서 가세요.', '路上小心。', SpeechTag.honorific),
            _line('A', '안녕히 계세요.', '再見。', SpeechTag.honorific),
            _line('B', '안녕히 가세요.', '請慢走。', SpeechTag.honorific),
          ],
        ),
      ],
      quizSeeds: _wordSeeds(const <String>[
        'word:오랜만이에요',
        'word:잘 지내요',
        'word:안녕히 가세요',
        'word:안녕히 계세요',
        'word:조심하세요',
        'word:보고 싶다',
        'word:고맙다',
        'word:미안하다',
        'word:또',
        'word:기억하다',
        'word:돌아가다',
      ]),
    );

/// 問名字（簡單版）：目前使用。
LessonCard _u1NameSimple() => LessonCard.sound(
          id: 'u1:name',
          title: '問名字、說名字',
          paragraphs: const <String>[
            '「제」是「저의」（我的）的縮短說法。名字有收尾音時用「이에요」：例如名字叫 민석，就說 민석이에요。',
            '問陌生人名字，最常用的客氣說法是「이름이 어떻게 되세요?」。裡面的「-세요」是尊敬說法，先整句記住。',
            '「이름이」的 이 是另一個助詞（標出「名字」是句子的主角），單元 6 會學；這幾句先整句記住就好。',
            '「이름이 어떻게 돼요?」也是禮貌說法，適合年紀相近的人。',
            '「이름이 뭐예요?」語氣比較直接，只對年紀相近、比較輕鬆的場合用。',
          ],
          items: <SoundItem>[
            _sound('이름이 어떻게 되세요?', '請問您叫什麼名字？（對陌生人最客氣）', SpeechTag.honorific),
            _sound('이름이 어떻게 돼요?', '你叫什麼名字？（日常禮貌）', SpeechTag.polite),
            _sound('이름이 뭐예요?', '你叫什麼名字？（直接，對年紀相近的人）', SpeechTag.polite),
            _sound('제 이름은 민수예요.', '我的名字是民秀。', SpeechTag.polite),
            _sound('저는 민수예요.', '我是民秀。', SpeechTag.polite),
          ],
        );

/// 問名字（四級完整版，含 성함）：尊敬說法開關打開時使用。
LessonCard _u1NameFourLevels() => LessonCard.sound(
          id: 'u1:name',
          title: '問名字：四種說法，四種對象',
          paragraphs: const <String>[
            '「제」是「저의」（我的）的縮短說法。名字有收尾音時，也一樣用「이에요」：例如名字叫 민석，就說 민석이에요。',
            '問「你叫什麼名字？」依對象有四種說法，由最尊敬到最直接：',
            '① 성함이 어떻게 되십니까?：最正式、最尊敬，用在職場、客人、面試。',
            '② 성함이 어떻게 되세요?：尊敬，用在長輩、年紀大很多的人、不熟的人。',
            '③ 이름이 어떻게 돼요?：日常禮貌，比 ④ 柔和，一般場合、同輩、年紀相近的人。',
            '④ 이름이 뭐예요?：也是 해요體，但語氣比較直接，只適合同輩或年紀相近的人。不要拿來問長輩或在職場問客人。',
            '提醒：「이름이 뭐예요?」不是「適合工作的敬語」。對長輩或工作場合請用 ① 或 ②。',
          ],
          items: <SoundItem>[
            _sound('성함이 어떻게 되십니까?', '請問您貴姓大名？（最正式・職場）', SpeechTag.formal),
            _sound('성함이 어떻게 되세요?', '請問您貴姓大名？（對長輩）', SpeechTag.honorific),
            _sound('이름이 어떻게 돼요?', '你叫什麼名字？（日常禮貌）', SpeechTag.polite),
            _sound('이름이 뭐예요?', '你叫什麼名字？（直接，只對同輩）', SpeechTag.polite),
            _sound('제 이름은 민수예요.', '我的名字是民秀。', SpeechTag.polite),
            _sound('저는 민수예요.', '我是民秀。', SpeechTag.polite),
          ],
        );
