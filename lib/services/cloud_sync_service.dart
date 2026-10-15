import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'progress_store.dart';

class CloudSyncService extends ChangeNotifier {
  CloudSyncService(this.progressStore, {http.Client? client})
      : _client = client ?? http.Client() {
    progressStore.addListener(_onLocalProgressChanged);
  }

  static const _apiKey = 'AIzaSyB1I_ko3CZyVYyQk_Fz76qD5Ywi2VfWgtg';
  static const _projectId = 'codigo-zero-avancado';
  static const _documentId = 'flutter_course_v1';
  static const _refreshTokenKey = 'course_cloud_refresh_token_v1';
  static const _userIdKey = 'course_cloud_user_id_v1';
  static const _emailKey = 'course_cloud_email_v1';
  static const _ownerKey = 'course_cloud_local_owner_v1';
  static const _networkTimeout = Duration(seconds: 10);

  final ProgressStore progressStore;
  final http.Client _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Timer? _saveTimer;
  String? _idToken;
  String? _refreshToken;
  String? _userId;
  String? _email;
  String? _localOwnerId;
  DateTime? _tokenExpiresAt;
  String? _lastUploadedJson;
  bool _applyingRemote = false;
  bool _disposed = false;

  bool busy = false;
  String status = 'Progresso salvo neste aparelho.';
  String? error;

  bool get signedIn => _userId != null && _refreshToken != null;
  String? get email => _email;

  Future<void> initialize() async {
    try {
      _localOwnerId = await _secureStorage.read(key: _ownerKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      _userId = await _secureStorage.read(key: _userIdKey);
      _email = await _secureStorage.read(key: _emailKey);
      if (_refreshToken == null || _userId == null) {
        status = 'Entre com a mesma conta no celular e no computador para sincronizar.';
        notifyListeners();
        return;
      }
      await _guardLocalOwner(_userId!);
      busy = true;
      status = 'Reconectando sua conta...';
      notifyListeners();
      await _refreshSession();
      await syncNow();
    } catch (e) {
      error = _friendlyError(e);
      status = 'O progresso local continua seguro neste aparelho.';
      notifyListeners();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> createAccount(String email, String password) async {
    await _authenticate(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
      email,
      password,
      successStatus: 'Conta criada e progresso sincronizado.',
    );
  }

  Future<void> signIn(String email, String password) async {
    await _authenticate(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey',
      email,
      password,
      successStatus: 'Conta conectada e progresso sincronizado.',
    );
  }

  Future<void> sendPasswordReset(String email) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw StateError('Digite o e-mail da sua conta para recuperar a senha.');
    }
    busy = true;
    error = null;
    status = 'Enviando recuperação de senha...';
    notifyListeners();
    try {
      final response = await _client
          .post(
            Uri.parse(
              'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey',
            ),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'requestType': 'PASSWORD_RESET',
              'email': normalizedEmail,
            }),
          )
          .timeout(_networkTimeout);
      _decodeResponse(response);
      status = 'E-mail de recuperação enviado. Confira sua caixa de entrada.';
    } catch (e) {
      error = _friendlyError(e);
      status = 'Não foi possível enviar a recuperação de senha.';
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _authenticate(
    String url,
    String email,
    String password, {
    required String successStatus,
  }) async {
    if (email.trim().isEmpty || password.length < 6) {
      throw StateError('Digite um e-mail válido e uma senha com pelo menos 6 caracteres.');
    }
    busy = true;
    error = null;
    status = 'Conectando sua conta...';
    notifyListeners();
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(_networkTimeout);
      final data = _decodeResponse(response);
      _applyAuthPayload(data);
      await _guardLocalOwner(_userId!);
      await _persistSession();
      await syncNow();
      if (error == null) status = successStatus;
    } catch (e) {
      error = _friendlyError(e);
      status = 'Não foi possível entrar. O progresso local não foi perdido.';
      if (error?.contains('outra conta') == true) {
        await _clearSessionCredentials();
      }
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _guardLocalOwner(String uid) async {
    _localOwnerId ??= await _secureStorage.read(key: _ownerKey);
    final owner = _localOwnerId;
    if (owner != null && owner != uid) {
      throw StateError(
        'Este aparelho já possui progresso vinculado a outra conta. Entre com a conta usada anteriormente para evitar misturar estudos de pessoas diferentes.',
      );
    }
  }

  Future<void> _claimLocalProgressForCurrentUser() async {
    final uid = _userId;
    if (uid == null) return;
    await _guardLocalOwner(uid);
    if (_localOwnerId == null) {
      _localOwnerId = uid;
      await _secureStorage.write(key: _ownerKey, value: uid);
    }
  }

  Future<void> signOut() async {
    _saveTimer?.cancel();
    await _clearSessionCredentials();
    error = null;
    status = 'Você saiu da nuvem. O progresso continua salvo neste aparelho e permanece vinculado a esta conta.';
    notifyListeners();
  }

  Future<void> _clearSessionCredentials() async {
    _idToken = null;
    _refreshToken = null;
    _userId = null;
    _email = null;
    _tokenExpiresAt = null;
    _lastUploadedJson = null;
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _emailKey);
  }

  Future<void> syncNow() async {
    if (!signedIn) return;
    busy = true;
    error = null;
    status = 'Sincronizando progresso...';
    notifyListeners();
    try {
      await _guardLocalOwner(_userId!);
      final token = await _ensureToken();
      final remoteState = await _readRemoteState(token);
      if (remoteState != null) {
        _applyingRemote = true;
        await progressStore.mergeCloudState(remoteState);
        _applyingRemote = false;
      }
      await _writeRemoteState(await _ensureToken());
      await _claimLocalProgressForCurrentUser();
      status = 'Sincronizado. Você pode continuar em outro aparelho.';
    } catch (e) {
      _applyingRemote = false;
      error = _friendlyError(e);
      status = 'Sem sincronização agora. O progresso local continua salvo.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _onLocalProgressChanged() {
    if (_disposed || _applyingRemote || !signedIn) return;
    final snapshot = jsonEncode(progressStore.cloudState());
    if (snapshot == _lastUploadedJson) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1200), () async {
      if (_disposed || _applyingRemote || !signedIn) return;
      try {
        await _guardLocalOwner(_userId!);
        await _writeRemoteState(await _ensureToken());
        await _claimLocalProgressForCurrentUser();
        if (_disposed) return;
        error = null;
        status = 'Progresso salvo na nuvem.';
        notifyListeners();
      } catch (e) {
        if (_disposed) return;
        error = _friendlyError(e);
        status = 'Salvo neste aparelho; a nuvem será tentada novamente.';
        notifyListeners();
      }
    });
  }

