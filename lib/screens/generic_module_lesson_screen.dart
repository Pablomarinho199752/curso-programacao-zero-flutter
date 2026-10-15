import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/section_card.dart';

const _genericSteps = [
  'Explicação curta',
  'Videoaula',
  'Exemplo',
  'Prática',
  'Desafio',
  'Correção',
  'Mini projeto',
  'Revisão',
];

class GenericModuleLessonScreen extends StatefulWidget {
  const GenericModuleLessonScreen({
    super.key,
    required this.lesson,
    required this.progressStore,
  });

  final CourseLesson lesson;
  final ProgressStore progressStore;

  @override
  State<GenericModuleLessonScreen> createState() =>
      _GenericModuleLessonScreenState();
}

class _GenericModuleLessonScreenState extends State<GenericModuleLessonScreen> {
  final _controllers = <String, TextEditingController>{};
  final _feedback = <String, String>{};

  LessonProgress get p => widget.progressStore.forLesson(widget.lesson.id);
  Map<String, dynamic> get data => widget.lesson.onboarding;

  String text(String key) => (data[key] as String?) ?? '';
  List<String> texts(String key) =>
      ((data[key] as List?) ?? const <dynamic>[]).cast<String>();

  Future<void> update(void Function(LessonProgress) change) =>
      widget.progressStore.update(widget.lesson.id, change);

