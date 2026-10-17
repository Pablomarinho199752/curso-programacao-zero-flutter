import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serious_python/serious_python.dart';

class PythonExecutionResult {
  const PythonExecutionResult({
    required this.ok,
    required this.stdout,
    required this.stderr,
    required this.durationMs,
    this.error,
    this.errorType,
    this.errorLine,
  });

  final bool ok;
  final String stdout;
  final String stderr;
  final String? error;
  final String? errorType;
  final int? errorLine;
  final int durationMs;

  factory PythonExecutionResult.fromJson(Map<String, dynamic> json) =>
      PythonExecutionResult(
        ok: json['ok'] == true,
        stdout: json['stdout'] as String? ?? '',
        stderr: json['stderr'] as String? ?? '',
        error: json['error'] as String?,
        errorType: json['errorType'] as String?,
        errorLine: (json['errorLine'] as num?)?.toInt(),
        durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      );
}

class PythonLabService {
  static final Uri _healthUri = Uri.parse('http://127.0.0.1:8765/health');
  static final Uri _runUri = Uri.parse('http://127.0.0.1:8765/run');

  bool _ready = false;
  Future<void>? _starting;
  String? runtimeVersion;

  Future<void> ensureStarted() {
    if (_ready) return Future.value();
    return _starting ??= _start();
  }

  Future<void> _start() async {
    try {
      final alreadyRunning = await _checkHealth();
      if (alreadyRunning) {
        _ready = true;
        return;
      }

      final runner = SeriousPython.run().then<void>(
        (_) {},
        onError: (Object _, StackTrace __) {
          _ready = false;
        },
      );
      unawaited(runner);

      for (var attempt = 0; attempt < 80; attempt++) {
        if (await _checkHealth()) {
          _ready = true;
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
      throw StateError(
        'O Python local não iniciou. Feche e abra o aplicativo e tente novamente.',
      );
    } finally {
      _starting = null;
    }
  }

  Future<bool> _checkHealth() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(milliseconds: 350);
    try {
      final request = await client.getUrl(_healthUri);
      final response = await request.close().timeout(
            const Duration(milliseconds: 700),
          );
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['ok'] == true) {
        runtimeVersion = decoded['runtime'] as String?;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Future<PythonExecutionResult> run({
    required String code,
    String stdin = '',
  }) async {
    await ensureStarted();
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 2);
    try {
      final request = await client.postUrl(_runUri);
      request.headers.contentType = ContentType.json;
      // The local Python server requires Content-Length. HttpClient.write()
      // can send chunked requests, which the server rejects as an empty body.
      final payload = utf8.encode(jsonEncode({'code': code, 'stdin': stdin}));
      request.contentLength = payload.length;
      request.add(payload);
      final response = await request.close().timeout(
            const Duration(seconds: 7),
          );
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw StateError('O laboratório devolveu uma resposta inválida.');
      }
      return PythonExecutionResult.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } on TimeoutException {
      return const PythonExecutionResult(
        ok: false,
        stdout: '',
        stderr: '',
        error:
            'A execução demorou além do limite. Verifique loops ou operações que não terminam.',
        errorType: 'TimeoutError',
        durationMs: 7000,
      );
    } finally {
      client.close(force: true);
    }
  }
}
