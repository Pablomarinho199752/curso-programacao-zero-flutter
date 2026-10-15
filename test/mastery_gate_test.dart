import 'package:curso_programacao_zero/data/course_repository.dart';
import 'package:curso_programacao_zero/screens/modules_screen.dart';
import 'package:curso_programacao_zero/services/mastery_gate.dart';
import 'package:curso_programacao_zero/services/progress_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('desafio de domínio exige previsão, correção, criação e explicação', () {
    expect(module0PredictionIsCorrect(1), isTrue);
    expect(module0PredictionIsCorrect(0), isFalse);

    expect(
      evaluateModule0Debugging('print("Planejar")\nprint("Executar")').passed,
      isTrue,
    );
    expect(
      evaluateModule0Debugging('print("Planejar")\nprint("Executar"').passed,
      isFalse,
    );

    expect(
      evaluateModule0Creation('print("Meu app")\nprint("Primeira versão")').passed,
      isTrue,
    );
    expect(
      evaluateModule0Creation('print("Olá, mundo!")\nprint("Outra")').passed,
      isFalse,
    );

    expect(
      evaluateModule0Explanation(
        'O código são as instruções que eu escrevo e a saída é o resultado que aparece na tela.',
      ).passed,
      isTrue,
    );
    expect(evaluateModule0Explanation('São coisas diferentes.').passed, isFalse);
  });

  testWidgets('8/8 oferece desafio e o desafio libera o Módulo 1', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final modules = (await tester.runAsync(
      () => const CourseRepository().loadModules(),
    ))!;
    final store = ProgressStore();
    await store.initialize();
    final lesson0 = modules.first.lessons.single;
    await store.update(
      lesson0.id,
      (progress) => progress.completed.addAll(List.generate(8, (index) => index)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ModulesScreen(modules: modules, progressStore: store),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> scrollTo(Finder finder) async {
      await tester.scrollUntilVisible(
        finder,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 40,
      );
      await tester.pumpAndSettle();
    }

    final masteryButton = find.byKey(const ValueKey('module_0_mastery_button'));
    await scrollTo(masteryButton);
    expect(masteryButton, findsOneWidget);
    expect(store.isModuleUnlocked(modules, 1), isFalse);

    await tester.tap(masteryButton);
    await tester.pumpAndSettle();
    expect(find.text('Desafio de domínio — Módulo 0'), findsOneWidget);

    final prediction = find.text('Planejar\nTestar');
    await scrollTo(prediction);
    await tester.tap(prediction);
    await tester.pumpAndSettle();

    final debug = find.byKey(const ValueKey('mastery_debug'));
    await scrollTo(debug);
    await tester.enterText(debug, 'print("Planejar")\nprint("Executar")');
    await scrollTo(find.text('Testar correção'));
    await tester.tap(find.text('Testar correção'));
    await tester.pumpAndSettle();

    final create = find.byKey(const ValueKey('mastery_create'));
    await scrollTo(create);
    await tester.enterText(create, 'print("Meu app")\nprint("Primeira versão")');
    await scrollTo(find.text('Executar meu código'));
    await tester.tap(find.text('Executar meu código'));
    await tester.pumpAndSettle();

    final explain = find.byKey(const ValueKey('mastery_explain'));
    await scrollTo(explain);
    await tester.enterText(
      explain,
      'O código são as instruções que eu escrevo e a saída é o resultado que aparece na tela.',
    );
    await scrollTo(find.text('Conferir explicação'));
    await tester.tap(find.text('Conferir explicação'));
    await tester.pumpAndSettle();

    final finish = find.byKey(const ValueKey('mastery_finish'));
    await scrollTo(finish);
    expect(tester.widget<FilledButton>(finish).onPressed, isNotNull);
    await tester.tap(finish);
    await tester.pumpAndSettle();

    expect(store.isModuleMastered('module_0'), isTrue);
    expect(store.isModuleUnlocked(modules, 1), isTrue);
    expect(find.text('Módulo 1 liberado!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
