enum SkillStatus { notStarted, inProgress, mastered }

extension SkillStatusX on SkillStatus {
  String get storageValue => switch (this) {
    SkillStatus.notStarted => 'not_started',
    SkillStatus.inProgress => 'in_progress',
    SkillStatus.mastered => 'mastered',
  };

  String get label => switch (this) {
    SkillStatus.notStarted => 'Ainda não começou',
    SkillStatus.inProgress => 'Em desenvolvimento',
    SkillStatus.mastered => 'Percurso concluído',
  };

  String get emoji => switch (this) {
    SkillStatus.notStarted => '🔴',
    SkillStatus.inProgress => '🟡',
    SkillStatus.mastered => '🟢',
  };

  static SkillStatus fromStorage(String? value) => switch (value) {
    'in_progress' => SkillStatus.inProgress,
    'mastered' => SkillStatus.mastered,
    _ => SkillStatus.notStarted,
  };
}

class CourseModule {
  const CourseModule({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String id;
  final int number;
  final String title;
  final String description;
  final List<CourseLesson> lessons;

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
    id: json['id'] as String,
    number: json['number'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    lessons: (json['lessons'] as List<dynamic>)
        .map((e) => CourseLesson.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.number,
    required this.title,
    required this.objective,
    required this.theory,
    required this.code,
    required this.practicePrompt,
    required this.practiceAnswer,
    required this.challenge,
    required this.review,
    required this.videoUrl,
    required this.quiz,
    required this.onboarding,
  });

  final String id;
  final String number;
  final String title;
  final String objective;
  final List<String> theory;
  final String code;
  final String practicePrompt;
  final String practiceAnswer;
  final String challenge;
  final List<String> review;
  final String videoUrl;
  final List<QuizQuestion> quiz;
  final Map<String, dynamic> onboarding;

  factory CourseLesson.fromJson(Map<String, dynamic> json) => CourseLesson(
    id: json['id'] as String,
    onboarding: json['onboarding'] as Map<String, dynamic>,
    number: json['number'] as String,
    title: json['title'] as String,
    objective: json['objective'] as String,
    theory: (json['theory'] as List<dynamic>).cast<String>(),
    code: json['code'] as String,
    practicePrompt: json['practicePrompt'] as String,
    practiceAnswer: json['practiceAnswer'] as String,
    challenge: json['challenge'] as String,
    review: (json['review'] as List<dynamic>).cast<String>(),
    videoUrl: json['videoUrl'] as String,
    quiz: (json['quiz'] as List<dynamic>)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    question: json['question'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
    correctIndex: json['correctIndex'] as int,
    explanation: json['explanation'] as String,
  );
}
