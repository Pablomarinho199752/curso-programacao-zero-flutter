import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curso_programacao_zero/data/course_repository.dart';
import 'package:curso_programacao_zero/main.dart';
import 'package:curso_programacao_zero/screens/lesson_screen.dart';
import 'package:curso_programacao_zero/services/print_lab.dart';
import 'package:curso_programacao_zero/services/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('laboratório preserva ordem e rejeita código fora do escopo', () {
    expect(runPrintLab('print("Segundo")\nprint(\'Primeiro\')').output, [
      'Segundo',
      'Primeiro',
    ]);
    expect(
      runPrintLab('print("Oi")\nprint("Tchau"').error,
      contains('Linha 2'),
    );
    expect(runPrintLab('').ok, isFalse);
    expect(runPrintLab('import os').ok, isFalse);
    expect(runPrintLab('print("a"); print("b")').ok, isFalse);
    expect(runPrintLab(' print ( "Olá, mundo!" ) ').output, ['Olá, mundo!']);
  });

  test('conteúdo mantém um módulo, uma aula e três perguntas', () async {
    final modules = await const CourseRepository().loadModules();
    expect(modules.length, 1);
    expect(modules.single.number, 0);
    final lesson = modules.single.lessons.single;
    expect(lesson.quiz.length, 3);
    expect(runPrintLab(lesson.code).ok, isTrue);
    expect(runPrintLab(lesson.onboarding['brokenCode'] as String).ok, isFalse);
    expect(runPrintLab(lesson.onboarding['fixedCode'] as String).ok, isTrue);
  });

  test(
    'persiste respostas, tentativas, etapa e progresso; não herda domínio antigo',
    () async {
      SharedPreferences.setMockInitialValues({
        'lesson_status_lesson_0_1': 'mastered',
      });
      final store = ProgressStore();
      await store.initialize();
      expect(store.completionFor(['lesson_0_1']), 0);
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
      expect(restored.forLesson('lesson_0_1').answers['0'], 1);
      expect(restored.completionFor(['lesson_0_1']), 3 / 8);
    },
  );

  test('dados inválidos não impedem abertura', () async {
    SharedPreferences.setMockInitialValues({'onboarding_v1': '{bad'});
    final store = ProgressStore();
    await store.initialize();
    expect(store.recoveredData, isTrue);
    expect(store.completionFor(['lesson_0_1']), 0);
    await store.update('lesson_0_1', (p) => p.checks.add('welcome'));
    expect(store.saveError, isNull);
    final raw = (await SharedPreferences.getInstance()).getString(
      'onboarding_v1',
    );
    expect(jsonDecode(raw!), contains('lesson_0_1'));
  });

  Future<void> tap(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.drag(find.byType(ListView).first, const Offset(0, 10000));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 50,
    );
    await tester.pumpAndSettle();
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'percurso completo, pistas, retomada, mini projeto e revisão',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final lesson = (await tester.runAsync(
        () => const CourseRepository().loadModules(),
      ))!.single.lessons.single;
      final store = ProgressStore();
      await store.initialize();
      await tester.pumpWidget(
        MaterialApp(
          home: LessonScreen(lesson: lesson, progressStore: store),
        ),
      );
      await tester.pumpAndSettle();
      Finder next() =>
          find.widgetWithText(FilledButton, 'Concluir etapa e continuar');
      await tester.scrollUntilVisible(
        next(),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<FilledButton>(next()).onPressed, isNull);
      await tap(tester, find.byType(CheckboxListTile));
      await tap(tester, next());
      expect(store.forLesson(lesson.id).step, 1);
      await tap(tester, find.text('Alternativa em texto • sem internet'));
      await tap(tester, find.byType(CheckboxListTile));
      await tap(tester, next());
      await tap(tester, find.text('Executar no laboratório'));
      await tap(tester, next());
      await tester.enterText(find.byKey(const ValueKey('practice')), 'errado');
      await tap(tester, find.text('Conferir previsão'));
      expect(find.textContaining('Ainda não.'), findsOneWidget);
      expect(
        store.forLesson(lesson.id).checks.contains('practice_ok'),
        isFalse,
      );
      await tester.enterText(
        find.byKey(const ValueKey('practice')),
        lesson.practiceAnswer,
      );
      await tap(tester, find.text('Conferir previsão'));
      await tap(tester, next());
      await tester.enterText(
        find.byKey(const ValueKey('challenge')),
        'Segurar jarra\nLevantar\nDespejar até metade\nDevolver jarra',
      );
      await tap(tester, next());
      for (var i = 0; i < 3; i++) {
        await tap(tester, find.byType(CheckboxListTile).at(i));
      }
      await tap(tester, find.text('Executar no laboratório'));
      expect(find.textContaining('Linha 2:'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('correction')),
        lesson.onboarding['fixedCode'] as String,
      );
      await tap(tester, find.text('Executar no laboratório'));
      await tap(tester, next());
      await tester.enterText(
        find.byKey(const ValueKey('project')),
        'print("Pablo")\nprint("Quero criar um jogo")',
      );
      await tap(tester, find.text('Executar no laboratório'));
      for (var i = 0; i < 2; i++) {
        await tap(tester, find.byType(CheckboxListTile).at(i));
      }
      await tap(tester, next());
      expect(store.completionFor([lesson.id]), 7 / 8);
      for (var i = 0; i < 3; i++) {
        await tap(
          tester,
          find.text(lesson.quiz[i].options[lesson.quiz[i].correctIndex]),
        );
      }
      await tap(tester, find.text('Conferir as 3 respostas'));
      await tester.enterText(
        find.byKey(const ValueKey('reflection')),
        'Corrigi o parêntese que faltava na segunda linha.',
      );
      await tap(tester, find.text('Concluir Módulo 0'));
      expect(store.completionFor([lesson.id]), 1);
      expect(tester.takeException(), isNull);
      final restored = ProgressStore();
      await restored.initialize();
      expect(restored.forLesson(lesson.id).step, 7);
      expect(
        restored.forLesson(lesson.id).drafts['project'],
        contains('Pablo'),
      );
      // Reabrir a prática e editar invalida a conclusão, sem apagar rascunhos.
      await tap(tester, find.text('4. Prática'));
      await tester.enterText(
        find.byKey(const ValueKey('practice')),
        'outra resposta',
      );
      expect(store.completionFor([lesson.id]), 3 / 8);
      expect(store.forLesson(lesson.id).drafts['project'], contains('Pablo'));
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  testWidgets(
    'home reage ao progresso e usa navegação desktop',
    (tester) async {
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
      await store.update('lesson_0_1', (p) => p.completed.addAll([0, 1, 2, 3]));
      await tester.pumpAndSettle();
      expect(find.text('50% das etapas concluídas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
