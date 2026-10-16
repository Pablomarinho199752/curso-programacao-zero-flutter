import 'package:flutter_test/flutter_test.dart';

import 'package:curso_programacao_zero/models/course_models.dart';
import 'package:curso_programacao_zero/services/learning_coach_service.dart';
import 'package:curso_programacao_zero/services/progress_store.dart';
import 'package:curso_programacao_zero/services/python_lab_service.dart';

CourseLesson lesson(String id) => CourseLesson(
      id: id,
      number: '1.1',
      title: 'Teste',
      objective: 'Aprender testando.',
      theory: const ['Uma ideia por vez.'],
      code: 'print("oi")',
      practicePrompt: 'Preveja a saída.',
      practiceAnswer: 'oi',
      challenge: 'Crie uma solução.',
      review: const ['Explique o conceito.'],
      videoUrl: '',
      quiz: const [],
      onboarding: const {
        'brokenCode': 'print(nome)',
        'projectStarter': 'nome = "Ada"\nprint(nome)',
        'correctionPrompt': 'Encontre e corrija o problema.',
        'projectPrompt': 'Monte um mini projeto.',
      },
    );

void main() {
  const coach = LearningCoachService();

  test('usa os rascunhos corretos para desafio, correção e projeto', () {
    final progress = LessonProgress();
    expect(coach.draftKey(4), 'challenge');
    expect(coach.draftKey(5), 'correction');
    expect(coach.draftKey(6), 'project');

    expect(coach.starterCode(lesson('lesson_2_1'), progress, 5), 'print(nome)');
    progress.drafts['correction'] = 'nome = "Ana"\nprint(nome)';
    expect(
      coach.starterCode(lesson('lesson_2_1'), progress, 5),
      'nome = "Ana"\nprint(nome)',
    );
  });

  test('gera pistas progressivas a partir do erro real do Python', () {
    const result = PythonExecutionResult(
      ok: false,
      stdout: '',
      stderr: '',
      error: 'invalid syntax',
      errorType: 'SyntaxError',
      errorLine: 3,
      durationMs: 10,
    );

    final first = coach.hintsFor(
      result: result,
      attempt: 1,
      lesson: lesson('lesson_2_1'),
      step: 4,
    );
    expect(first.join(' '), contains('linha 3'));
    expect(first.join(' '), contains('parênteses'));

    final third = coach.hintsFor(
      result: result,
      attempt: 3,
      lesson: lesson('lesson_2_1'),
      step: 4,
    );
    expect(third.join(' '), contains('Isole o problema'));
    expect(third.join(' '), contains('print()'));
  });

  test('agenda revisões com intervalos crescentes', () {
    final progress = LessonProgress()
      ..completed.addAll(List<int>.generate(8, (index) => index));
    const now = 10 * Duration.millisecondsPerDay;
    progress.updatedAtMs = now - (2 * Duration.millisecondsPerDay);

    expect(coach.reviewIntervalDays(progress), 1);
    expect(coach.reviewDue(progress, nowMs: now), isTrue);

    progress.attempts['spaced_review_count'] = 1;
    progress.attempts['spaced_review_last_ms'] = now;
    expect(coach.reviewIntervalDays(progress), 3);
    expect(coach.reviewDue(progress, nowMs: now), isFalse);
  });

  test('edições da aula não deslocam revisões já registradas', () {
    final progress = LessonProgress()
      ..completed.addAll(List<int>.generate(8, (index) => index));
    const lastReview = 20 * Duration.millisecondsPerDay;
    const now = lastReview + (4 * Duration.millisecondsPerDay);

    progress.attempts['spaced_review_count'] = 1;
    progress.attempts['spaced_review_last_ms'] = lastReview;
    progress.updatedAtMs = now;

    expect(coach.reviewAnchorMs(progress), lastReview);
    expect(coach.reviewIntervalDays(progress), 3);
    expect(coach.reviewDue(progress, nowMs: now), isTrue);
  });

  test('oferece projetos cumulativos apenas nos marcos planejados', () {
    expect(coach.hasCumulativeProject(lesson('lesson_3_1')), isTrue);
    expect(coach.cumulativeProjectPrompt(lesson('lesson_3_1')), isNotNull);
    expect(coach.hasCumulativeProject(lesson('lesson_4_1')), isFalse);
    expect(coach.cumulativeProjectPrompt(lesson('lesson_4_1')), isNull);
    expect(coach.hasCumulativeProject(lesson('lesson_12_1')), isTrue);
  });
}
