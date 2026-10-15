import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:curso_programacao_zero/services/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('salva e recupera a última aula e etapa visitada', () async {
    final first = ProgressStore();
    await first.initialize();
    await first.update('lesson_2_1', (progress) {
      progress.step = 4;
      progress.completed.addAll({0, 1, 2, 3});
    });

    final second = ProgressStore();
    await second.initialize();

    expect(second.lastLessonId, 'lesson_2_1');
    expect(second.lastStep, 4);
    expect(second.forLesson('lesson_2_1').completed, containsAll({0, 1, 2, 3}));
  });

  test('mescla conclusão dos dois aparelhos sem regredir', () async {
    final store = ProgressStore();
    await store.initialize();
    await store.update('lesson_3_1', (progress) {
      progress.step = 3;
      progress.completed.addAll({0, 1, 2});
      progress.checks.add('practice_ok');
      progress.attempts['practice'] = 2;
      progress.drafts['challenge'] = 'rascunho local';
    });

    final localUpdated = store.forLesson('lesson_3_1').updatedAtMs;
    await store.mergeCloudState({
      'schemaVersion': 2,
      'updatedAtMs': localUpdated + 1000,
      'lastLessonId': 'lesson_3_1',
      'lastStep': 5,
      'masteredModules': ['module_0'],
      'lessons': {
        'lesson_3_1': {
          'step': 5,
          'updatedAtMs': localUpdated + 1000,
          'completed': [0, 1, 2, 3, 4],
          'drafts': {'challenge': 'rascunho mais novo da nuvem'},
          'checks': ['challenge_ok'],
          'attempts': {'practice': 1, 'challenge': 3},
          'answers': <String, int>{},
        },
      },
    });

    final merged = store.forLesson('lesson_3_1');
    expect(merged.completed, containsAll({0, 1, 2, 3, 4}));
    expect(merged.checks, containsAll({'practice_ok', 'challenge_ok'}));
    expect(merged.attempts['practice'], 2);
    expect(merged.attempts['challenge'], 3);
    expect(merged.drafts['challenge'], 'rascunho mais novo da nuvem');
    expect(store.lastStep, 5);
    expect(store.isModuleMastered('module_0'), isTrue);
  });

  test('rascunho local mais novo vence rascunho antigo da nuvem', () async {
    final store = ProgressStore();
    await store.initialize();
    await store.update('lesson_4_1', (progress) {
      progress.drafts['project'] = 'versão local nova';
    });

    final localUpdated = store.forLesson('lesson_4_1').updatedAtMs;
    await store.mergeCloudState({
      'schemaVersion': 2,
      'updatedAtMs': localUpdated - 1000,
      'lastLessonId': 'lesson_4_1',
      'lastStep': 2,
      'masteredModules': <String>[],
      'lessons': {
        'lesson_4_1': {
          'step': 1,
          'updatedAtMs': localUpdated - 1000,
          'completed': [0],
          'drafts': {'project': 'versão remota antiga'},
          'checks': <String>[],
          'attempts': <String, int>{},
          'answers': <String, int>{},
        },
      },
    });

    expect(store.forLesson('lesson_4_1').drafts['project'], 'versão local nova');
  });
}
