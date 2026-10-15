import 'dart:async';

import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/learning_coach_service.dart';
import '../services/progress_store.dart';
import '../services/python_lab_service.dart';

class LessonWorkspaceScreen extends StatefulWidget {
  const LessonWorkspaceScreen({
    super.key,
    required this.lesson,
    required this.progressStore,
    required this.lessonChild,
  });

  final CourseLesson lesson;
  final ProgressStore progressStore;
  final Widget lessonChild;

  @override
  State<LessonWorkspaceScreen> createState() => _LessonWorkspaceScreenState();
}

class _LessonWorkspaceScreenState extends State<LessonWorkspaceScreen> {
  static const _coach = LearningCoachService();

  final _python = PythonLabService();
  final _codeController = TextEditingController();
  final _stdinController = TextEditingController();
  Timer? _saveTimer;
  PythonExecutionResult? _result;
  List<String> _hints = const [];
  bool _running = false;
  bool _cumulativeMode = false;
  int _lastStep = -1;

  LessonProgress get progress =>
      widget.progressStore.forLesson(widget.lesson.id);

  int get currentStep => progress.step.clamp(0, 7);

  String get _activeDraftKey => _cumulativeMode
      ? _coach.cumulativeProjectKey(widget.lesson)
      : _coach.draftKey(currentStep);

  @override
  void initState() {
    super.initState();
    _lastStep = currentStep;
    _loadCodeForCurrentContext();
    widget.progressStore.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.progressStore.removeListener(_onProgressChanged);
    _saveTimer?.cancel();
    _codeController.dispose();
    _stdinController.dispose();
    super.dispose();
  }

  void _onProgressChanged() {
    if (!mounted) return;
    final step = currentStep;
    if (step == _lastStep || _cumulativeMode) return;
    _lastStep = step;
    setState(() {
      _result = null;
      _hints = const [];
      _loadCodeForCurrentContext();
    });
  }

  void _loadCodeForCurrentContext() {
    if (_cumulativeMode) {
      final saved = progress.drafts[_coach.cumulativeProjectKey(widget.lesson)];
      _codeController.text = saved ??
          '# Projeto cumulativo\n# Comece pequeno. Escreva uma parte, execute e só depois avance.\n';
      return;
    }
    _codeController.text =
        _coach.starterCode(widget.lesson, progress, currentStep);
  }

  void _queueSave(String value) {
    _saveTimer?.cancel();
    final key = _activeDraftKey;
    _saveTimer = Timer(const Duration(milliseconds: 450), () {
      widget.progressStore.update(widget.lesson.id, (lessonProgress) {
        lessonProgress.drafts[key] = value;
        lessonProgress.checks.remove('${key}_runtime_ok');
      });
    });
  }

