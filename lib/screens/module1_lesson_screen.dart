import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/course_models.dart';
import '../services/basics_lab.dart';
import '../services/progress_store.dart';
import '../widgets/section_card.dart';

const _steps = [
  'Explicação curta',
  'Videoaula',
  'Exemplo',
  'Prática',
  'Desafio',
  'Correção',
  'Mini projeto',
  'Revisão',
];

class Module1LessonScreen extends StatefulWidget {
  const Module1LessonScreen({
    super.key,
    required this.lesson,
    required this.progressStore,
  });

  final CourseLesson lesson;
  final ProgressStore progressStore;

  @override
  State<Module1LessonScreen> createState() => _Module1LessonScreenState();
}

class _Module1LessonScreenState extends State<Module1LessonScreen> {
  final _controllers = <String, TextEditingController>{};
  final _feedback = <String, String>{};

  LessonProgress get p => widget.progressStore.forLesson(widget.lesson.id);
  Map<String, dynamic> get data => widget.lesson.onboarding;
  String text(String key) => (data[key] as String?) ?? '';
  List<String> texts(String key) =>
      ((data[key] as List?) ?? const <dynamic>[]).cast<String>();

  Future<void> update(void Function(LessonProgress) change) async {
    await widget.progressStore.update(widget.lesson.id, change);
    if (mounted) setState(() {});
  }

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
      final fallback = switch (key) {
        'correction' => text('brokenCode'),
        'project' => text('projectStarter'),
        _ => '',
      };
      _controllers[key] = TextEditingController(text: p.drafts[key] ?? fallback);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void invalidate(LessonProgress progress, int from) {
    progress.completed.removeWhere((step) => step >= from);
  }

