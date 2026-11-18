import '../content_models.dart';
import 'lesson_basic_sentences.dart';
import 'lesson_communication.dart';
import 'lesson_connectors.dart';
import 'lesson_how_korean_works.dart';
import 'lesson_particles1.dart';
import 'lesson_particles2.dart';
import 'lesson_requests.dart';
import 'lesson_speech_levels.dart';
import 'lesson_tense_ability.dart';

/// 所有文法課程（順序即為學習順序）。
const List<GrammarLessonData> allGrammarLessons = <GrammarLessonData>[
  grammarHowKoreanWorks,
  grammarParticles1,
  grammarParticles2,
  grammarBasicSentences,
  grammarRequests,
  grammarSpeechLevels,
  grammarTenseAbility,
  grammarConnectors,
  grammarCommunication,
  grammarBanmal,
];
