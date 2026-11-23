import '../content_models.dart';
import 'topic_adjectives_judge.dart';
import 'topic_adjectives_person.dart';
import 'topic_adjectives_sense.dart';
import 'topic_adjectives_size.dart';
import 'topic_animals.dart';
import 'topic_body.dart';
import 'topic_clothes.dart';
import 'topic_colors.dart';
import 'topic_concepts_mind.dart';
import 'topic_concepts_thing.dart';
import 'topic_family.dart';
import 'topic_feelings.dart';
import 'topic_food.dart';
import 'topic_fruits.dart';
import 'topic_function_conj.dart';
import 'topic_function_degree.dart';
import 'topic_function_manner.dart';
import 'topic_function_pron.dart';
import 'topic_function_time.dart';
import 'topic_greetings.dart';
import 'topic_hobbies.dart';
import 'topic_home.dart';
import 'topic_language.dart';
import 'topic_nature.dart';
import 'topic_numbers.dart';
import 'topic_people.dart';
import 'topic_places.dart';
import 'topic_polite.dart';
import 'topic_restaurant.dart';
import 'topic_school.dart';
import 'topic_shopping.dart';
import 'topic_tech.dart';
import 'topic_time_calendar.dart';
import 'topic_time_day.dart';
import 'topic_transport.dart';
import 'topic_verbs_eat.dart';
import 'topic_verbs_handle.dart';
import 'topic_verbs_life.dart';
import 'topic_verbs_make.dart';
import 'topic_verbs_mind.dart';
import 'topic_verbs_move.dart';
import 'topic_verbs_social.dart';
import 'topic_verbs_state.dart';
import 'topic_work.dart';

/// 所有單字主題（順序即為 App 內顯示順序）。
const List<WordTopic> allWordTopics = <WordTopic>[
  topicGreetings,
  topicPolite,
  topicNumbers,
  topicTimeDay,
  topicTimeCalendar,
  topicPeople,
  topicFamily,
  topicBody,
  topicFood,
  topicFruits,
  topicRestaurant,
  topicShopping,
  topicClothes,
  topicHome,
  topicPlaces,
  topicTransport,
  topicSchool,
  topicLanguage,
  topicWork,
  topicNature,
  topicAnimals,
  topicColors,
  topicHobbies,
  topicTech,
  topicFeelings,
  topicVerbsMove,
  topicVerbsEat,
  topicVerbsLife,
  topicVerbsMind,
  topicVerbsSocial,
  topicVerbsHandle,
  topicVerbsMake,
  topicVerbsState,
  topicAdjectivesSize,
  topicAdjectivesSense,
  topicAdjectivesPerson,
  topicAdjectivesJudge,
  topicFunctionPron,
  topicFunctionDegree,
  topicFunctionTime,
  topicFunctionManner,
  topicFunctionConj,
  topicConceptsThing,
  topicConceptsMind,
];