  Widget codeBox(String source) => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF171923),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SelectableText(
          source,
          style: const TextStyle(
            color: Color(0xFFF5F7FF),
            fontFamily: 'monospace',
            height: 1.55,
          ),
        ),
      );

  Widget codeField(String key, String label, int step, {int lines = 5}) =>
      TextField(
        key: ValueKey(key),
        controller: _controllers[key],
        minLines: lines,
        maxLines: lines + 4,
        maxLength: 3000,
        autocorrect: false,
        enableSuggestions: false,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
        onChanged: (value) {
          setState(() => _feedback.remove(key));
          update((progress) {
            progress.drafts[key] = value;
            progress.checks.remove('${key}_ok');
            invalidate(progress, step);
          });
        },
      );

  Widget feedback(String key) {
    final message = _feedback[key];
    if (message == null) return const SizedBox.shrink();
    final ok = p.checks.contains('${key}_ok');
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message),
    );
  }

  Future<void> runCode(
    String key,
    int step, {
    required bool Function(BasicsLabResult) accept,
  }) async {
    final source = _controllers[key]!.text;
    final result = runBasicsLab(source);
    final accepted = result.ok && accept(result);
    await update((progress) {
      progress.drafts[key] = source;
      progress.attempts[key] = (progress.attempts[key] ?? 0) + 1;
      if (accepted) {
        progress.checks.add('${key}_ok');
      } else {
        progress.checks.remove('${key}_ok');
        invalidate(progress, step);
      }
    });
    if (!mounted) return;
    setState(() {
      if (!result.ok) {
        _feedback[key] = result.error ?? 'Ainda há algo para ajustar.';
      } else if (accepted) {
        final visible = result.output.isEmpty
            ? 'Código executado sem saída.'
            : result.output.join('\n');
        _feedback[key] = 'Funcionou. Saída:\n$visible';
      } else {
        _feedback[key] =
            'O código executou, mas ainda não atende ao objetivo desta etapa. Confira o pedido e tente outra vez.';
      }
    });
  }

  bool canComplete(int step) => switch (step) {
        0 => p.checks.contains('concept_ready'),
        1 => p.checks.contains('video_ready'),
        2 => p.checks.contains('example_ok'),
        3 => p.checks.contains('practice_ok'),
        4 => p.checks.contains('challenge_ok'),
        5 => p.checks.contains('correction_ok'),
        6 => p.checks.contains('project_ok'),
        7 => p.checks.contains('quiz_ok') && p.checks.contains('reflection_ok'),
        _ => false,
      };

  Future<void> finishStep(int step) async {
    await update((progress) {
      progress.completed.add(step);
      if (step < 7) progress.step = step + 1;
    });
    if (!mounted) return;
    setState(() {});
    if (step == 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aula 1.1 concluída. Isso ainda não marca o Módulo 1 como dominado.',
          ),
        ),
      );
    }
  }

  Widget simpleCheck(String key, String label, int step) => CheckboxListTile(
        value: p.checks.contains(key),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(label),
        onChanged: (checked) => update((progress) {
          if (checked == true) {
            progress.checks.add(key);
          } else {
            progress.checks.remove(key);
            invalidate(progress, step);
          }
        }),
      );

  Widget stageBody(int step) {
    final lesson = widget.lesson;
    final scheme = Theme.of(context).colorScheme;

    switch (step) {
      case 0:
        return SectionCard(
          title: 'Uma variável é um nome ligado a um valor',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.objective),
              const SizedBox(height: 14),
              ...lesson.theory.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(item),
                ),
              ),
              codeBox(lesson.code),
              simpleCheck(
                'concept_ready',
                'Consigo explicar, com minhas palavras, por que dar um nome a um valor pode ser útil.',
                0,
              ),
            ],
          ),
        );
      case 1:
        return SectionCard(
          title: text('videoTitle'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text('videoGuide')),
              const SizedBox(height: 14),
              if (lesson.videoUrl.isNotEmpty)
                FilledButton.icon(
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Abrir videoaula'),
                  onPressed: () async {
                    final uri = Uri.tryParse(lesson.videoUrl);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'A videoaula está sendo produzida. A alternativa em texto já permite continuar sem perder o conteúdo.',
                  ),
                ),
              const SizedBox(height: 14),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Alternativa em texto • sem internet'),
                children: texts('videoFallback')
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item),
                        ),
                      ),
                    )
                    .toList(),
              ),
              simpleCheck(
                'video_ready',
                'Entendi a ideia principal e consigo seguir para o exemplo.',
                1,
              ),
            ],
          ),
        );
      case 2:
        final result = runBasicsLab(lesson.code);
        return SectionCard(
          title: 'Exemplo: três valores guardados',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Antes de olhar a saída, leia de cima para baixo e descubra o que cada nome guarda.',
              ),
              codeBox(lesson.code),
              OutlinedButton.icon(
                onPressed: () => update(
                  (progress) => progress.checks.add('example_ok'),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Executar exemplo'),
              ),
              if (p.checks.contains('example_ok')) ...[
                const SizedBox(height: 10),
                Text(
                  result.ok
                      ? 'Saída:\n${result.output.join('\n')}'
                      : result.error ?? '',
                ),
              ],
            ],
          ),
        );
      case 3:
        return SectionCard(
          title: 'Prática: preveja antes de testar',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.practicePrompt),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('practice'),
                controller: _controllers['practice'],
                decoration: const InputDecoration(labelText: 'Sua previsão'),
                onChanged: (value) => update((progress) {
                  progress.drafts['practice'] = value;
                  progress.checks.remove('practice_ok');
                  invalidate(progress, 3);
                }),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () async {
                  final answer = _controllers['practice']!.text.trim();
                  final correct = answer == lesson.practiceAnswer.trim();
                  await update((progress) {
                    progress.attempts['practice'] =
                        (progress.attempts['practice'] ?? 0) + 1;
                    if (correct) {
                      progress.checks.add('practice_ok');
                    } else {
                      progress.checks.remove('practice_ok');
                    }
                  });
                  if (!mounted) return;
                  setState(() {
                    _feedback['practice'] = correct
                        ? 'Certo. Você acompanhou o valor da variável até a saída.'
                        : 'Ainda não. Siga o nome da variável: qual valor foi guardado nela antes do print?';
                  });
                },
                child: const Text('Conferir previsão'),
              ),
              feedback('practice'),
              if ((p.attempts['practice'] ?? 0) >= 2) ...[
                const SizedBox(height: 10),
                ...texts('practiceHints').map((hint) => Text('• $hint')),
              ],
            ],
          ),
        );
      case 4:
        return SectionCard(
          title: 'Desafio: crie suas próprias variáveis',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.challenge),
              const SizedBox(height: 12),
              codeField('challenge', 'Seu código', 4, lines: 6),
              FilledButton.icon(
                onPressed: () => runCode(
                  'challenge',
                  4,
                  accept: (result) =>
                      result.variables.length >= 3 && result.output.length >= 2,
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Executar desafio'),
              ),
              feedback('challenge'),
              if ((p.attempts['challenge'] ?? 0) >= 2) ...[
                const SizedBox(height: 10),
                ...texts('challengeHints').map((hint) => Text('• $hint')),
              ],
            ],
          ),
        );
      case 5:
        return SectionCard(
          title: 'Correção: encontre o nome que não existe',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Este programa tem um erro. Execute, leia a mensagem e corrija só o necessário.',
              ),
              const SizedBox(height: 12),
              codeField('correction', 'Código para corrigir', 5, lines: 5),
              FilledButton.icon(
                onPressed: () => runCode(
                  'correction',
                  5,
                  accept: (result) =>
                      result.output.join('\n') == text('fixedOutput'),
                ),
                icon: const Icon(Icons.bug_report_rounded),
                label: const Text('Executar correção'),
              ),
              feedback('correction'),
              if ((p.attempts['correction'] ?? 0) >= 2) ...[
                const SizedBox(height: 10),
                ...texts('correctionHints').map((hint) => Text('• $hint')),
              ],
            ],
          ),
        );
      case 6:
        return SectionCard(
          title: 'Mini projeto: ficha de dados',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text('projectPrompt')),
              const SizedBox(height: 12),
              codeField('project', 'Seu mini projeto', 6, lines: 7),
              FilledButton.icon(
                onPressed: () => runCode(
                  'project',
                  6,
                  accept: (result) {
                    final source = _controllers['project']!.text;
                    return result.variables.length >= 3 &&
                        result.output.length >= 3 &&
                        source.trim() != text('projectStarter').trim();
                  },
                ),
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('Executar mini projeto'),
              ),
              feedback('project'),
            ],
          ),
        );
      default:
        return _reviewStage();
    }
  }

  Widget _reviewStage() {
    final lesson = widget.lesson;
    return SectionCard(
      title: 'Revisão da Aula 1.1',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lesson.review.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $item'),
            ),
          ),
          const SizedBox(height: 12),
          ...lesson.quiz.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final question = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${questionIndex + 1}. ${question.question}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: question.options.asMap().entries.map((option) {
                      final selected =
                          p.answers['$questionIndex'] == option.key;
                      return ChoiceChip(
                        label: Text(option.value),
                        selected: selected,
                        onSelected: (_) => update((progress) {
                          progress.answers['$questionIndex'] = option.key;
                          progress.checks.remove('quiz_ok');
                          invalidate(progress, 7);
                        }),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          FilledButton(
            onPressed: () async {
              final correct = lesson.quiz.asMap().entries.every(
                    (entry) =>
                        p.answers['${entry.key}'] == entry.value.correctIndex,
                  );
              await update((progress) {
                if (correct) {
                  progress.checks.add('quiz_ok');
                } else {
                  progress.checks.remove('quiz_ok');
                }
              });
              if (mounted) setState(() {});
            },
            child: const Text('Conferir as 3 respostas'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Explique com suas palavras: qual é a diferença entre o nome de uma variável e o valor guardado nela?',
          ),
          const SizedBox(height: 10),
          TextField(
            key: const ValueKey('reflection'),
            controller: _controllers['reflection'],
            autocorrect: true,
            enableSuggestions: true,
            textCapitalization: TextCapitalization.sentences,
            spellCheckConfiguration: const SpellCheckConfiguration(),
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Sua explicação'),
            onChanged: (value) => update((progress) {
              progress.drafts['reflection'] = value;
              final words = value
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((word) => word.isNotEmpty)
                  .length;
              if (words >= 8) {
                progress.checks.add('reflection_ok');
              } else {
                progress.checks.remove('reflection_ok');
              }
              invalidate(progress, 7);
            }),
          ),
          const SizedBox(height: 10),
          Text(
            p.checks.contains('quiz_ok')
                ? 'Quiz correto. A explicação escrita ainda faz parte da evidência.'
                : 'A revisão só fecha com as três respostas corretas e uma explicação sua.',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = p.step.clamp(0, 7);
    final done = p.completed.length;
    return Scaffold(
      appBar: AppBar(title: Text('Módulo 1 • Aula ${widget.lesson.number}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Text(
            widget.lesson.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text('$done de 8 etapas concluídas'),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: done / 8, minHeight: 8),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _steps.asMap().entries.map((entry) {
              final reached =
                  entry.key <= p.step || p.completed.contains(entry.key);
              return ActionChip(
                avatar: Icon(
                  p.completed.contains(entry.key)
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 17,
                ),
                label: Text('${entry.key + 1}. ${entry.value}'),
                onPressed: reached
                    ? () => update((progress) => progress.step = entry.key)
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          stageBody(step),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canComplete(step) ? () => finishStep(step) : null,
              icon: Icon(
                step == 7 ? Icons.flag_rounded : Icons.arrow_forward_rounded,
              ),
              label: Text(
                step == 7
                    ? 'Concluir Aula 1.1'
                    : 'Concluir etapa e continuar',
              ),
            ),
          ),
          if (step < 7 && !canComplete(step)) ...[
            const SizedBox(height: 8),
            const Text(
              'Faça a ação pedida nesta etapa para continuar.',
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
