import '../models/course_models.dart';
import 'progress_store.dart';
import 'python_lab_service.dart';

class LearningCoachService {
  const LearningCoachService();

  static const _reviewIntervalsDays = <int>[1, 3, 7, 14, 30];

  String stageName(int step) => switch (step) {
        0 => 'Explicação',
        1 => 'Videoaula',
        2 => 'Exemplo',
        3 => 'Prática',
        4 => 'Desafio',
        5 => 'Correção',
        6 => 'Mini projeto',
        _ => 'Revisão',
      };

  String draftKey(int step) => switch (step) {
        4 => 'challenge',
        5 => 'correction',
        6 => 'project',
        3 => 'inline_practice_code',
        _ => 'inline_example_code',
      };

  String promptFor(CourseLesson lesson, int step) => switch (step) {
        0 => 'Teste a ideia da explicação com um exemplo pequeno. Mude um valor por vez e observe o resultado.',
        1 => 'Depois do vídeo, recrie um exemplo com suas próprias palavras e valores.',
        2 => 'Execute o exemplo, depois altere um detalhe e tente prever a nova saída antes de rodar de novo.',
        3 => lesson.practicePrompt,
        4 => lesson.challenge,
        5 => ((lesson.onboarding['correctionPrompt'] as String?) ??
            'Execute o código com problema, leia o erro e corrija apenas o necessário.'),
        6 => ((lesson.onboarding['projectPrompt'] as String?) ??
            'Execute seu mini projeto em partes pequenas e confira cada resultado antes de continuar.'),
        _ => 'Sem olhar a solução, escreva um exemplo curto que prove que você ainda lembra o conceito da aula.',
      };

  String starterCode(CourseLesson lesson, LessonProgress progress, int step) {
    final key = draftKey(step);
    final saved = progress.drafts[key];
    if (saved != null && saved.trim().isNotEmpty) return saved;

    if (step == 5) {
      final broken = lesson.onboarding['brokenCode'];
      if (broken is String && broken.trim().isNotEmpty) return broken;
    }
    if (step == 6) {
      final starter = lesson.onboarding['projectStarter'];
      if (starter is String && starter.trim().isNotEmpty) return starter;
    }
    return lesson.code;
  }

  List<String> hintsFor({
    required PythonExecutionResult result,
    required int attempt,
    required CourseLesson lesson,
    required int step,
  }) {
    if (result.ok) {
      return <String>[
        'O código executou. Agora confirme se a saída é a que você previu.',
        if (step >= 4)
          'Não encerre só porque executou: compare o resultado com todos os requisitos do desafio.',
      ];
    }

    final type = result.errorType ?? '';
    final line = result.errorLine;
    final hints = <String>[];

    if (line != null) {
      hints.add('Comece pela linha $line. Leia essa linha junto com a anterior antes de alterar o código.');
    }

    if (type.contains('Syntax')) {
      hints.add('O Python não conseguiu entender a forma do código. Confira parênteses, dois-pontos, aspas e indentação.');
    } else if (type.contains('Name')) {
      hints.add('O código tentou usar um nome que o Python não conhece. Compare letra por letra com o nome criado antes.');
    } else if (type.contains('Type')) {
      hints.add('Os valores existem, mas a operação não combina com o tipo de algum deles. Descubra primeiro quais tipos estão envolvidos.');
    } else if (type.contains('Index')) {
      hints.add('O código tentou acessar uma posição que não existe. Conte quantos itens há e lembre que a primeira posição é 0.');
    } else if (type.contains('Key')) {
      hints.add('A chave procurada não foi encontrada. Confira a grafia e as chaves realmente existentes.');
    } else if (type.contains('Value')) {
      hints.add('O formato do valor não combina com a conversão/operação pedida. Confira o conteúdo antes de convertê-lo.');
    } else if (type.contains('Timeout')) {
      hints.add('A execução não terminou. Procure um laço cuja condição talvez nunca mude.');
    } else {
      hints.add('Leia o tipo do erro e compare o que o Python recebeu com o que você esperava que ele recebesse.');
    }

    if (attempt >= 2) {
      hints.add('Isole o problema: comente temporariamente partes do código e teste o menor trecho que ainda reproduz o erro.');
    }
    if (attempt >= 3) {
      hints.add('Use print() logo antes da linha problemática para observar os valores e tipos que chegaram até ali.');
    }

    return hints;
  }

  int reviewCount(LessonProgress progress) =>
      progress.attempts['spaced_review_count'] ?? 0;

  int reviewIntervalDays(LessonProgress progress) {
    final count = reviewCount(progress);
    final index = count.clamp(0, _reviewIntervalsDays.length - 1);
    return _reviewIntervalsDays[index];
  }

  bool reviewDue(LessonProgress progress, {int? nowMs}) {
    if (progress.completed.length < 8 || progress.updatedAtMs <= 0) return false;
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - progress.updatedAtMs;
    return elapsed >= Duration(days: reviewIntervalDays(progress)).inMilliseconds;
  }

  Duration timeUntilReview(LessonProgress progress, {int? nowMs}) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final target = progress.updatedAtMs +
        Duration(days: reviewIntervalDays(progress)).inMilliseconds;
    return Duration(milliseconds: (target - now).clamp(0, 1 << 62));
  }

  int moduleNumber(CourseLesson lesson) {
    final match = RegExp(r'^lesson_(\d+)_').firstMatch(lesson.id);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  bool hasCumulativeProject(CourseLesson lesson) {
    final module = moduleNumber(lesson);
    return const <int>{3, 6, 9, 12}.contains(module);
  }

  String cumulativeProjectKey(CourseLesson lesson) =>
      'cumulative_project_m${moduleNumber(lesson)}';

  String? cumulativeProjectPrompt(CourseLesson lesson) {
    return switch (moduleNumber(lesson)) {
      3 => 'Projeto cumulativo 1: crie um programa que receba dados, guarde em variáveis, tome uma decisão e mostre uma resposta clara ao usuário.',
      6 => 'Projeto cumulativo 2: evolua o programa anterior usando repetição e coleções. O usuário deve conseguir trabalhar com vários itens, não apenas um.',
      9 => 'Projeto cumulativo 3: organize o programa em funções e estruturas de dados. Separe entrada, processamento e saída para o código ficar fácil de testar.',
      12 => 'Projeto final cumulativo: construa um pequeno programa completo escolhendo o problema. Planeje, implemente em partes, trate erros básicos, teste casos diferentes e explique suas decisões.',
      _ => null,
    };
  }
}
