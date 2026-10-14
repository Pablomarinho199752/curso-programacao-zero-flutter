class BasicsLabResult {
  const BasicsLabResult({
    required this.ok,
    required this.output,
    required this.variables,
    this.error,
  });

  final bool ok;
  final List<String> output;
  final Map<String, Object> variables;
  final String? error;
}

final _name = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
final _assignment = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$');
final _print = RegExp(r'^print\s*\((.*)\)\s*$');

BasicsLabResult runBasicsLab(String source) {
  if (source.trim().isEmpty) {
    return const BasicsLabResult(
      ok: false,
      output: [],
      variables: {},
      error: 'Escreva pelo menos uma instrução antes de executar.',
    );
  }
  if (source.length > 3000) {
    return const BasicsLabResult(
      ok: false,
      output: [],
      variables: {},
      error: 'O laboratório aceita até 3000 caracteres neste módulo.',
    );
  }

  final variables = <String, Object>{};
  final output = <String>[];
  final lines = source.split('\n');

  for (var index = 0; index < lines.length; index++) {
    final raw = lines[index];
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    if (line.contains(';')) {
      return _failure(index, output, variables, 'use uma instrução por linha.');
    }

    final printMatch = _print.firstMatch(line);
    if (printMatch != null) {
      final expression = printMatch.group(1)!.trim();
      final value = _readValue(expression, variables);
      if (value == null) {
        return _failure(
          index,
          output,
          variables,
          'não encontrei esse valor ou variável. Confira o nome e tente de novo.',
        );
      }
      output.add(_formatValue(value));
      continue;
    }

    final assignmentMatch = _assignment.firstMatch(line);
    if (assignmentMatch != null) {
      final variableName = assignmentMatch.group(1)!;
      final expression = assignmentMatch.group(2)!.trim();
      if (!_name.hasMatch(variableName)) {
        return _failure(index, output, variables, 'o nome da variável não é válido.');
      }
      final value = _readLiteral(expression);
      if (value == null) {
        return _failure(
          index,
          output,
          variables,
          'neste laboratório, atribua apenas texto entre aspas ou números.',
        );
      }
      variables[variableName] = value;
      continue;
    }

    return _failure(
      index,
      output,
      variables,
      'use uma atribuição simples (nome = valor) ou print(...).',
    );
  }

  return BasicsLabResult(
    ok: true,
    output: output,
    variables: Map.unmodifiable(variables),
  );
}

BasicsLabResult _failure(
  int zeroBasedLine,
  List<String> output,
  Map<String, Object> variables,
  String message,
) =>
    BasicsLabResult(
      ok: false,
      output: List.unmodifiable(output),
      variables: Map.unmodifiable(variables),
      error: 'Linha ${zeroBasedLine + 1}: $message',
    );

Object? _readValue(String expression, Map<String, Object> variables) {
  final literal = _readLiteral(expression);
  if (literal != null) return literal;
  return variables[expression];
}

Object? _readLiteral(String expression) {
  if (expression.length >= 2 &&
      ((expression.startsWith('"') && expression.endsWith('"')) ||
          (expression.startsWith("'") && expression.endsWith("'")))) {
    final inner = expression.substring(1, expression.length - 1);
    if (inner.contains(expression[0])) return null;
    return inner;
  }

  final integer = int.tryParse(expression);
  if (integer != null) return integer;
  final decimal = double.tryParse(expression);
  if (decimal != null) return decimal;
  return null;
}

String _formatValue(Object value) {
  if (value is double && value == value.roundToDouble()) {
    return value.toStringAsFixed(1);
  }
  return value.toString();
}
