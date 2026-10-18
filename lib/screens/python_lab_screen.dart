import 'package:flutter/material.dart';

import '../services/python_lab_service.dart';

class PythonLabScreen extends StatefulWidget {
  const PythonLabScreen({super.key, required this.lab});

  final PythonLabService lab;

  @override
  State<PythonLabScreen> createState() => _PythonLabScreenState();
}

class _PythonLabScreenState extends State<PythonLabScreen> {
  final _codeController = TextEditingController(
    text: 'nome = "Pythonista"\nfor numero in range(1, 4):\n    print(nome, numero)',
  );
  final _stdinController = TextEditingController();
  PythonExecutionResult? _result;
  bool _running = false;

  @override
  void dispose() {
    _codeController.dispose();
    _stdinController.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_codeController.text.trim().isEmpty) return;
    setState(() {
      _running = true;
      _result = null;
    });
    try {
      final result = await widget.lab.run(
        code: _codeController.text,
        stdin: _stdinController.text,
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _result = PythonExecutionResult(
          ok: false,
          stdout: '',
          stderr: '',
          error: e.toString().replaceFirst('Bad state: ', ''),
          errorType: 'RuntimeError',
          durationMs: 0,
        ),
      );
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  void _loadExample(String code, {String stdin = ''}) {
    setState(() {
      _codeController.text = code;
      _stdinController.text = stdin;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text(
          'Laboratório Python',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Aqui o código é executado por um Python real dentro do aplicativo. Antes de apertar Executar, tente prever a saída. Depois compare o resultado com o que você esperava.',
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              label: const Text('Variáveis'),
              onPressed: () => _loadExample(
                'nome = "Lia"\nidade = 22\nprint(nome)\nprint(idade)',
              ),
            ),
            ActionChip(
              label: const Text('Decisão'),
              onPressed: () => _loadExample(
                'nota = 8\nif nota >= 7:\n    print("Aprovado")\nelse:\n    print("Revisar")',
              ),
            ),
            ActionChip(
              label: const Text('Loop'),
              onPressed: () => _loadExample(
                'total = 0\nfor numero in range(1, 6):\n    total = total + numero\nprint(total)',
              ),
            ),
            ActionChip(
              label: const Text('input()'),
              onPressed: () => _loadExample(
                'nome = input("Qual seu nome? ")\nprint("Olá,", nome)',
                stdin: 'Pablo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _codeController,
          minLines: 12,
          maxLines: 24,
          maxLength: 12000,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(fontFamily: 'monospace', height: 1.45),
          decoration: const InputDecoration(
            labelText: 'Seu código Python',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 220),
              child: Icon(Icons.code_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _stdinController,
          autocorrect: true,
          enableSuggestions: true,
          textCapitalization: TextCapitalization.sentences,
          spellCheckConfiguration: const SpellCheckConfiguration(),
          minLines: 2,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Entrada para input() • uma resposta por linha',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.keyboard_rounded),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _running ? null : _run,
          icon: _running
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: Text(_running ? 'Executando Python...' : 'Executar Python'),
        ),
        const SizedBox(height: 18),
        if (_result != null) _ResultCard(result: _result!, scheme: scheme),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regras do laboratório',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text('• Execuções muito longas são interrompidas para proteger o aplicativo.'),
              Text('• Alguns módulos perigosos do Python são bloqueados.'),
              Text('• math, random, json, datetime, sqlite3 e outros módulos didáticos estão liberados.'),
              Text('• Seu código roda localmente no aparelho; ele não é enviado para um servidor de execução.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.scheme});

  final PythonExecutionResult result;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final hasOutput = result.stdout.isNotEmpty || result.stderr.isNotEmpty;
    final line = result.errorLine == null ? '' : ' • linha ${result.errorLine}';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: result.ok ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(result.ok ? Icons.check_circle_rounded : Icons.error_rounded),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.ok
                      ? 'Executado com sucesso • ${result.durationMs} ms'
                      : '${result.errorType ?? 'Erro'}$line',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (!result.ok && result.error != null) ...[
            const SizedBox(height: 10),
            Text(result.error!),
          ],
          if (hasOutput) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF171923),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                '${result.stdout}${result.stderr}',
                style: const TextStyle(
                  color: Color(0xFFF5F7FF),
                  fontFamily: 'monospace',
                  height: 1.45,
                ),
              ),
            ),
          ] else if (result.ok) ...[
            const SizedBox(height: 10),
            const Text('O programa terminou sem mostrar nada na saída.'),
          ],
        ],
      ),
    );
  }
}
