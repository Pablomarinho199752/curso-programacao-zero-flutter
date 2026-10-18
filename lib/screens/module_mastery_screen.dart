import 'package:flutter/material.dart';

import '../services/mastery_gate.dart';
import '../services/progress_store.dart';

class Module0MasteryScreen extends StatefulWidget {
  const Module0MasteryScreen({super.key, required this.progressStore});

  final ProgressStore progressStore;

  @override
  State<Module0MasteryScreen> createState() => _Module0MasteryScreenState();
}

class _Module0MasteryScreenState extends State<Module0MasteryScreen> {
  static const _progressId = 'mastery_module_0';

  late final TextEditingController _debugController;
  late final TextEditingController _createController;
  late final TextEditingController _explainController;
  int? _prediction;
  bool _debugPassed = false;
  bool _createPassed = false;
  bool _explainPassed = false;
  String? _debugMessage;
  String? _createMessage;
  String? _explainMessage;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final saved = widget.progressStore.forLesson(_progressId);
    _prediction = saved.answers['prediction'];
    _debugPassed = saved.checks.contains('debug_ok');
    _createPassed = saved.checks.contains('create_ok');
    _explainPassed = saved.checks.contains('explain_ok');
    _debugController = TextEditingController(
      text: saved.drafts['debug'] ?? 'print("Planejar")\nprint("Executar"',
    );
    _createController = TextEditingController(text: saved.drafts['create'] ?? '');
    _explainController = TextEditingController(text: saved.drafts['explain'] ?? '');
  }

  @override
  void dispose() {
    _debugController.dispose();
    _createController.dispose();
    _explainController.dispose();
    super.dispose();
  }

  bool get _predictionPassed => module0PredictionIsCorrect(_prediction);
  bool get _ready =>
      _predictionPassed && _debugPassed && _createPassed && _explainPassed;

  void _selectPrediction(int value) {
    setState(() => _prediction = value);
    widget.progressStore.update(_progressId, (progress) {
      progress.answers['prediction'] = value;
      if (module0PredictionIsCorrect(value)) {
        progress.checks.add('prediction_ok');
      } else {
        progress.checks.remove('prediction_ok');
      }
    });
  }

  void _checkDebugging() {
    final evaluation = evaluateModule0Debugging(_debugController.text);
    setState(() {
      _debugPassed = evaluation.passed;
      _debugMessage = evaluation.message;
    });
    widget.progressStore.update(_progressId, (progress) {
      progress.drafts['debug'] = _debugController.text;
      progress.attempts['debug'] = (progress.attempts['debug'] ?? 0) + 1;
      if (evaluation.passed) {
        progress.checks.add('debug_ok');
      } else {
        progress.checks.remove('debug_ok');
      }
    });
  }

  void _checkCreation() {
    final evaluation = evaluateModule0Creation(_createController.text);
    setState(() {
      _createPassed = evaluation.passed;
      _createMessage = evaluation.message;
    });
    widget.progressStore.update(_progressId, (progress) {
      progress.drafts['create'] = _createController.text;
      progress.attempts['create'] = (progress.attempts['create'] ?? 0) + 1;
      if (evaluation.passed) {
        progress.checks.add('create_ok');
      } else {
        progress.checks.remove('create_ok');
      }
    });
  }

  void _checkExplanation() {
    final evaluation = evaluateModule0Explanation(_explainController.text);
    setState(() {
      _explainPassed = evaluation.passed;
      _explainMessage = evaluation.message;
    });
    widget.progressStore.update(_progressId, (progress) {
      progress.drafts['explain'] = _explainController.text;
      progress.attempts['explain'] = (progress.attempts['explain'] ?? 0) + 1;
      if (evaluation.passed) {
        progress.checks.add('explain_ok');
      } else {
        progress.checks.remove('explain_ok');
      }
    });
  }

  Future<void> _finish() async {
    if (!_ready || _finishing) return;
    setState(() => _finishing = true);
    await widget.progressStore.setModuleMastered('module_0', true);
    if (!mounted) return;
    setState(() => _finishing = false);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.lock_open_rounded, size: 38),
        title: const Text('Módulo 1 liberado!'),
        content: const Text(
          'Você concluiu as quatro evidências do desafio: prever, corrigir, criar e explicar. O cadeado do Módulo 1 foi aberto neste aparelho.',
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Desafio de domínio — Módulo 0')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '8/8 concluiu o percurso. Agora prove que consegue usar o que aprendeu.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'Não é uma prova de decorar. São quatro evidências diferentes. Se algo não passar, o app mostra o que revisar e você tenta de novo.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _MasteryCard(
            number: 1,
            title: 'Entender e prever',
            passed: _predictionPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sem executar, qual é a saída deste código?'),
                const SizedBox(height: 10),
                const _CodeBox('print("Planejar")\nprint("Testar")'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Testar\nPlanejar'),
                      selected: _prediction == 0,
                      onSelected: (_) => _selectPrediction(0),
                    ),
                    ChoiceChip(
                      label: const Text('Planejar\nTestar'),
                      selected: _prediction == 1,
                      onSelected: (_) => _selectPrediction(1),
                    ),
                    ChoiceChip(
                      label: const Text('print\nprint'),
                      selected: _prediction == 2,
                      onSelected: (_) => _selectPrediction(2),
                    ),
                  ],
                ),
                if (_prediction != null) ...[
                  const SizedBox(height: 10),
                  _Feedback(
                    passed: _predictionPassed,
                    text: _predictionPassed
                        ? 'Certo. A saída mantém a mesma ordem das instruções.'
                        : 'Ainda não. Leia o código de cima para baixo e acompanhe cada print.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MasteryCard(
            number: 2,
            title: 'Encontrar e corrigir um erro',
            passed: _debugPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'O programa deveria mostrar Planejar e depois Executar. Corrija apenas o necessário.',
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('mastery_debug'),
                  controller: _debugController,
                  minLines: 3,
                  maxLines: 6,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: const InputDecoration(labelText: 'Código para corrigir'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkDebugging,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Testar correção'),
                ),
                if (_debugMessage != null) ...[
                  const SizedBox(height: 10),
                  _Feedback(passed: _debugPassed, text: _debugMessage!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MasteryCard(
            number: 3,
            title: 'Criar sem copiar',
            passed: _createPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crie duas mensagens diferentes com print. Use textos seus — não copie os exemplos desta tela ou da aula.',
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('mastery_create'),
                  controller: _createController,
                  minLines: 3,
                  maxLines: 7,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    hintText: 'Escreva seu código aqui',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkCreation,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Executar meu código'),
                ),
                if (_createMessage != null) ...[
                  const SizedBox(height: 10),
                  _Feedback(passed: _createPassed, text: _createMessage!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MasteryCard(
            number: 4,
            title: 'Explicar com suas palavras',
            passed: _explainPassed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Qual é a diferença entre o código que você escreve e a saída que aparece quando o programa roda?',
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('mastery_explain'),
                  controller: _explainController,
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                  spellCheckConfiguration: const SpellCheckConfiguration(),
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Explique do seu jeito, sem copiar uma definição.',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkExplanation,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Conferir explicação'),
                ),
                if (_explainMessage != null) ...[
                  const SizedBox(height: 10),
                  _Feedback(passed: _explainPassed, text: _explainMessage!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            key: const ValueKey('mastery_finish'),
            onPressed: _ready && !_finishing ? _finish : null,
            icon: _finishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_rounded),
            label: Text(_ready ? 'Liberar Módulo 1' : 'Complete as 4 evidências'),
          ),
          const SizedBox(height: 10),
          Text(
            'Este desafio usa o laboratório seguro do curso. Ele valida os fundamentos do Módulo 0; não executa Python arbitrário nem comandos do aparelho.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _MasteryCard extends StatelessWidget {
  const _MasteryCard({
    required this.number,
    required this.title,
    required this.passed,
    required this.child,
  });

  final int number;
  final String title;
  final bool passed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
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
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
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
}

class _CodeBox extends StatelessWidget {
  const _CodeBox(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171923),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Color(0xFFF5F7FF),
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.passed, required this.text});

  final bool passed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          passed ? Icons.check_circle_rounded : Icons.lightbulb_outline_rounded,
          size: 19,
          color: passed ? scheme.tertiary : scheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
