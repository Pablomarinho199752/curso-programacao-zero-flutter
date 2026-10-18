import 'package:curso_programacao_zero/services/non_python_activity_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Git switch and checkout branch creation are both valid', () {
    for (final create in [
      'git switch -c feat/calculadora',
      'git checkout -b feat/calculadora',
    ]) {
      final result = checkNonPythonActivity(
        module: 11,
        step: 'challenge',
        source: '$create\ngit add .\ngit commit -m "feat: calculadora"',
      );
      expect(result.passed, isTrue, reason: result.missing.join(', '));
    }
  });

  test('Git commands in a comment do not pass as executable commands', () {
    final result = checkNonPythonActivity(
      module: 11,
      step: 'correction',
      source: '# git status\n# git diff\ngit commit -m "feat: revisar"',
    );
    expect(result.passed, isFalse);
    expect(result.missing.length, 2);
  });

  test('planning text is not parsed as Python and has no keyword gate', () {
    final result = checkNonPythonActivity(
      module: 12,
      step: 'challenge',
      source: 'Quero criar uma agenda. Vou conferir três situações '
          'e comparar o resultado com meu objetivo.',
    );
    expect(result.passed, isTrue);
    expect(
      checkNonPythonActivity(module: 12, step: 'challenge', source: 'oi').passed,
      isFalse,
    );
  });
}