  Future<String> _ensureToken() async {
    final expiresAt = _tokenExpiresAt;
    if (_idToken == null ||
        expiresAt == null ||
        DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 1)))) {
      await _refreshSession();
    }
    final token = _idToken;
    if (token == null) throw StateError('Sessão indisponível. Entre novamente.');
    return token;
  }

  Future<void> _refreshSession() async {
    final refresh = _refreshToken;
    if (refresh == null) throw StateError('Sessão expirada. Entre novamente.');
    final response = await _client
        .post(
          Uri.parse('https://securetoken.googleapis.com/v1/token?key=$_apiKey'),
          headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'refresh_token',
            'refresh_token': refresh,
          },
        )
        .timeout(_networkTimeout);
    final data = _decodeResponse(response);
    _idToken = data['id_token'] as String?;
    _refreshToken = data['refresh_token'] as String? ?? _refreshToken;
    _userId = data['user_id'] as String? ?? _userId;
    if (_userId != null) await _guardLocalOwner(_userId!);
    final seconds = int.tryParse('${data['expires_in'] ?? 3600}') ?? 3600;
    _tokenExpiresAt = DateTime.now().add(Duration(seconds: seconds));
    await _persistSession();
  }

  void _applyAuthPayload(Map<String, dynamic> data) {
    _idToken = data['idToken'] as String?;
    _refreshToken = data['refreshToken'] as String?;
    _userId = data['localId'] as String?;
    _email = data['email'] as String? ?? _email;
    final seconds = int.tryParse('${data['expiresIn'] ?? 3600}') ?? 3600;
    _tokenExpiresAt = DateTime.now().add(Duration(seconds: seconds));
    if (_idToken == null || _refreshToken == null || _userId == null) {
      throw StateError('O Firebase não devolveu uma sessão completa.');
    }
  }

  Future<void> _persistSession() async {
    final refresh = _refreshToken;
    final uid = _userId;
    if (refresh != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refresh);
    }
    if (uid != null) {
      await _secureStorage.write(key: _userIdKey, value: uid);
    }
    if (_email != null) {
      await _secureStorage.write(key: _emailKey, value: _email);
    }
  }

  Uri get _documentUri => Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users/$_userId/progress/$_documentId',
      );

  Future<Map<String, dynamic>?> _readRemoteState(String token) async {
    final response = await _client
        .get(
          _documentUri,
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(_networkTimeout);
    if (response.statusCode == 404) return null;
    final data = _decodeResponse(response);
    final fields = data['fields'];
    if (fields is! Map) return null;
    final stateField = fields['stateJson'];
    if (stateField is! Map) return null;
    final raw = stateField['stringValue'];
    if (raw is! String || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
  }

  Future<void> _writeRemoteState(String token) async {
    final state = progressStore.cloudState();
    final stateJson = jsonEncode(state);
    final response = await _client
        .patch(
          _documentUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'fields': {
              'schemaVersion': {'integerValue': '2'},
              'stateJson': {'stringValue': stateJson},
              'updatedAtMs': {
                'integerValue': '${progressStore.updatedAtMs}',
              },
            },
          }),
        )
        .timeout(_networkTimeout);
    _decodeResponse(response);
    _lastUploadedJson = stateJson;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic> data = {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) data = Map<String, dynamic>.from(decoded);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    final errorData = data['error'];
    if (errorData is Map) {
      final message = errorData['message'];
      if (message is String) throw StateError(message);
    }
    throw StateError('Erro de rede ${response.statusCode}.');
  }

  String _friendlyError(Object error) {
    final raw = error.toString();
    if (error is TimeoutException) return 'A nuvem demorou para responder.';
    if (raw.contains('outra conta')) {
      return 'Este aparelho já possui progresso de outra conta. Entre com a conta usada anteriormente para não misturar os estudos.';
    }
    if (raw.contains('EMAIL_EXISTS')) {
      return 'Esse e-mail já tem conta. Use Entrar.';
    }
    if (raw.contains('INVALID_LOGIN_CREDENTIALS') ||
        raw.contains('INVALID_PASSWORD') ||
        raw.contains('EMAIL_NOT_FOUND')) {
      return 'E-mail ou senha incorretos.';
    }
    if (raw.contains('INVALID_EMAIL')) return 'Digite um e-mail válido.';
    if (raw.contains('WEAK_PASSWORD')) {
      return 'Use uma senha com pelo menos 6 caracteres.';
    }
    if (raw.contains('PERMISSION_DENIED')) {
      return 'A conta entrou, mas as regras da nuvem ainda não liberaram este curso.';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'Sem internet no momento.';
    }
    return raw.replaceFirst('Bad state: ', '');
  }

  @override
  void dispose() {
    _disposed = true;
    _saveTimer?.cancel();
    progressStore.removeListener(_onLocalProgressChanged);
    _client.close();
    super.dispose();
  }
}
