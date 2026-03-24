class RecommendedCharacter {
  const RecommendedCharacter({
    required this.imagePath,
    required this.name,
    required this.danceType,
    required this.backgroundIntro,
    required this.presetQuestions,
  });

  final String imagePath;
  final String name;
  final String danceType;
  final String backgroundIntro;
  final List<String> presetQuestions;
}

const List<RecommendedCharacter> kRecommendedCharacters = <RecommendedCharacter>[
  RecommendedCharacter(
    imagePath: 'assets/robot_dance_1.png',
    name: 'Aeron',
    danceType: 'Street Dance',
    backgroundIntro: 'Born in underground battle arenas, Aeron teaches explosive combos and musicality.',
    presetQuestions: <String>[
      'How do I start a simple freestyle combo for beginners?',
      'What drills improve my footwork and balance?',
      'How can I read the beat better in a battle?',
      'Give me a five-minute warm-up for street dance.',
    ],
  ),
  RecommendedCharacter(
    imagePath: 'assets/robot_dance_2.png',
    name: 'Nyra',
    danceType: 'Disco',
    backgroundIntro: 'Inspired by classic dance floors, Nyra builds groove, rhythm, and stage confidence.',
    presetQuestions: <String>[
      'What is the first disco step I should learn?',
      'How do I keep groove on a slow disco track?',
      'Suggest a mirror practice routine for disco attitude.',
      'How do I avoid looking stiff when dancing disco?',
    ],
  ),
  RecommendedCharacter(
    imagePath: 'assets/robot_dance_3.png',
    name: 'Kaito',
    danceType: 'Jazz',
    backgroundIntro: 'Trained in theatrical choreography, Kaito focuses on lines, control, and expression.',
    presetQuestions: <String>[
      'What are essential jazz isolations for beginners?',
      'How do I improve my extensions and lines?',
      'Give me an across-the-floor combo for jazz technique.',
      'How should I use my hands expressively in jazz?',
    ],
  ),
  RecommendedCharacter(
    imagePath: 'assets/robot_dance_4.png',
    name: 'Lumia',
    danceType: 'Street Dance',
    backgroundIntro: 'Lumia is a freestyle mentor for footwork, bounce, and battle-ready transitions.',
    presetQuestions: <String>[
      'Explain top rock versus footwork—which should I drill first?',
      'How do I train faster transitions between moves?',
      'What is a good practice plan for a three-minute freestyle?',
      'How do I stay relaxed while keeping sharp hits?',
    ],
  ),
  RecommendedCharacter(
    imagePath: 'assets/robot_dance_5.png',
    name: 'Zeke',
    danceType: 'Elf Dance',
    backgroundIntro: 'Zeke blends fantasy flow with agile turns to create an ethereal dance language.',
    presetQuestions: <String>[
      'How do I make turns feel light and floating?',
      'What arm pathways fit a fantasy lyrical line?',
      'Give me a short phrase that mixes spins and soft landings.',
      'How do I build stamina for long ethereal sequences?',
    ],
  ),
];
