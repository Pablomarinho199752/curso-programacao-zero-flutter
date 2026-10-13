/// Laboratório limitado: não executa Python, rede ou comandos do aparelho.
class LabResult {
  const LabResult(this.output, this.error);
  final List<String> output;
  final String? error;
  bool get ok => error == null;
}

LabResult runPrintLab(String source) {
  if (source.length > 2000) {
    return const LabResult([], 'Use até 2.000 caracteres neste laboratório.');
  }
  final output = <String>[];
  final pattern = RegExp(r'''^print\s*\(\s*(["'])([^"'\\]*)\1\s*\)\s*$''');
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final match = pattern.firstMatch(line);
    if (match == null) {
      return LabResult(
        output,
        'Linha ${i + 1}: confira print, parênteses e o par de aspas. '
        'Este simulador aceita somente print com texto simples, um por linha. '
        'Outros comandos e escapes ficam fora deste laboratório.',
      );
    }
    output.add(match.group(2)!);
  }
  return output.isEmpty
      ? const LabResult([], 'Escreva uma instrução antes de executar.')
      : LabResult(output, null);
}
