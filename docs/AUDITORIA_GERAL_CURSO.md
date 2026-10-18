# Auditoria geral — Curso de Programação do Zero

Estado: **em andamento — NÃO LIBERAR COMO CURSO 100% VALIDADO**.

Este documento acompanha a qualidade do conteúdo e da experiência do aluno.
Build verde significa que arquivos compilaram e os testes registrados passaram;
não demonstra que todas as perguntas, pistas, aulas e correções estejam corretas.

## Regras obrigatórias de qualidade

1. Nenhuma etapa exige um comando sem explicação e pelo menos um exemplo
   anterior na mesma aula ou em um módulo pré-requisito.
2. Código Python válido não pode ser reprovado por espaço, aspas equivalentes
   ou escolha legítima de nomes. O verificador distingue **sintaxe**, **estrutura**
   e **comportamento observado**; só o último pode demonstrar execução.
3. Programas da aula devem rodar no Python embarcado nas plataformas em que
   o curso promete execução; dependências de rede e terminal externo devem
   ser avisadas **antes** da tentativa.
4. Git usa terminal Git, não Python; plano escrito não passa por compilação Python.
5. Erros de execução mostram a causa ou oferecem uma pista, sem entregar
   automaticamente a solução.
6. Nenhuma mudança pode zerar progresso, apagar versões antigas de vídeos ou
   destruir rascunhos sincronizados.
7. Android e Windows devem passar pela inspeção estática, testes unitários,
   testes de interface, instalação e verificação manual de todas as etapas.

## Revisão inicial por módulo

| Módulo | Foco auditado | Ação na primeira rodada | Evidência manual ainda pendente |
|---|---|---|---|
| 0 | print, aspas, saída, algoritmo | Preservado | Testar exercício, pistas e liberação no celular |
| 1 | atribuição, tipos e nomes de variáveis | Preservado | Testar diferentes códigos corretos e mensagens |
| 2 | if/elif/else, limites, and/or | Explicações e regras de nota/frequência reescritas | Testar 4/5/6/7, frequências 74/75/80 e soluções alternativas |
| 3 | for/while, %, break | Pré-requisitos acrescentados | Testar paridade, loops e encerramento seguro |
| 4 | listas, posições e dicionários | Posição zero e acesso por chaves explicados | Conferir aspas simples/duplas e diferentes nomes |
| 5 | funções, parâmetros e média | Exemplo matemático explicitado | Confirmar diferentes implementações de média |
| 6 | arquivos, erros e imports | Modos de arquivo ensinados; arquivos de texto no espaço privado temporário | Confirmar escrita/leitura entre execuções no Android e Windows |
| 7 | assert e debugging | Significado e exemplos de assert acrescentados | Verificar pistas para assertion failures |
| 8 | HTTP, JSON e APIs | requests não empacotado substituído por urllib.request padrão, com alternativa offline | Testar rede com e sem internet em Android e Windows |
| 9 | SQLite / CRUD | Parâmetros e commit ensinados | Testar banco persistente e instruções SQL no aparelho |
| 10 | classes e ambientes | self, __init__ e desconto exemplificados | Garantir que venv/dependências são identificados como tarefas no computador |
| 11 | Git/GitHub | Corrigir roteamento para não enviar comandos ao Python | Executar em terminal real, verificar alternativas switch/checkout e PR |
| 12 | projeto independente | Planos tratados como texto; rascunho Python separado | Avaliar projetos reais com critérios claros, não apenas palavras-chave |

## Verificações automatizadas acrescentadas

- Integridade das 13 etapas e três perguntas de cada aula.
- Validade sintática e imports autorizados para exemplos Python dos módulos 0–10.
- Regressão do `print ("adulto")` aceito no desafio de decisões.
- Presença da explicação de `and` antes da cobrança no mini projeto.
- Escrita e leitura de texto em arquivo privado e rejeição de caminhos externos.
- API com biblioteca padrão e alternativa offline, sem impor `requests`.
- Comandos Git aceitos por alternativas corretas, ignorando comandos em comentários.
- Planos escritos não enviados ao verificador Python.

## Pendências importantes antes de considerar o retorno ao curso

- Percorrer **manualmente** todas as oito etapas de cada módulo no Android e
  Windows, com códigos corretos variados, erros propositais e retomada.
- Conferir comportamento real do Python empacotado, incluindo arquivos, HTTP
  e SQLite, e não apenas executar o núcleo no runner de CI.
- Auditar e revisar rubricas que ainda analisam fragmentos ou palavras, para
  evitar aprovar códigos que tenham a palavra certa mas o comportamento errado.
- Rever a compatibilidade das videoaulas existentes com as novas explicações,
  preservando lado a lado versões originais e novas.
- Testar sincronização e migração de progresso entre aparelhos reais e versões
  antes de recomendar reinstalar qualquer APK.
- Reavaliar os projetos finais e as atividades externas para não confundir
  relato de teste com teste verificado.

**Critério de conclusão:** não há compromisso de 100% de ausência de bugs.
A liberação deve ocorrer após todas as pendências críticas resolvidas, CI
verde e roteiro de teste manual aprovado.
