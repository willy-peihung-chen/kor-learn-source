import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/labels.dart';
import '../data/quiz_types.dart';
import '../state/app_state.dart';
import '../util/korean_runs.dart';
import 'app_scope.dart';
import 'speak_button.dart';
import 'speakable_text.dart';
import 'theme.dart';
import 'widgets.dart';

/// 「測驗」頁籤：混合測驗、主題單字測驗、文法填空與錯題本。
class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  String _topicId = Catalog.topics.first.id;

  /// 文法測驗的範圍：null 代表全部文法課程。
  String? _grammarLessonId;

  void _open(String title, List<QuizQuestion> questions) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizSessionPage(title: title, questions: questions),
      ),
    );
  }

  List<String> _grammarIds() {
    final lessons = _grammarLessonId == null
        ? Catalog.grammarLessons
        : Catalog.grammarLessons.where((l) => l.id == _grammarLessonId);
    return <String>[
      for (final lesson in lessons)
        for (final point in lesson.points)
          for (var i = 0; i < point.examples.length; i++) point.exampleId(i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final mistakes = state.mistakeSeeds;

    return PageBody(
      children: <Widget>[
        Text('測驗', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('混合測驗', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '從韓文字母、音節，以及你已經複習過的單字、已學過的文法中隨機抽 10 題。'
                '（已複習單字 ${state.learnedWordCount} 個）',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _open(
                  '混合測驗',
                  state.quiz.mixed(
                    count: 10,
                    wordIds: state.learnedWordIds,
                    grammarExampleIds: state.learnedGrammarExampleIds,
                  ),
                ),
                child: const Text('開始測驗'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('主題單字測驗', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '選一個主題，從裡面的單字抽 10 題（不需要先複習過）。',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: '主題',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _topicId,
                    isExpanded: true,
                    isDense: true,
                    items: <DropdownMenuItem<String>>[
                      for (final topic in Catalog.topics)
                        DropdownMenuItem<String>(
                          value: topic.id,
                          child: Text(topic.title),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _topicId = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _open(
                  '主題單字：${Catalog.topicById(_topicId)?.title ?? ''}',
                  state.quiz.topicQuiz(_topicId, count: 10),
                ),
                child: const Text('開始主題測驗'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('文法填空', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '看中文意思，選出句子空格該填的助詞或語尾。',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: '範圍',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _grammarLessonId,
                    isExpanded: true,
                    isDense: true,
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('全部文法課程'),
                      ),
                      for (final lesson in Catalog.grammarLessons)
                        DropdownMenuItem<String?>(
                          value: lesson.id,
                          child: Text(lesson.title),
                        ),
                    ],
                    onChanged: (value) => setState(() => _grammarLessonId = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _open(
                  '文法填空',
                  state.quiz.grammarQuiz(_grammarIds(), count: 10),
                ),
                child: const Text('開始文法測驗'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('錯題本（${mistakes.length} 題）', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                mistakes.isEmpty
                    ? '目前沒有錯題。答錯的題目會自動收進來；之後答對，就會移出錯題本。'
                    : '最近一次答錯的題目。重新答對後會自動移出。',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              if (mistakes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _open(
                    '錯題練習',
                    state.quiz.buildAll(mistakes.take(10)),
                  ),
                  child: Text(
                    mistakes.length > 10 ? '練習錯題（最近 10 題）' : '練習錯題',
                  ),
                ),
                const SizedBox(height: 12),
                for (final seed in mistakes.take(20))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            itemLabel(seed.itemId),
                            style: hangulStyle(16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          seed.kind.label,
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 一組測驗的作答畫面（混合測驗、課後測驗、錯題練習共用）。
class QuizSessionPage extends StatefulWidget {
  const QuizSessionPage({
    super.key,
    required this.title,
    required this.questions,
  });

  final String title;
  final List<QuizQuestion> questions;

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  int _index = 0;
  int? _selected;
  int _correctCount = 0;
  bool _finished = false;
  final List<QuizQuestion> _wrong = <QuizQuestion>[];

  void _choose(AppState state, int option) {
    if (_selected != null) {
      return;
    }
    final question = widget.questions[_index];
    final correct = state.recordAnswer(question, option);
    setState(() {
      _selected = option;
      if (correct) {
        _correctCount++;
      } else {
        _wrong.add(question);
      }
    });
  }

  void _next(AppState state) {
    if (_index + 1 >= widget.questions.length) {
      state.finishQuiz(widget.title, _correctCount, widget.questions.length);
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  void _retryWrong(AppState state) {
    final seeds = _wrong.map((q) => q.seed).toList();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuizSessionPage(
          title: '錯題重練',
          questions: state.quiz.buildAll(seeds),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: widget.questions.isEmpty
            ? const PageBody(
                children: <Widget>[Text('目前沒有可出的題目。')],
              )
            : _finished
                ? _buildResult(context, state)
                : _buildQuestion(context, state),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final question = widget.questions[_index];
    final answered = _selected != null;
    final isLast = _index + 1 >= widget.questions.length;

    return Column(
      children: <Widget>[
        LinearProgressIndicator(
          value: (_index + (answered ? 1 : 0)) / widget.questions.length,
        ),
        Expanded(
          child: PageBody(
            children: <Widget>[
              Text(
                '第 ${_index + 1} / ${widget.questions.length} 題・${question.kind.label}',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 12),
              SpeakableText(question.prompt, style: theme.textTheme.titleMedium),
              if (question.kind == QuizKind.listenSyllable &&
                  question.speakText != null) ...<Widget>[
                const SizedBox(height: 16),
                Center(
                  child: IconButton.filledTonal(
                    iconSize: 48,
                    tooltip: '播放聲音',
                    icon: const Icon(Icons.volume_up_outlined),
                    onPressed: () => speakText(context, question.speakText!),
                  ),
                ),
              ],
              if (question.stimulus != null) ...<Widget>[
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          question.stimulus!,
                          style: hangulStyle(
                            question.kind == QuizKind.grammarCloze ? 28 : 64,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // 只有「單字→中文」題的題幹是韓文單字，才放朗讀按鈕。
                      if (question.kind == QuizKind.wordMeaning) ...<Widget>[
                        const SizedBox(width: 4),
                        SpeakButton(text: question.stimulus!, tooltip: '朗讀單字'),
                      ],
                      // 文法填空：一開始就能聽整句（朗讀的是完整句子）。
                      if (question.kind == QuizKind.grammarCloze &&
                          question.speakText != null) ...<Widget>[
                        const SizedBox(width: 4),
                        SpeakButton(
                          text: question.speakText!,
                          tooltip: '朗讀例句',
                          iconSize: 24,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              for (var i = 0; i < question.options.length; i++)
                _optionTile(context, state, question, i),
              if (answered) ...<Widget>[
                const SizedBox(height: 4),
                SectionCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        question.isCorrect(_selected!)
                            ? '答對了'
                            : '答錯了，正確答案：${question.correctAnswer}',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(question.explanation, style: theme.textTheme.bodyMedium),
                      if (question.speakText != null)
                        Row(
                          children: <Widget>[
                            Text(
                              question.kind == QuizKind.listenSyllable
                                  ? '再聽一次'
                                  : '朗讀例句',
                              style: theme.textTheme.bodySmall?.copyWith(color: muted),
                            ),
                            SpeakButton(
                              text: question.speakText!,
                              tooltip: '朗讀例句',
                              iconSize: 22,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _next(state),
                  child: Text(isLast ? '查看結果' : '下一題'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _optionTile(
    BuildContext context,
    AppState state,
    QuizQuestion question,
    int i,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final answered = _selected != null;
    final isCorrect = i == question.correctIndex;
    final isChosen = _selected == i;

    var background = Colors.white;
    var border = scheme.outlineVariant;
    IconData? icon;
    if (answered && isCorrect) {
      background = scheme.primaryContainer;
      border = scheme.primary;
      icon = Icons.check_circle_outline;
    } else if (answered && isChosen) {
      background = scheme.errorContainer;
      border = scheme.error;
      icon = Icons.cancel_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: answered ? null : () => _choose(state, i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(question.options[i], style: hangulStyle(18))),
                // 選項裡有韓文就能點喇叭聽（不會選到這個選項）。
                // 聽音辨字題不加，否則可以逐一比對聲音，等於直接給答案。
                if (question.kind != QuizKind.listenSyllable &&
                    _hasKorean(question.options[i]))
                  SpeakButton(
                    text: question.options[i],
                    tooltip: '朗讀選項',
                    iconSize: 22,
                  ),
                if (icon != null) Icon(icon),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final total = widget.questions.length;
    final percent = (_correctCount * 100 / total).round();

    return PageBody(
      children: <Widget>[
        SectionCard(
          child: Column(
            children: <Widget>[
              Text('測驗結果', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('$_correctCount / $total', style: theme.textTheme.displaySmall),
              const SizedBox(height: 4),
              Text(
                '正確率 $percent%',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_wrong.isNotEmpty)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('答錯的題目', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final q in _wrong)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(q.prompt, style: theme.textTheme.bodyMedium),
                        Text(
                          '正確答案：${q.correctAnswer}',
                          style: hangulStyle(16, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _retryWrong(state),
                  child: const Text('再練答錯的題目'),
                ),
              ],
            ),
          ),
        if (_wrong.isNotEmpty) const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('完成'),
        ),
      ],
    );
  }
}

bool _hasKorean(String text) => splitKoreanRuns(text).any((r) => r.isKorean);
