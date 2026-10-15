import 'dart:convert';

import 'package:curso_programacao_zero/data/course_repository.dart';
import 'package:curso_programacao_zero/main.dart';
import 'package:curso_programacao_zero/screens/generic_module_lesson_screen.dart';
import 'package:curso_programacao_zero/screens/lesson_screen.dart';
import 'package:curso_programacao_zero/services/basics_lab.dart';
import 'package:curso_programacao_zero/services/print_lab.dart';
import 'package:curso_programacao_zero/services/progress_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('laboratório inicial preserva ordem e rejeita código fora do escopo', () {
    expect(runPrintLab('print("Segundo")\nprint(\'Primeiro\')').output, [
      'Segundo',
      'Primeiro',
    ]);
    expect(runPrintLab('print("Oi")\nprint("Tchau"').error, contains('Linha 2'));
    expect(runPrintLab('').ok, isFalse);
    expect(runPrintLab('import os').ok, isFalse);
  });

  test('laboratório do Módulo 1 aceita variáveis sem executar Python arbitrário', () {
    final result = runBasicsLab(
      'apelido = "Pythonista"\nprojetos = 2\nmeta = 7.5\n'
      'print(apelido)\nprint(projetos)\nprint(meta)',
    );
    expect(result.ok, isTrue);
    expect(result.output, ['Pythonista', '2', '7.5']);
    expect(result.variables.length, 3);
    expect(runBasicsLab('import os').ok, isFalse);
    expect(runBasicsLab('x = 1 + 2').ok, isFalse);
  });

  test('conteúdo carrega os 13 módulos com aula, projeto e revisão', () async {
    final modules = await const CourseRepository().loadModules();
    expect(modules.length, 13);
    expect(modules.first.number, 0);
    expect(modules.last.number, 12);
    expect(modules.every((module) => module.project.isNotEmpty), isTrue);
    expect(modules.every((module) => module.lessons.isNotEmpty), isTrue);
    expect(modules.every((module) => module.lessons.first.quiz.length == 3), isTrue);
    expect(
      modules.every((module) => module.lessons.first.review.isNotEmpty),
      isTrue,
    );

    final lesson0 = modules.first.lessons.single;
    expect(runPrintLab(lesson0.code).ok, isTrue);
    expect(runPrintLab(lesson0.onboarding['brokenCode'] as String).ok, isFalse);
    expect(runPrintLab(lesson0.onboarding['fixedCode'] as String).ok, isTrue);

    final lesson1 = modules[1].lessons.single;
    expect(lesson1.number, '1.1');
    expect(runBasicsLab(lesson1.code).ok, isTrue);
    expect(runBasicsLab(lesson1.onboarding['fixedCode'] as String).ok, isTrue);

    for (final module in modules.skip(2)) {
      final lesson = module.lessons.single;
      expect(lesson.onboarding['videoTitle'], isNotEmpty);
      expect(lesson.onboarding['videoRenderId'], isNotEmpty);
      expect(lesson.onboarding['projectPrompt'], isNotEmpty);
      expect(lesson.onboarding['reflectionPrompt'], isNotEmpty);
      expect(lesson.onboarding['evidencePrompt'], isNotEmpty);
    }
  });

  test('cadeado depende de domínio comprovado e persiste no aparelho', () async {
    final modules = await const CourseRepository().loadModules();
    final store = ProgressStore();
    await store.initialize();

    expect(store.isModuleUnlocked(modules, 0), isTrue);
    expect(store.isModuleUnlocked(modules, 1), isFalse);

    await store.setModuleMastered('module_0', true);
    expect(store.isModuleUnlocked(modules, 1), isTrue);
    expect(store.isModuleUnlocked(modules, 2), isFalse);

    await store.setModuleMastered('module_1', true);
    expect(store.isModuleUnlocked(modules, 2), isTrue);
    expect(store.isModuleUnlocked(modules, 3), isFalse);

    final restored = ProgressStore();
    await restored.initialize();
    expect(restored.isModuleMastered('module_0'), isTrue);
    expect(restored.isModuleMastered('module_1'), isTrue);
    expect(restored.isModuleUnlocked(modules, 2), isTrue);
  });

  test('persiste respostas, tentativas e progresso; ignora domínio legado', () async {
    SharedPreferences.setMockInitialValues({
      'lesson_status_lesson_0_1': 'mastered',
    });
    final store = ProgressStore();
    await store.initialize();
    expect(store.completionFor(['lesson_0_1']), 0);
    expect(store.isModuleMastered('module_0'), isFalse);

    await store.update('lesson_0_1', (p) {
      p.step = 3;
      p.completed.addAll([0, 1, 2]);
      p.drafts['practice'] = 'rascunho';
      p.answers['0'] = 1;
      p.attempts['practice'] = 2;
    });

    final restored = ProgressStore();
    await restored.initialize();
    expect(restored.forLesson('lesson_0_1').drafts['practice'], 'rascunho');
    expect(restored.forLesson('lesson_0_1').step, 3);
    expect(restored.forLesson('lesson_0_1').attempts['practice'], 2);
    expect(restored.completionFor(['lesson_0_1']), 3 / 8);
  });

  test('dados inválidos não impedem abertura e podem ser salvos novamente', () async {
    SharedPreferences.setMockInitialValues({'onboarding_v1': '{bad'});
    final store = ProgressStore();
    await store.initialize();
    expect(store.recoveredData, isTrue);
    await store.update('lesson_0_1', (p) => p.checks.add('welcome'));
    expect(store.saveError, isNull);
    final raw = (await SharedPreferences.getInstance()).getString('onboarding_v1');
    expect(jsonDecode(raw!), contains('lesson_0_1'));
  });

  testWidgets('Módulo 0 continua com percurso de oito etapas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final modules = (await tester.runAsync(
      () => const CourseRepository().loadModules(),
    ))!;
    final store = ProgressStore();
    await store.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: LessonScreen(
          lesson: modules.first.lessons.single,
          progressStore: store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('0 de 8'), findsOneWidget);
    expect(find.text('1. Explicação curta'), findsOneWidget);
    expect(find.text('8. Revisão'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('módulo avançado abre percurso completo sem overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final modules = (await tester.runAsync(
      () => const CourseRepository().loadModules(),
    ))!;
    final store = ProgressStore();
    await store.initialize();
    final lesson = modules[2].lessons.single;

    await tester.pumpWidget(
      MaterialApp(
        home: GenericModuleLessonScreen(
          lesson: lesson,
          progressStore: store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(lesson.title), findsOneWidget);
    expect(find.text('1. Explicação curta'), findsOneWidget);
    expect(find.text('8. Revisão'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home reage ao progresso e usa navegação desktop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = ProgressStore();
    await store.initialize();
    final modules = (await tester.runAsync(
      () => const CourseRepository().loadModules(),
    ))!;

    await tester.pumpWidget(
      MaterialApp(
        home: CourseShell(modules: modules, progressStore: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);

    await store.update(
      'lesson_0_1',
      (p) => p.completed.addAll([0, 1, 2, 3]),
    );
    await tester.pumpAndSettle();
    expect(find.text('50% das etapas concluídas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
