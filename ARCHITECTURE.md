# Arquitetura — Módulo 0

Flutter + JSON local + ChangeNotifier + SharedPreferences. Sem backend ou framework extra de estado.

- `assets/content/modules.json`: uma aula com conteúdo das oito etapas, pistas, critérios e três perguntas.
- `lib/models`: modelos do conteúdo; os complementos do onboarding ficam no bloco JSON `onboarding`.
- `lib/data`: leitura do conteúdo empacotado.
- `lib/services/progress_store.dart`: respostas, critérios, tentativas, etapa atual e etapas concluídas; escrita serializada e recuperável.
- `lib/services/print_lab.dart`: simulador puro e restrito a print de texto. Nunca executa comandos arbitrários.
- `lib/screens/lesson_screen.dart`: percurso guiado; validações de tarefa, pistas e relatório copiável.
- `lib/screens`: início, módulos e progresso reagem ao mesmo store.
- `.github/workflows`: análise, testes e builds em SDK fixo; publicação continua separada por tag.

O progresso conta etapas concluídas, não cliques em links nem apenas quiz. Etapas futuras exigem as anteriores; todas as etapas já alcançadas podem ser revisitadas. Uma edição invalida a conclusão da atividade e das posteriores, sem apagar os rascunhos. A marcação “Percurso concluído” não certifica domínio. A avaliação de textos abertos é explícita como autoavaliação.

Plataformas Android/Windows são geradas por `scripts/bootstrap.*` ou CI para manter o repositório simples. Evitar múltiplos pacotes, roteador ou serviço remoto enquanto o Módulo 0 está em validação.
