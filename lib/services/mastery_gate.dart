import 'print_lab.dart';

class MasteryEvaluation {
  const MasteryEvaluation({required this.passed, required this.message});

  final bool passed;
  final String message;
}

bool module0PredictionIsCorrect(int? option) => option == 1;

MasteryEvaluation evaluateModule0Debugging(String source) {
  final result = runPrintLab(source);
  if (!result.ok) {
    return MasteryEvaluation(
      passed: false,
      message: result.error ?? 'Ainda há um erro para corrigir.',
    );
  }
  const expected = ['Planejar', 'Executar'];
  if (!_sameOutput(result.output, expected)) {
    return const MasteryEvaluation(
      passed: false,
      message:
          'O código executou, mas a saída precisa manter Planejar na primeira linha e Executar na segunda.',
    );
  }
  return const MasteryEvaluation(
    passed: true,
    message: 'Correção validada: você encontrou e corrigiu o erro sem trocar o objetivo do código.',
  );
}

MasteryEvaluation evaluateModule0Creation(String source) {
  final result = runPrintLab(source);
  if (!result.ok) {
    return MasteryEvaluation(
      passed: false,
      message: result.error ?? 'Revise o código e tente novamente.',
    );
  }
  if (result.output.length < 2) {
    return const MasteryEvaluation(
      passed: false,
      message: 'Crie pelo menos duas instruções print, uma por linha.',
    );
  }
  final unique = result.output.map((text) => text.trim()).where((text) => text.isNotEmpty).toSet();
  if (unique.length < 2) {
    return const MasteryEvaluation(
      passed: false,
      message: 'Use duas mensagens diferentes para mostrar que você criou a solução.',
    );
  }
  const copiedExamples = {
    'Olá, mundo!',
    'Um passo de cada vez',
    'Planejar',
    'Executar',
  };
  if (result.output.any(copiedExamples.contains)) {
    return const MasteryEvaluation(
      passed: false,
      message: 'Use textos seus, diferentes dos exemplos do curso.',
    );
  }
  return const MasteryEvaluation(
    passed: true,
    message: 'Criação validada: o laboratório executou duas mensagens diferentes escritas por você.',
  );
}

MasteryEvaluation evaluateModule0Explanation(String text) {
  final answer = text.trim().toLowerCase();
  if (answer.length < 35) {
    return const MasteryEvaluation(
      passed: false,
      message: 'Explique um pouco mais, com suas palavras. Tente usar pelo menos uma frase completa.',
    );
  }
  const codeTerms = [
    'código',
    'codigo',
    'comando',
    'instrução',
    'instrucao',
    'programa',
    'escrev',
  ];
  const outputTerms = [
    'saída',
    'saida',
    'resultado',
    'aparece',
    'mostra',
    'tela',
  ];
  final mentionsCode = codeTerms.any(answer.contains);
  final mentionsOutput = outputTerms.any(answer.contains);
  if (!mentionsCode || !mentionsOutput) {
    return const MasteryEvaluation(
      passed: false,
      message:
          'Sua explicação precisa diferenciar o que você escreve no código do resultado que aparece quando ele é executado.',
    );
  }
  return const MasteryEvaluation(
    passed: true,
    message: 'Explicação validada: você diferenciou instrução e resultado com suas próprias palavras.',
  );
}

bool _sameOutput(List<String> actual, List<String> expected) {
  if (actual.length != expected.length) return false;
  for (var i = 0; i < actual.length; i++) {
    if (actual[i] != expected[i]) return false;
  }
  return true;
}
