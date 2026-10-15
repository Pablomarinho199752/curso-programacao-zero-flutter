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
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) return;
      _passwordController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.cloudSync.error ?? 'Não foi possível concluir a ação.'),
        ),
      );
    }
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
              'Seu progresso continua salvo no aparelho mesmo sem internet. Ao entrar com a mesma conta no celular e no computador, o curso combina os dois progressos e retoma de onde você parou.',
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
                              : 'Sincronização opcional',
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
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) {
                  if (!sync.busy) {
                    _run(
                      () => sync.signIn(
                        _emailController.text,
                        _passwordController.text,
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Senha',
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
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: sync.busy
                    ? null
                    : () => _run(
                          () => sync.signIn(
                            _emailController.text,
                            _passwordController.text,
                          ),
                        ),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Entrar e sincronizar'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: sync.busy
                    ? null
                    : () => _run(
                          () => sync.createAccount(
                            _emailController.text,
                            _passwordController.text,
                          ),
                        ),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Criar conta para sincronizar'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Use uma senha própria para esta conta do curso. O token de sessão fica no armazenamento seguro do Android/Windows; sua senha não é guardada pelo aplicativo.',
                style: TextStyle(fontSize: 13),
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
              'Como funciona',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            const _InfoTile(
              icon: Icons.phone_android_rounded,
              title: 'Continue em qualquer aparelho',
              text:
                  'Entre com a mesma conta. Aulas concluídas, respostas, rascunhos, tentativas, domínio dos módulos e a última etapa visitada são combinados.',
            ),
            const _InfoTile(
              icon: Icons.wifi_off_rounded,
              title: 'Funciona offline',
              text:
                  'Sem internet, o curso continua salvando localmente. Quando a conexão voltar e a conta estiver conectada, o app tenta enviar o progresso novamente.',
            ),
            const _InfoTile(
              icon: Icons.merge_rounded,
              title: 'Não joga fora o avanço de outro aparelho',
              text:
                  'Etapas concluídas são unidas. Tentativas usam o maior valor. Rascunhos mais recentes vencem conflitos para evitar voltar para uma versão antiga.',
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
