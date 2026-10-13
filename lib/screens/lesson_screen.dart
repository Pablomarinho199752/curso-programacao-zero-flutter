import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course_models.dart';
import '../services/print_lab.dart';
import '../services/progress_store.dart';
import '../widgets/section_card.dart';

const onboardingSteps = [
  'Explicação curta',
  'Videoaula',
  'Exemplo',
  'Prática',
  'Desafio',
  'Correção',
  'Mini projeto',
  'Revisão',
];

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.progressStore,
  });
  final CourseLesson lesson;
  final ProgressStore progressStore;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _controllers = <String, TextEditingController>{};
  final _scroll = ScrollController();
  final _feedback = <String, String>{};
  LessonProgress get p => widget.progressStore.forLesson(widget.lesson.id);
  Map<String, dynamic> get content => widget.lesson.onboarding;
  List<String> texts(String key) => (content[key] as List).cast<String>();
  String value(String key) => content[key] as String;
  Future<void> update(void Function(LessonProgress) fn) =>
      widget.progressStore.update(widget.lesson.id, fn);

  @override
  void initState() {
    super.initState();
    for (final key in [
      'practice',
      'challenge',
      'correction',
      'project',
      'reflection',
    ]) {
      final initial = key == 'correction'
          ? value('brokenCode')
          : key == 'project'
          ? value('projectStarter')
          : '';
      _controllers[key] = TextEditingController(text: p.drafts[key] ?? initial);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  void invalidate(LessonProgress data, int from) {
    data.completed.removeWhere((step) => step >= from);
  }

  Widget field(String key, String label, int step, {int lines = 3}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: TextField(
      key: ValueKey(key),
      controller: _controllers[key],
      minLines: lines,
      maxLines: lines + 3,
      maxLength: 2000,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
      onChanged: (text) {
        _feedback.remove(key);
        update((data) {
          data.drafts[key] = text;
          data.checks.remove('${key}_ok');
          if (key == 'challenge' || key == 'project') {
            data.checks.removeWhere((item) => item.startsWith('${key}_check_'));
          }
          invalidate(data, step);
        });
      },
    ),
  );

  Widget check(String key, String label, int step) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    value: p.checks.contains(key),
    controlAffinity: ListTileControlAffinity.leading,
    onChanged: (checked) => update((data) {
      if (checked == true) {
        data.checks.add(key);
      } else {
        data.checks.remove(key);
        invalidate(data, step);
      }
    }),
  );

  Widget code(String text) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: SelectableText(
      text,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
    ),
  );

  Widget feedback(String key) => _feedback[key] == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Semantics(liveRegion: true, child: Text(_feedback[key]!)),
        );

  void run(String key) {
    final source = key == 'example'
        ? widget.lesson.code
        : _controllers[key]!.text;
    final result = runPrintLab(source);
    var valid = result.ok;
    String? taskHint;
    if (key == 'correction' && valid) {
      valid =
          result.output.join('\n') == 'Consegui começar\nVou testar de novo';
      if (!valid)
        taskHint =
            'Mantenha os dois textos originais; corrija apenas a escrita que impede a execução.';
    }
    if (key == 'project' && valid) {
      valid =
          result.output.length == 2 &&
          result.output.every((line) => line.trim().isNotEmpty) &&
          result.output[0].trim() != 'Meu apelido' &&
          result.output[1].trim() != 'Quero criar...';
      if (!valid)
        taskHint =
            'Use duas linhas de saída com textos seus. Troque os dois textos do modelo.';
    }
    _feedback[key] = [
      if (result.output.isNotEmpty) 'Saída:\n${result.output.join('\n')}',
      if (result.error != null) result.error!,
      if (taskHint != null) taskHint,
      if (valid) 'Execução concluída. Compare a saída com o que você esperava.',
    ].join('\n\n');
    update((data) {
      data.attempts[key] = (data.attempts[key] ?? 0) + 1;
      if (key != 'example') data.drafts[key] = source;
      if (valid) {
        data.checks.add('${key}_ok');
      } else {
        data.checks.remove('${key}_ok');
      }
    });
  }

  Widget lab(String key, int step) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Laboratório offline • Simula apenas print com texto simples, um por linha. Não executa Python completo. Aspas dentro do texto, escapes e outros comandos ficam para depois.',
      ),
      if (key == 'example')
        code(widget.lesson.code)
      else
        field(key, 'Código para testar', step),
      FilledButton.tonalIcon(
        onPressed: () => run(key),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Executar no laboratório'),
      ),
      feedback(key),
      if (p.checks.contains('${key}_ok') && _feedback[key] == null)
        const Text(
          'Última execução válida salva. Você pode executar novamente.',
        ),
    ],
  );

  void checkPractice() {
    final answer = _controllers['practice']!.text.trim();
    if (answer.isEmpty) {
      setState(
        () => _feedback['practice'] = 'Escreva sua previsão antes de conferir.',
      );
      return;
    }
    update((data) {
      data.drafts['practice'] = _controllers['practice']!.text;
      final attempts = (data.attempts['practice'] ?? 0) + 1;
      data.attempts['practice'] = attempts;
      if (answer == widget.lesson.practiceAnswer) {
        data.checks.add('practice_ok');
        _feedback['practice'] =
            'Isso! Você previu o texto da saída, sem os sinais usados no código.';
      } else {
        data.checks.remove('practice_ok');
        final hints = texts('practiceHints');
        _feedback['practice'] =
            'Ainda não. ${hints[(attempts - 1).clamp(0, hints.length - 1)]} Tente de novo.';
      }
    });
  }

  Future<void> openVideo() async {
    try {
      final ok = await launchUrl(
        Uri.parse(widget.lesson.videoUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) throw StateError('video');
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o vídeo. Use a alternativa em texto abaixo ou tente novamente com internet.',
            ),
          ),
        );
    }
  }

  bool allChecks(String key) => List.generate(
    texts('${key}Checks').length,
    (i) => p.checks.contains('${key}_check_$i'),
  ).every((v) => v);
  bool get canContinue => switch (p.step) {
    0 => p.checks.contains('welcome'),
    1 => p.checks.contains('video'),
    2 => p.checks.contains('example_ok'),
    3 => p.checks.contains('practice_ok'),
    4 =>
      _controllers['challenge']!.text
                  .trim()
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .length >=
              4 &&
          _controllers['challenge']!.text
                  .trim()
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .length <=
              6,
    5 => p.checks.contains('correction_ok') && allChecks('challenge'),
    6 => p.checks.contains('project_ok') && allChecks('project'),
    7 =>
      p.checks.contains('quiz_ok') &&
          _controllers['reflection']!.text
                  .trim()
                  .split(RegExp(r'\s+'))
                  .length >=
              3,
    _ => false,
  };

  void move(int step) {
    update((data) => data.step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void next() {
    if (!canContinue) return;
    update((data) {
      data.completed.add(data.step);
      if (data.step < 7) data.step++;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void checkQuiz() {
    if (p.answers.length != widget.lesson.quiz.length) {
      setState(
        () =>
            _feedback['quiz'] = 'Responda às três perguntas antes de conferir.',
      );
      return;
    }
    update((data) {
      data.attempts['quiz'] = (data.attempts['quiz'] ?? 0) + 1;
      final passed = List.generate(
        widget.lesson.quiz.length,
        (i) => data.answers['$i'] == widget.lesson.quiz[i].correctIndex,
      ).every((v) => v);
      if (passed) data.checks.add('quiz_ok');
      data.checks.add('quiz_checked');
      _feedback['quiz'] = passed
          ? 'Três respostas corretas. Agora explique com suas palavras o que aprendeu.'
          : 'Há respostas para revisar. Use as pistas e tente novamente.';
    });
  }

  Widget quiz() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < widget.lesson.quiz.length; i++) ...[
        Text(
          '${i + 1}. ${widget.lesson.quiz[i].question}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RadioGroup<int>(
          groupValue: p.answers['$i'],
          onChanged: (answer) => update((data) {
            data.answers['$i'] = answer!;
            data.checks.removeAll(['quiz_ok', 'quiz_checked']);
            invalidate(data, 7);
            _feedback.remove('quiz');
          }),
          child: Column(
            children: [
              for (
                var option = 0;
                option < widget.lesson.quiz[i].options.length;
                option++
              )
                RadioListTile<int>(
                  title: Text(widget.lesson.quiz[i].options[option]),
                  value: option,
                ),
            ],
          ),
        ),
        if (p.checks.contains('quiz_checked'))
          Text(
            p.answers['$i'] == widget.lesson.quiz[i].correctIndex
                ? 'Correto. ${widget.lesson.quiz[i].explanation}'
                : 'Pista: ${texts('quizHints')[i]}',
          ),
        const SizedBox(height: 16),
      ],
      FilledButton.tonal(
        onPressed: checkQuiz,
        child: const Text('Conferir as 3 respostas'),
      ),
      feedback('quiz'),
    ],
  );

  List<Widget> stage() => switch (p.step) {
    0 => [
      Text(widget.lesson.objective),
      const SizedBox(height: 12),
      const Text(
        'Você precisa apenas deste app. Leia uma etapa por vez e use Voltar para revisar. Suas respostas ficam neste aparelho; não há conta nem sincronização entre Android e Windows.',
      ),
      ...widget.lesson.theory.map(
        (text) =>
            Padding(padding: const EdgeInsets.only(top: 14), child: Text(text)),
      ),
      check(
        'welcome',
        'Entendi como estudar aqui e vou experimentar, mesmo quando errar.',
        0,
      ),
    ],
    1 => [
      Text(value('videoGuide')),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: openVideo,
        icon: const Icon(Icons.open_in_new),
        label: Text(value('videoTitle')),
      ),
      const Text(
        'Abre fora do app e precisa de internet. Ao voltar, você continua nesta etapa.',
      ),
      ExpansionTile(
        title: const Text('Alternativa em texto • sem internet'),
        children: texts('videoFallback')
            .map(
              (text) =>
                  Padding(padding: const EdgeInsets.all(12), child: Text(text)),
            )
            .toList(),
      ),
      check('video', 'Assisti à introdução ou li a alternativa em texto.', 1),
    ],
    2 => [
      const Text(
        'Antes de executar, imagine quais duas linhas aparecerão. O computador segue a ordem das instruções. Depois compare sua previsão com a saída.',
      ),
      lab('example', 2),
    ],
    3 => [
      Text(widget.lesson.practicePrompt),
      field('practice', 'Minha previsão da saída', 3, lines: 1),
      FilledButton.tonal(
        onPressed: checkPractice,
        child: const Text('Conferir previsão'),
      ),
      feedback('practice'),
      if (p.checks.contains('practice_ok'))
        const Text('Previsão correta registrada.'),
      if ((p.attempts['practice'] ?? 0) >= 2)
        ExpansionTile(
          title: const Text('Ver explicação depois das tentativas'),
          children: [
            Text(
              'A saída é ${widget.lesson.practiceAnswer}. print mostra o texto entre as aspas. Volte ao campo e registre o que entendeu.',
            ),
          ],
        ),
    ],
    4 => [
      Text(widget.lesson.challenge),
      field('challenge', 'Meu algoritmo • um passo por linha', 4, lines: 6),
      const Text(
        'Escreva de 4 a 6 linhas. A próxima etapa ajuda você a avaliar a clareza. O app confere apenas a quantidade de passos; a qualidade será discutida na revisão.',
      ),
    ],
    5 => [
      const Text(
        'Primeiro, releia seu algoritmo. A avaliação abaixo é sua: marcar os itens não significa que o app verificou o texto.',
      ),
      code(p.drafts['challenge'] ?? ''),
      for (var i = 0; i < texts('challengeChecks').length; i++)
        check('challenge_check_$i', texts('challengeChecks')[i], 5),
      ExpansionTile(
        title: const Text('Comparar com uma solução possível'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(value('challengeExample')),
          ),
        ],
      ),
      const Divider(height: 32),
      const Text(
        'Agora corrija um erro pequeno. Execute este código como está, leia a indicação da linha e tente ajustar sem trocar os textos.',
      ),
      lab('correction', 5),
      if ((p.attempts['correction'] ?? 0) > 0)
        Text(
          'Pista: ${texts('correctionHints')[((p.attempts['correction'] ?? 1) - 1).clamp(0, 1)]}',
        ),
      if ((p.attempts['correction'] ?? 0) >= 2)
        ExpansionTile(
          title: const Text('Ver correção comentada'),
          children: [
            code(value('fixedCode')),
            const Text(
              'Faltava fechar o parêntese da segunda linha. Ajuste seu código e execute para comparar.',
            ),
          ],
        ),
    ],
    6 => [
      Text(value('projectPrompt')),
      lab('project', 6),
      for (var i = 0; i < texts('projectChecks').length; i++)
        check('project_check_$i', texts('projectChecks')[i], 6),
    ],
    7 => [
      ...widget.lesson.review.map(
        (text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(text),
        ),
      ),
      quiz(),
      field(
        'reflection',
        'Com minhas palavras: o que corrigi e por quê? O que ainda me confunde?',
        7,
      ),
      const Text(
        'Depois, tente recriar o cartão sem consultar o modelo. Se precisar de ajuda, volte à etapa correspondente. Seu relatório pode ser copiado para revisão pedagógica no ChatGPT.',
      ),
      if (p.completed.length == 8)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Módulo 0 concluído! O Módulo 1 ainda não foi liberado. Vamos revisar este percurso antes da próxima versão.',
          ),
        ),
      OutlinedButton.icon(
        onPressed: copyReview,
        icon: const Icon(Icons.copy),
        label: const Text('Copiar minha revisão para o ChatGPT'),
      ),
    ],
    _ => [],
  };

  Future<void> copyReview() async {
    final report =
        'Revisão pedagógica — Módulo 0\n'
        'Etapas concluídas: ${p.completed.length}/8\n'
        'Minha previsão: ${p.drafts['practice'] ?? ""}\n'
        'Meu algoritmo (autoavaliação):\n${p.drafts['challenge'] ?? ""}\n'
        'Minha correção:\n${p.drafts['correction'] ?? ""}\n'
        'Meu mini projeto:\n${p.drafts['project'] ?? ""}\n'
        'Reflexão:\n${p.drafts['reflection'] ?? ""}\n'
        'Tentativas: ${p.attempts}\n'
        'Quiz: ${List.generate(widget.lesson.quiz.length, (i) => "${i + 1}: ${p.answers['$i'] == null ? 'sem resposta' : widget.lesson.quiz[i].options[p.answers['$i']!]} ").join('\n')}\n'
        'Revise minha compreensão. Dê pistas antes de soluções e não avance para o Módulo 1.';
    try {
      await Clipboard.setData(ClipboardData(text: report));
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revisão copiada. Cole na conversa do ChatGPT.'),
          ),
        );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível copiar. Tente novamente.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.progressStore,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Módulo 0 • Primeiros passos')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Etapa ${p.step + 1} de 8 • ${p.completed.length}/8 concluídas',
              ),
              LinearProgressIndicator(
                value: p.completed.length / 8,
                semanticsLabel: 'Progresso do Módulo 0',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < 8; i++)
                    ChoiceChip(
                      label: Text('${i + 1}. ${onboardingSteps[i]}'),
                      selected: p.step == i,
                      onSelected:
                          i == 0 ||
                              List.generate(
                                i,
                                (index) => p.completed.contains(index),
                              ).every((v) => v)
                          ? (_) => move(i)
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.progressStore.saveError != null) ...[
                Text(widget.progressStore.saveError!),
                TextButton(
                  onPressed: widget.progressStore.save,
                  child: const Text('Tentar salvar novamente'),
                ),
              ],
              SectionCard(
                title: onboardingSteps[p.step],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stage(),
                ),
              ),
              if (!canContinue)
                Text(switch (p.step) {
                  0 => 'Confirme que entendeu a proposta para continuar.',
                  1 =>
                    'Assista ao vídeo ou leia a alternativa e confirme acima.',
                  2 => 'Execute o exemplo e observe a saída.',
                  3 => 'Registre e confira uma previsão correta.',
                  4 => 'Registre de 4 a 6 passos, um por linha.',
                  5 =>
                    'Revise os três critérios e execute a correção mantendo os dois textos.',
                  6 => 'Execute seus dois textos e confirme os dois critérios.',
                  _ =>
                    'Acerte as três perguntas e escreva uma reflexão com pelo menos três palavras.',
                }),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (p.step > 0)
                    OutlinedButton(
                      onPressed: () => move(p.step - 1),
                      child: const Text('Voltar'),
                    ),
                  FilledButton(
                    onPressed: canContinue ? next : null,
                    child: Text(
                      p.step == 7
                          ? (p.completed.length == 8
                                ? 'Revisão concluída'
                                : 'Concluir Módulo 0')
                          : 'Concluir etapa e continuar',
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Salvar e sair'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}