  Future<void> _runCode() async {
    if (_running) return;
    final code = _codeController.text;
    final key = _activeDraftKey;
    if (code.trim().isEmpty) {
      setState(() {
        _result = const PythonExecutionResult(
          ok: false,
          stdout: '',
          stderr: '',
          error: 'Escreva algum código antes de executar.',
          errorType: 'EmptyCode',
          durationMs: 0,
        );
        _hints = const ['Comece com a menor parte possível do programa.'];
      });
      return;
    }

    setState(() {
      _running = true;
      _result = null;
      _hints = const [];
    });

    await widget.progressStore.update(widget.lesson.id, (lessonProgress) {
      lessonProgress.drafts[key] = code;
    });

    try {
      final result = await _python.run(
        code: code,
        stdin: _stdinController.text,
      );
      final attempt = (progress.attempts['${key}_runtime'] ?? 0) + 1;

      await widget.progressStore.update(widget.lesson.id, (lessonProgress) {
        lessonProgress.attempts['${key}_runtime'] = attempt;
        if (result.ok) {
          lessonProgress.checks.add('${key}_runtime_ok');
        } else {
          lessonProgress.checks.remove('${key}_runtime_ok');
        }
      });

      if (!mounted) return;
      setState(() {
        _result = result;
        _hints = _coach.hintsFor(
          result: result,
          attempt: attempt,
          lesson: widget.lesson,
          step: currentStep,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _result = PythonExecutionResult(
          ok: false,
          stdout: '',
          stderr: '',
          error: error.toString(),
          errorType: 'RuntimeStartError',
          durationMs: 0,
        );
        _hints = const [
          'O executor local não iniciou. Feche e abra o app e tente novamente; seu código continua salvo.',
        ];
      });
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _registerReview() async {
    if (!_coach.reviewDue(progress) || _result?.ok != true) return;
    await widget.progressStore.update(widget.lesson.id, (lessonProgress) {
      final next = (_coach.reviewCount(lessonProgress) + 1).clamp(0, 999);
      lessonProgress.attempts['spaced_review_count'] = next;
      lessonProgress.checks.add('spaced_review_$next');
    });
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revisão registrada. O curso vai aumentar o intervalo da próxima revisão.'),
      ),
    );
  }

  void _toggleCumulativeProject() {
    setState(() {
      _cumulativeMode = !_cumulativeMode;
      _result = null;
      _hints = const [];
      _loadCodeForCurrentContext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            elevation: 1,
            child: SafeArea(
              bottom: false,
              child: TabBar(
                tabs: [
                  const Tab(
                    icon: Icon(Icons.school_rounded),
                    text: 'Aula',
                  ),
                  Tab(
                    icon: Icon(
                      progress.checks.contains('${_activeDraftKey}_runtime_ok')
                          ? Icons.check_circle_rounded
                          : Icons.terminal_rounded,
                    ),
                    text: 'Python na aula',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                widget.lessonChild,
                _buildWorkspace(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspace(BuildContext context) {
    final theme = Theme.of(context);
    final projectPrompt = _coach.cumulativeProjectPrompt(widget.lesson);
    final reviewDue = _coach.reviewDue(progress);
    final nextReview = _coach.timeUntilReview(progress);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            Text(
              _cumulativeMode
                  ? 'Projeto cumulativo'
                  : '${_coach.stageName(currentStep)} • Python real',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _cumulativeMode
                  ? (projectPrompt ?? '')
                  : _coach.promptFor(widget.lesson, currentStep),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'O executor faz parte desta aula. Ele não aprova o desafio sozinho: primeiro execute, observe o comportamento e depois volte à etapa da aula para conferir os requisitos.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _codeController,
              minLines: 10,
              maxLines: 24,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: 'monospace', height: 1.45),
              decoration: const InputDecoration(
                labelText: 'Código Python',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: _queueSave,
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Entrada para input() • opcional'),
              subtitle: const Text('Uma resposta por linha.'),
              children: [
                TextField(
                  controller: _stdinController,
                  minLines: 2,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'exemplo\n42',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _running ? null : _runCode,
                  icon: _running
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(_running ? 'Executando...' : 'Executar Python'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _result = null;
                      _hints = const [];
                      _loadCodeForCurrentContext();
                    });
                    _queueSave(_codeController.text);
                  },
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restaurar etapa'),
                ),
              ],
            ),
            if (_result != null) ...[
              const SizedBox(height: 18),
              _resultCard(context, _result!),
            ],
            if (_hints.isNotEmpty) ...[
              const SizedBox(height: 14),
              _hintsCard(context),
            ],
            if (projectPrompt != null && currentStep >= 6) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projeto que mistura módulos anteriores',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(projectPrompt),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _toggleCumulativeProject,
                        icon: Icon(
                          _cumulativeMode
                              ? Icons.arrow_back_rounded
                              : Icons.account_tree_rounded,
                        ),
                        label: Text(
                          _cumulativeMode
                              ? 'Voltar ao código da aula'
                              : 'Trabalhar neste projeto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (progress.completed.length == 8) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revisão espaçada',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reviewDue
                            ? 'Esta aula está pronta para revisão. Sem olhar a solução, escreva um exemplo curto acima e execute. Se funcionar, registre a revisão.'
                            : 'Ainda não está na hora. A próxima revisão entra em aproximadamente ${_daysOrHours(nextReview)}.',
                      ),
                      if (reviewDue) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _result?.ok == true ? _registerReview : null,
                          icon: const Icon(Icons.psychology_alt_rounded),
                          label: const Text('Registrar revisão feita'),
                        ),
                        if (_result?.ok != true)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Execute corretamente um exemplo primeiro. Isso evita marcar revisão apenas por abrir a tela.',
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultCard(BuildContext context, PythonExecutionResult result) {
    final theme = Theme.of(context);
    final ok = result.ok;
    final output = result.stdout.trim();
    final stderr = result.stderr.trim();

    return Card(
      color: ok
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ok ? 'Executou sem erro' : 'Python encontrou um problema',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text('${result.durationMs} ms'),
              ],
            ),
            if (output.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Saída:'),
              SelectableText(
                output,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
            if (!ok) ...[
              const SizedBox(height: 12),
              SelectableText(
                [
                  if (result.errorType != null) result.errorType!,
                  if (result.errorLine != null) 'linha ${result.errorLine}',
                  if (result.error != null) result.error!,
                  if (stderr.isNotEmpty) stderr,
                ].join(' • '),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hintsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pistas — sem entregar a solução',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ..._hints.map(
              (hint) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text('• $hint'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _daysOrHours(Duration duration) {
    if (duration.inDays >= 1) {
      return '${duration.inDays} dia${duration.inDays == 1 ? '' : 's'}';
    }
    final hours = duration.inHours.clamp(1, 23);
    return '$hours hora${hours == 1 ? '' : 's'}';
  }
}
