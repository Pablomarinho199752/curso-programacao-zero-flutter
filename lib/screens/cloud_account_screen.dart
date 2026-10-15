import 'package:flutter/material.dart';

import '../services/cloud_sync_service.dart';

class CloudAccountScreen extends StatefulWidget {
  const CloudAccountScreen({super.key, required this.cloudSync});

  final CloudSyncService cloudSync;

  @override
  State<CloudAccountScreen> createState() => _CloudAccountScreenState();
}

class _CloudAccountScreenState extends State<CloudAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _creatingAccount = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) return;
      _passwordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.cloudSync.status)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.cloudSync.error ?? 'Não foi possível concluir a ação.'),
        ),
      );
    }
  }

  Future<void> _createAccount() async {
    final password = _passwordController.text;
    if (password != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As duas senhas precisam ser iguais.')),
      );
      return;
    }
    await _run(
      () => widget.cloudSync.createAccount(
        _emailController.text,
        password,
      ),
    );
  }

  Future<void> _resetPassword() async {
    await _run(
      () => widget.cloudSync.sendPasswordReset(_emailController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cloudSync,
      builder: (context, _) {
        final sync = widget.cloudSync;
        final scheme = Theme.of(context).colorScheme;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            Text(
              'Conta e sincronização',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie uma conta uma única vez. Depois, entre com o mesmo e-mail no celular e no computador para continuar exatamente de onde parou.',
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: sync.error == null
                    ? scheme.primaryContainer.withValues(alpha: 0.45)
                    : scheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    sync.signedIn ? Icons.cloud_done_rounded : Icons.cloud_outlined,
                    color: sync.error == null ? scheme.primary : scheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sync.signedIn
                              ? 'Conta conectada${sync.email == null ? '' : ': ${sync.email}'}'
                              : 'Sua conta do curso',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(sync.status),
                        if (sync.error != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            sync.error!,
                            style: TextStyle(color: scheme.onErrorContainer),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (sync.busy)
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (!sync.signedIn) ...[
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.login_rounded),
                    label: Text('Entrar'),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.person_add_alt_1_rounded),
                    label: Text('Criar conta'),
                  ),
                ],
                selected: {_creatingAccount},
                onSelectionChanged: sync.busy
                    ? null
                    : (selection) => setState(() {
                          _creatingAccount = selection.first;
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        }),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                textInputAction:
                    _creatingAccount ? TextInputAction.next : TextInputAction.done,
                autofillHints: _creatingAccount
                    ? const [AutofillHints.newPassword]
                    : const [AutofillHints.password],
                onSubmitted: (_) {
                  if (!_creatingAccount && !sync.busy) {
                    _run(
                      () => sync.signIn(
                        _emailController.text,
                        _passwordController.text,
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: _creatingAccount ? 'Crie uma senha' : 'Senha',
                  helperText: _creatingAccount
                      ? 'Use pelo menos 6 caracteres.'
                      : null,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              if (_creatingAccount) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) {
                    if (!sync.busy) _createAccount();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Confirme a senha',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: sync.busy
                    ? null
                    : _creatingAccount
                        ? _createAccount
                        : () => _run(
                              () => sync.signIn(
                                _emailController.text,
                                _passwordController.text,
                              ),
                            ),
                icon: Icon(
                  _creatingAccount
                      ? Icons.person_add_alt_1_rounded
                      : Icons.login_rounded,
                ),
                label: Text(
                  _creatingAccount
                      ? 'Criar conta e salvar progresso'
                      : 'Entrar e continuar meu curso',
                ),
              ),
              if (!_creatingAccount) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: sync.busy ? null : _resetPassword,
                  child: const Text('Esqueci minha senha'),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                _creatingAccount
                    ? 'Ao criar a conta, o progresso que já está neste aparelho passa a ser vinculado a ela e é enviado para a nuvem.'
                    : 'Sua sessão fica salva com segurança neste aparelho. Ao abrir o app novamente, ele tenta reconectar automaticamente.',
                style: const TextStyle(fontSize: 13),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: sync.busy ? null : sync.syncNow,
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Sincronizar agora'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: sync.busy ? null : sync.signOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sair da conta neste aparelho'),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'O que fica salvo na sua conta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            const _InfoTile(
              icon: Icons.phone_android_rounded,
              title: 'Onde você parou',
              text:
                  'A última aula e a última etapa visitadas ficam sincronizadas para você continuar no outro aparelho.',
            ),
            const _InfoTile(
              icon: Icons.edit_note_rounded,
              title: 'Seu trabalho nas aulas',
              text:
                  'Etapas concluídas, respostas, rascunhos, tentativas e domínio dos módulos são preservados.',
            ),
            const _InfoTile(
              icon: Icons.wifi_off_rounded,
              title: 'Também funciona sem internet',
              text:
                  'Offline, o curso salva neste aparelho. Quando a conexão voltar, a conta tenta sincronizar novamente.',
            ),
            const _InfoTile(
              icon: Icons.merge_rounded,
              title: 'Celular e computador trabalham juntos',
              text:
                  'Os avanços dos dois aparelhos são combinados para evitar perder uma etapa já concluída.',
            ),
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
