import 'package:flutter/material.dart';

import '../widgets/spelling_configuration.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../services/python_lab_service.dart';
import 'lesson_destination.dart';

class GenericModuleMasteryScreen extends StatefulWidget {
  const GenericModuleMasteryScreen({
    super.key,
    required this.module,
    required this.progressStore,
    required this.nextModuleNumber,
  });

  final CourseModule module;
  final ProgressStore progressStore;
  final int? nextModuleNumber;

  @override
  State<GenericModuleMasteryScreen> createState() =>
      _GenericModuleMasteryScreenState();
}

class _GenericModuleMasteryScreenState
    extends State<GenericModuleMasteryScreen> {
  late final CourseLesson lesson;
  final _python = PythonLabService();
  late final TextEditingController _debugController;
  late final TextEditingController _createController;
  late final TextEditingController _explainController;
  late final TextEditingController _evidenceController;

  int? _prediction;
  bool _debugPassed = false;
  bool _createPassed = false;
  bool _explainPassed = false;
  bool _evidencePassed = false;
  String? _debugMessage;
  String? _createMessage;
  String? _explainMessage;
  String? _evidenceMessage;
  bool _finishing = false;

  String get _progressId => 'mastery_${widget.module.id}';
  Map<String, dynamic> get data => lesson.onboarding;
  String text(String key) => (data[key] as String?) ?? '';
  List<String> texts(String key) =>
      ((data[key] as List?) ?? const <dynamic>[]).cast<String>();

  @override
  void initState() {
    super.initState();
    lesson = widget.module.lessons.first;
    final saved = widget.progressStore.forLesson(_progressId);
    _prediction = saved.answers['prediction'];
    _debugPassed = saved.checks.contains('debug_ok');
    _createPassed = saved.checks.contains('create_ok');
    _explainPassed = saved.checks.contains('explain_ok');
    _evidencePassed = saved.checks.contains('evidence_ok');
    _debugController = TextEditingController(
      text: saved.drafts['debug'] ?? text('brokenCode'),
    );
    _createController = TextEditingController(text: saved.drafts['create'] ?? '');
    _explainController = TextEditingController(text: saved.drafts['explain'] ?? '');
    _evidenceController = TextEditingController(text: saved.drafts['evidence'] ?? '');
  }

  @override
  void dispose() {
    _debugController.dispose();
    _createController.dispose();
    _explainController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  int _words(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;

  List<String> get _debugRequirements {
    final fixed = text('fixedCode');
    if (fixed.isNotEmpty) {
      return fixed.split('\n').where((e) => e.trim().isNotEmpty).toList();
    }
    return texts('correctionRequiredTokens');
  }

  List<String> get _createRequirements {
    final required = texts('projectRequiredTokens');
    if (required.isNotEmpty) return required;
    if (widget.module.number == 1) return const ['=', 'print('];
    return texts('challengeRequiredTokens');
  }

  bool get _predictionPassed {
    if (_prediction == null || lesson.quiz.isEmpty) return false;
    return _prediction == lesson.quiz.first.correctIndex;
  }

  bool get _ready => _predictionPassed &&
      _debugPassed &&
      _createPassed &&
      _explainPassed &&
      _evidencePassed;

  Future<void> _selectPrediction(int value) async {
    setState(() => _prediction = value);
    await widget.progressStore.update(_progressId, (progress) {
      progress.answers['prediction'] = value;
      if (value == lesson.quiz.first.correctIndex) {
        progress.checks.add('prediction_ok');
      } else {
        progress.checks.remove('prediction_ok');
      }
    });
  }

  String _codeCheckFeedback(PythonCodeCheck check) {
    if (check.error != null) {
      final line = check.errorLine == null ? '' : ' (linha ${check.errorLine})';
      return 'Erro de Python$line: ${check.error}';
    }
    if (check.missing.isNotEmpty) {
      return 'A sintaxe Python está correta, mas ainda falta: '
          '${check.missing.join(', ')}.';
    }
    return 'Sintaxe e requisitos encontrados. '
        'Agora execute na aula e confirme o comportamento.';
  }

  Future<void> _checkDebug() async {
    final source = _debugController.text;
    try {
      final check = await _python.check(
        code: source,
        requirements: _debugRequirements,
      );
      if (!mounted) return;
      await widget.progressStore.update(_progressId, (progress) {
        progress.drafts['debug'] = source;
        progress.attempts['debug'] = (progress.attempts['debug'] ?? 0) + 1;
        if (check.ok) {
          progress.checks.add('debug_ok');
        } else {
          progress.checks.remove('debug_ok');
        }
      });
      if (!mounted) return;
      setState(() {
        _debugPassed = check.ok;
        _debugMessage = _codeCheckFeedback(check);
      });
    } catch (_) {
      if (mounted) {
        setState(() => _debugMessage =
            'Não consegui acessar o Python local. Tente novamente.');
      }
    }
  }

  Future<void> _checkCreate() async {
    final source = _createController.text;
    final starter = text('projectStarter').trim();
    try {
      final check = await _python.check(
        code: source,
        requirements: _createRequirements,
      );
      if (!mounted) return;
      final ownSolution = source.trim() != starter && source.trim().length >= 35;
      final passed = check.ok && ownSolution;
      await widget.progressStore.update(_progressId, (progress) {
        progress.drafts['create'] = source;
        progress.attempts['create'] = (progress.attempts['create'] ?? 0) + 1;
        if (passed) {
          progress.checks.add('create_ok');
        } else {
          progress.checks.remove('create_ok');
        }
      });
      if (!mounted) return;
      setState(() {
        _createPassed = passed;
        _createMessage = check.ok && !ownSolution
            ? 'Escreva uma solução sua, diferente do código inicial.'
            : _codeCheckFeedback(check);
      });
    } catch (_) {
      if (mounted) {
        setState(() => _createMessage =
            'Não consegui acessar o Python local. Tente novamente.');
      }
    }
  }

  Future<void> _checkExplain() async {
    final value = _explainController.text;
    final passed = _words(value) >= 20;
    await widget.progressStore.update(_progressId, (progress) {
      progress.drafts['explain'] = value;
      if (passed) {
        progress.checks.add('explain_ok');
      } else {
        progress.checks.remove('explain_ok');
      }
    });
    if (!mounted) return;
    setState(() {
      _explainPassed = passed;
      _explainMessage = passed
          ? 'Sua explicação tem detalhe suficiente para servir como evidência. Confira se ela fala do porquê, não apenas do comando usado.'
          : 'Explique com mais detalhe o raciocínio, a escolha feita e o que mudaria se a situação fosse diferente.';
    });
  }

  Future<void> _checkEvidence() async {
    final value = _evidenceController.text;
    final lower = value.toLowerCase();
    final passed = _words(value) >= 12 &&
        (lower.contains('saída') ||
            lower.contains('resultado') ||
            lower.contains('erro') ||
            lower.contains('teste') ||
            lower.contains('execut'));
    await widget.progressStore.update(_progressId, (progress) {
      progress.drafts['evidence'] = value;
      if (passed) {
        progress.checks.add('evidence_ok');
      } else {
        progress.checks.remove('evidence_ok');
      }
    });
    if (!mounted) return;
    setState(() {
      _evidencePassed = passed;
      _evidenceMessage = passed
          ? 'Evidência registrada. Confira se o que você descreveu corresponde ao resultado visto no Python da aula.'
          : 'Abra o Python da aula, execute seu código e registre aqui a entrada usada e a saída, resultado ou erro observado.';
    });
  }

  Future<void> _finish() async {
    if (!_ready || _finishing) return;
    setState(() => _finishing = true);
    await widget.progressStore.setModuleMastered(widget.module.id, true);
    if (!mounted) return;
    setState(() => _finishing = false);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.workspace_premium_rounded, size: 40),
        title: Text(
          widget.nextModuleNumber == null
              ? 'Curso concluído com domínio!'
              : 'Módulo ${widget.nextModuleNumber} liberado!',
        ),
        content: Text(
          widget.nextModuleNumber == null
              ? 'Você apresentou evidências de entender, corrigir, criar, explicar e testar. O projeto final continua sendo algo vivo: agora você já tem um método para descobrir o próximo passo.'
              : 'Você apresentou cinco evidências: entender, corrigir, criar, explicar e testar no Python do curso. O próximo módulo foi liberado neste aparelho.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Voltar aos módulos'),
          ),
        ],
      ),
    );
  }

  Widget _feedback(bool passed, String? message) {
    if (message == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.lightbulb_outline_rounded,
            color: passed ? scheme.tertiary : scheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _card({
    required int number,
    required String title,
    required bool passed,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: passed ? scheme.tertiary : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: passed
                      ? scheme.tertiaryContainer
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: passed
                    ? Icon(
                        Icons.check_rounded,
                        color: scheme.onTertiaryContainer,
                        size: 20,
                      )
                    : Text(
                        '$number',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = lesson.quiz.first;
    return Scaffold(
      appBar: AppBar(
        title: Text('Domínio — Módulo ${widget.module.number}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 36),
        children: [
          Text(
            'Concluir aulas não abre o próximo módulo sozinho.',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agora reúna evidências diferentes. A validação estrutural ajuda, mas no item 5 você precisa executar o código no Python real integrado à própria aula e registrar o que observou.',
          ),
          const SizedBox(height: 18),
          _card(
            number: 1,
            title: 'Entender sem executar',
            passed: _predictionPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.question),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: question.options.asMap().entries.map((entry) {
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: _prediction == entry.key,
                      onSelected: (_) => _selectPrediction(entry.key),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          _card(
            number: 2,
            title: 'Corrigir uma falha',
            passed: _debugPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text('correctionPrompt')),
                const SizedBox(height: 10),
                TextField(
                  controller: _debugController,
                  minLines: 5,
                  maxLines: 12,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: const InputDecoration(labelText: 'Sua correção'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkDebug,
                  icon: const Icon(Icons.bug_report_rounded),
                  label: const Text('Conferir correção'),
                ),
                _feedback(_debugPassed, _debugMessage),
              ],
            ),
          ),
          _card(
            number: 3,
            title: 'Criar sem copiar',
            passed: _createPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text('projectPrompt')),
                const SizedBox(height: 10),
                TextField(
                  controller: _createController,
                  minLines: 7,
                  maxLines: 16,
                  maxLength: 8000,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    labelText: 'Crie uma solução sua',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkCreate,
                  icon: const Icon(Icons.code_rounded),
                  label: const Text('Conferir requisitos'),
                ),
                _feedback(_createPassed, _createMessage),
              ],
            ),
          ),
          _card(
            number: 4,
            title: 'Explicar o raciocínio',
            passed: _explainPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text('reflectionPrompt')),
                const SizedBox(height: 10),
                TextField(
                  controller: _explainController,
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                  spellCheckConfiguration: writingSpellCheckConfiguration,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Explique do seu jeito',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkExplain,
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: const Text('Conferir explicação'),
                ),
                _feedback(_explainPassed, _explainMessage),
              ],
            ),
          ),
          _card(
            number: 5,
            title: 'Provar com o Python da aula',
            passed: _evidencePassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text('evidencePrompt')),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => lessonDestination(
                        lesson: lesson,
                        progressStore: widget.progressStore,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: const Text('Abrir aula e executar no Python'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _evidenceController,
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                  spellCheckConfiguration: writingSpellCheckConfiguration,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'O que você executou e observou?',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkEvidence,
                  icon: const Icon(Icons.terminal_rounded),
                  label: const Text('Registrar evidência'),
                ),
                _feedback(_evidencePassed, _evidenceMessage),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: ValueKey('${widget.module.id}_mastery_finish'),
            onPressed: _ready && !_finishing ? _finish : null,
            icon: _finishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_rounded),
            label: Text(
              _ready
                  ? widget.nextModuleNumber == null
                      ? 'Concluir domínio do curso'
                      : 'Liberar Módulo ${widget.nextModuleNumber}'
                  : 'Complete as 5 evidências',
            ),
          ),
        ],
      ),
    );
  }
}
