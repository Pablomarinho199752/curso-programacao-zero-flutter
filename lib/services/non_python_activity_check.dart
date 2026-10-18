/// Git terminal commands and planning activities are not Python programs.
/// This is a transparent structural self-check, not proof of correctness.
class NonPythonActivityCheck {
  const NonPythonActivityCheck({required this.passed, required this.missing});

  final bool passed;
  final List<String> missing;
}

NonPythonActivityCheck checkNonPythonActivity({
  required int module,
  required String step,
  required String source,
}) {
  if (module == 12) {
    final text = source.trim();
    // A plan is open-ended writing. We must not grade its language by checking
    // whether it contains one precise keyword, question mark or Python syntax.
    return NonPythonActivityCheck(
      passed: text.isNotEmpty && text.replaceAll(RegExp(r'\\s+'), '').length >= 20,
      missing: text.trim().length < 20
          ? const ['Escreva seu plano com requisitos e como pretende testá-los']
          : const [],
    );
  }

  if (module != 11) {
    throw ArgumentError.value(module, 'module', 'Módulo não textual');
  }

  // Ignore comments: they may mention missing commands ("# sem git status")
  // without actually placing these commands in the proposed workflow.
  final commands = source.split('\\n').map((line) => line.trim()).where(
        (line) => line.isNotEmpty && !line.startsWith('#'),
      ).toList();
  final normalized = commands.map((line) => line.toLowerCase()).toList();

  bool has(String expression) {
    final pattern = RegExp(expression, caseSensitive: false);
    return normalized.any((line) => pattern.hasMatch(line));
  }

  final missing = <String>[];
  final createdBranch = has(r'^git\\s+switch\\s+-c\\s+\\S+') ||
      has(r'^git\\s+checkout\\s+-b\\s+\\S+') ||
      (has(r'^git\\s+branch\\s+\\S+') &&
          has(r'^git\\s+(switch|checkout)\\s+\\S+'));
  if (step == 'challenge' || step == 'project') {
    if (!createdBranch) {
      missing.add('Criar e entrar em uma branch (git switch -c ou git checkout -b)');
    }
    if (!has(r'^git\\s+add\\s+')) {
      missing.add('Preparar alterações com git add');
    }
    if (!has(r'^git\\s+commit\\s+')) {
      missing.add('Registrar a mudança com git commit');
    }
    if (step == 'project' && !has(r'^git\\s+push\\b')) {
      missing.add('Publicar as alterações com git push');
    }
  } else if (step == 'correction' || step == 'debug') {
    if (!has(r'^git\\s+status\\b')) missing.add('Verificar git status');
    if (!has(r'^git\\s+diff\\b')) missing.add('Revisar git diff');
    if (!has(r'^git\\s+commit\\s+-m\\s+')) {
      missing.add('Fazer git commit -m com mensagem descritiva');
    }
  }
  return NonPythonActivityCheck(passed: missing.isEmpty, missing: missing);
}