  @override
  void initState() {
    super.initState();
    for (final key in [
      'practice',
      'challenge',
      'correction',
      'project',
      'reflection',
      'evidence',
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

  bool _containsRequired(String source, String key) {
    final required = texts(key);
    if (required.isEmpty) return source.trim().length >= 20;
    final normalized = source.toLowerCase();
    return required.every((token) => normalized.contains(token.toLowerCase()));
  }

  int _wordCount(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;

  Widget _codeBox(String source) => Container(
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

  Widget _codeField(String key, String label, int step, {int lines = 7}) =>
      TextField(
        key: ValueKey('${widget.lesson.id}_$key'),
        controller: _controllers[key],
        minLines: lines,
        maxLines: lines + 8,
        maxLength: 6000,
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

  Widget _feedbackBox(String key) {
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

  Future<void> _validateCode(String key, int step, String requiredKey) async {
    final source = _controllers[key]!.text;
    final accepted = _containsRequired(source, requiredKey);
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
      _feedback[key] = accepted
          ? 'A estrutura pedida está presente. Agora execute em um Python real e compare o comportamento com o seu plano.'
          : 'Ainda falta pelo menos um elemento essencial do pedido. Leia o objetivo, confira as pistas e ajuste uma coisa de cada vez.';
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
        7 => p.checks.contains('quiz_ok') &&
            p.checks.contains('reflection_ok') &&
            p.checks.contains('evidence_ok'),
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
            'Aula concluída. Concluir o percurso ainda não comprova domínio do módulo.',
          ),
        ),
      );
    }
  }

  Widget _simpleCheck(String key, String label, int step) => CheckboxListTile(
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
          title: text('conceptTitle').isEmpty
              ? 'Entenda a ideia antes de decorar comandos'
              : text('conceptTitle'),
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
              _codeBox(lesson.code),
              _simpleCheck(
                'concept_ready',
                'Consigo explicar a ideia principal desta aula com minhas palavras.',
                0,
              ),
            ],
          ),
        );
      case 1:
        return SectionCard(
          title: text('videoTitle').isEmpty ? 'Videoaula' : text('videoTitle'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text('videoGuide')),
              const SizedBox(height: 14),
              if (lesson.videoUrl.isNotEmpty)
                FilledButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(lesson.videoUrl);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Abrir videoaula'),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'A videoaula deste módulo já entrou na fila de renderização. Enquanto o link público final não estiver nesta versão do app, use a alternativa em texto abaixo.',
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
              _simpleCheck(
                'video_ready',
                'Entendi a ideia principal e estou pronto para testar o exemplo.',
                1,
              ),
            ],
          ),
        );
      case 2:
        return SectionCard(
          title: 'Exemplo: leia antes de revelar o resultado',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text('examplePrompt')),
              _codeBox(lesson.code),
              OutlinedButton.icon(
                onPressed: () => update(
                  (progress) => progress.checks.add('example_ok'),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Revelar resultado esperado'),
              ),
              if (p.checks.contains('example_ok')) ...[
                const SizedBox(height: 10),
                Text(text('exampleOutput')),
              ],
            ],
          ),
        );
      case 3:
        return SectionCard(
          title: 'Prática: preveja antes de executar',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.practicePrompt),
              const SizedBox(height: 12),
              TextField(
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
                  final correct = answer.toLowerCase() ==
                      lesson.practiceAnswer.trim().toLowerCase();
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
                        ? 'Certo. Você acompanhou o código antes de depender da execução.'
                        : 'Ainda não. Simule o programa de cima para baixo e tente novamente.';
                  });
                },
                child: const Text('Conferir previsão'),
              ),
              _feedbackBox('practice'),
              if ((p.attempts['practice'] ?? 0) >= 2)
                ...texts('practiceHints').map((hint) => Text('• $hint')),
            ],
          ),
        );
      case 4:
        return SectionCard(
          title: 'Desafio: construa uma solução sua',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.challenge),
              const SizedBox(height: 12),
              _codeField('challenge', 'Seu código', 4),
              FilledButton.icon(
                onPressed: () => _validateCode(
                  'challenge',
                  4,
                  'challengeRequiredTokens',
                ),
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('Conferir estrutura'),
              ),
              _feedbackBox('challenge'),
              if ((p.attempts['challenge'] ?? 0) >= 2)
                ...texts('challengeHints').map((hint) => Text('• $hint')),
            ],
          ),
        );
      case 5:
        return SectionCard(
          title: 'Correção: encontre a causa, não apenas a linha',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text('correctionPrompt')),
              const SizedBox(height: 12),
              _codeField('correction', 'Código para corrigir', 5),
              FilledButton.icon(
                onPressed: () => _validateCode(
                  'correction',
                  5,
                  'correctionRequiredTokens',
                ),
                icon: const Icon(Icons.bug_report_rounded),
                label: const Text('Conferir correção'),
              ),
              _feedbackBox('correction'),
              if ((p.attempts['correction'] ?? 0) >= 2)
                ...texts('correctionHints').map((hint) => Text('• $hint')),
            ],
          ),
        );
      case 6:
        return SectionCard(
          title: 'Mini projeto',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text('projectPrompt')),
              const SizedBox(height: 12),
              _codeField('project', 'Seu projeto', 6, lines: 10),
              FilledButton.icon(
                onPressed: () => _validateCode(
                  'project',
                  6,
                  'projectRequiredTokens',
                ),
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('Conferir requisitos'),
              ),
              _feedbackBox('project'),
              const SizedBox(height: 10),
              const Text(
                'A validação acima verifica a estrutura, não executa Python arbitrário. Execute o projeto em um ambiente Python real antes de fechar a revisão.',
              ),
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
      title: 'Revisão e evidência prática',
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
                      final selected = p.answers['$questionIndex'] == option.key;
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
          Text(text('reflectionPrompt')),
          const SizedBox(height: 10),
          TextField(
            controller: _controllers['reflection'],
            minLines: 3,
            maxLines: 7,
            decoration: const InputDecoration(labelText: 'Explique com suas palavras'),
            onChanged: (value) => update((progress) {
              progress.drafts['reflection'] = value;
              if (_wordCount(value) >= 12) {
                progress.checks.add('reflection_ok');
              } else {
                progress.checks.remove('reflection_ok');
              }
              invalidate(progress, 7);
            }),
          ),
          const SizedBox(height: 14),
          Text(text('evidencePrompt')),
          const SizedBox(height: 10),
          TextField(
            controller: _controllers['evidence'],
            minLines: 3,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Resultado real do teste / o que você observou',
            ),
            onChanged: (value) => update((progress) {
              progress.drafts['evidence'] = value;
              if (_wordCount(value) >= 8) {
                progress.checks.add('evidence_ok');
              } else {
                progress.checks.remove('evidence_ok');
              }
              invalidate(progress, 7);
            }),
          ),
          const SizedBox(height: 10),
          const Text(
            'O curso separa percurso de domínio. Esta evidência fecha a aula; o desafio de domínio do módulo ainda será uma etapa separada.',
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
      appBar: AppBar(title: Text('Aula ${widget.lesson.number}')),
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
            children: _genericSteps.asMap().entries.map((entry) {
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
                step == 7 ? 'Concluir aula' : 'Concluir etapa e continuar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
