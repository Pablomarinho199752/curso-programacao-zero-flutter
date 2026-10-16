# Continuação do Work — videoaulas 6 a 12

Este arquivo existe para o Work retomar a produção sem reler o histórico inteiro do projeto.

## Base correta

- Sempre atualizar a partir da `main` antes de produzir ou integrar vídeos.
- A branch preparada para a continuação é `feat/video-juno-6-12`.
- No momento em que este arquivo foi criado, essa branch estava idêntica à `main`, sem commits próprios.
- Não recuperar código antigo do app a partir de `feat/python-lab-cloud-progress` ou `feat/video-pilot-1-1`.
- Os PRs antigos #4 e #5 foram encerrados como substituídos e existem apenas como histórico.

## Estado audiovisual confirmado

Já estão integrados na `main`:

- `lesson_0_1`
- `lesson_1_1`
- `lesson_2_1`
- `lesson_3_1`
- `lesson_4_1`
- `lesson_5_1`

Os links anteriores foram preservados nos pacotes e metadados de produção.

Ainda precisam de nova produção:

- `lesson_6_1`
- `lesson_7_1`
- `lesson_8_1`
- `lesson_9_1`
- `lesson_10_1`
- `lesson_11_1`
- `lesson_12_1`

A pauta detalhada de cada uma já está em `docs/videos/batch-maya/README.md`. Não reinventar o conteúdo sem primeiro comparar com a aula atual da `main`.

## Voz e padrão

- Português do Brasil.
- Manter a identidade visual já aprovada no lote anterior.
- Preferência atual de voz: **Juno Female**, quando a ferramenta conectada disponibilizar essa voz com qualidade adequada em PT-BR.
- Se Juno não estiver disponível, usar a melhor voz feminina natural disponível, sem mudar o estilo visual do lote.
- Não comprar créditos, mudar plano ou autorizar cobrança sem aprovação do usuário.
- Alvo de 3 a 7 minutos por aula.
- Uma ideia principal por vídeo.
- Sempre mostrar código passo a passo, execução, resultado, um erro real, investigação e correção.
- Encerrar com uma pergunta que o vídeo não responde.

## Regras para integração

O Work pode alterar apenas:

- `assets/content/video_urls.json`, quando houver novo vídeo validado;
- `docs/videos/...`, para roteiros, storyboards, SRT, metadados, relatórios e fontes do vídeo.

Não alterar nesta tarefa:

- Firebase;
- autenticação;
- sincronização;
- progresso;
- revisão espaçada;
- projetos cumulativos;
- laboratório Python;
- navegação;
- tema claro/escuro;
- lógica pedagógica das aulas.

## Validação obrigatória antes de trocar um link

1. Assistir ao render completo.
2. Conferir voz, pronúncia e sincronismo das legendas.
3. Conferir legibilidade do código em tela pequena.
4. Executar os exemplos Python mostrados no vídeo.
5. Confirmar que não entrega a solução do desafio da aula.
6. Confirmar URL pública estável, sem login.
7. Preservar o link anterior nos metadados.
8. Integrar em PR separado com escopo apenas audiovisual.

## Bloqueio anterior

O lote anterior consumiu praticamente todo o saldo de narração do Runway e parou com os módulos 6–12 pendentes. Ao retomar, primeiro conferir quais ferramentas e créditos estão realmente disponíveis; não assumir que o saldo antigo continua igual.
