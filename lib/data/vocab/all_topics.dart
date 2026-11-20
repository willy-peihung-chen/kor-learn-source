import '../content_models.dart';
import 'topic_adjectives.dart';
import 'topic_animals.dart';
import 'topic_body.dart';
import 'topic_clothes.dart';
import 'topic_colors.dart';
import 'topic_concepts.dart';
import 'topic_family.dart';
import 'topic_feelings.dart';
import 'topic_food.dart';
import 'topic_fruits.dart';
import 'topic_function.dart';
import 'topic_greetings.dart';
import 'topic_hobbies.dart';
import 'topic_home.dart';
import 'topic_nature.dart';
import 'topic_numbers.dart';
import 'topic_people.dart';
import 'topic_places.dart';
import 'topic_restaurant.dart';
import 'topic_school.dart';
import 'topic_shopping.dart';
import 'topic_tech.dart';
import 'topic_time.dart';
import 'topic_transport.dart';
import 'topic_verbs.dart';
import 'topic_work.dart';

/// 所有單字主題（順序即為 App 內顯示順序）。
const List<WordTopic> allWordTopics = <WordTopic>[
  topicGreetings,
  topicNumbers,
  topicTime,
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
  topicWork,
  topicNature,
  topicAnimals,
  topicColors,
  topicHobbies,
  topicTech,
  topicFeelings,
  topicVerbs,
  topicAdjectives,
  topicFunction,
  topicConcepts,
];
