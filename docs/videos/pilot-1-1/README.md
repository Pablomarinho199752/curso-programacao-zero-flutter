# Piloto 1.1 — Variáveis: nomes para os dados

**Renderizado, legendado e aprovado pelo usuário. Link integrado no PR #7.**

- [Assistir ao piloto MP4](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/3625e808-0782-4707-8583-f32a9ec65657.mp4)
- [Baixar fontes completas, narração, legendas e projeto](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/16458efd-0bc7-420c-b110-a757a73f0276.zip)
- Aula: `lesson_1_1`, módulo 1.
- Duração: **3min58s** (238,084 s). Formato: 1920×1080, 24 fps, H.264/AAC.
- Narração: Runway, voz Maya, português brasileiro, velocidade 1,0.
- Montagem: Higgsfield/Higgsedit. Legendas: faster-whisper e burner clean.
- Roteiro: `pilot-script.json`. Storyboard inicial: `preview.html`. Composição: `edit.jsx`. Metadados: `metadata.json`.
- Link antigo preservado: https://share.descript.com/view/LYmNVlmGLyW

## Revisão de voz
O usuário gostou do visual e pediu uma voz feminina mais jovem. Esta revisão usa Maya, de perfil jovem e conversacional. Roteiro e identidade visual preservados; cenas e legendas reconstruídas para o novo áudio.
[Versão anterior com Leslie](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/704de7de-edc4-45f5-a2e0-3c6785fb31c2.mp4) preservada para comparação. Metadados anteriores em `revisions/v1.json`.
A voz Maya foi aprovada pelo usuário em 2026-10-15. Nenhum outro módulo foi produzido.

## Base atual e preservação
Nova branch `feat/video-pilot-main-20261015` criada diretamente da main `c1ef42fe1fdaa17ac747bcb2769960b3e6bb91f8`.
Somente `docs/videos/pilot-1-1/` foi replicado da branch antiga. A branch `feat/video-pilot-1-1` continua intacta.
Integração limitada ao override lesson_1_1 em assets/content/video_urls.json; Firebase, progresso, Python, navegação e lógica pedagógica preservados.
O arquivo da aula 1.1 na main mantém o mesmo conteúdo usado no roteiro (blob `96ebe507eff4d4837a511d4b27d2cc0c3d36a00b`).
Link ativo da aula 1.1 atualizado no PR #7 após aprovação. Endereço original preservado no conteúdo da aula e nos metadados.

## Validação realizada
- Saídas dos exemplos e NameError conferidos em execução Python.
- Áudio e vídeo chegam ao final; diferença de duração inferior a 0,2 s.
- Legendas contêm todas as 566 palavras do roteiro; similaridade da transcrição 96,82%.
- Imagens conferidas em 1s, 109,28s, 182,14s e 232,08s: legendas visíveis, código e saída separados, erro ampliado e pergunta final sem resposta.
- Uploads concluídos com HTTP 200 e confirmados no Higgsfield.
- Não houve teste de reprodução no app instalado em Android ou Windows, a voz e o estilo foram aprovados pelo usuário. A reprodução nos dispositivos continua pendente.
- Demonstração é ilustrada, não gravação da interface do app.

## Histórico e limites
Descript bloqueou por créditos insuficientes. HeyGen rejeitou Starfish; a tentativa autorizada com Orca terminou em timeout sem retornar áudio.
Runway concluiu a narração, consumindo 68 créditos na geração registrada. O Higgsedit renderizou o master; o primeiro envio falhou por caminho relativo incorreto, resolvido nesta retomada.
A versão legendada e o pacote de fontes estão agora hospedados. Não há bloqueio de crédito para entregar este piloto; limites de gerações futuras serão verificados antes de cada lote.

## Reproduzir e editar
Extraia o pacote de fontes. Ele inclui narração, clock.json, probe.json, roteiro, SRT, relatório de validação e projeto nativo.
Ajuste a constante `root` em edit.jsx ao diretório extraído. No ambiente com Higgsedit:
1. Registre Inter:400 e JetBrains Mono:400 em `project`.
2. Execute `higgsedit build edit.jsx`.
3. Renderize com caminho absoluto: `higgsedit render project --out /caminho/absoluto/master.mp4 --workers 4 --bitrate 3M`.
4. Use o SRT alinhado para gravar legendas com o burner fornecido no workflow; se alterar a voz, transcreva e valide novamente.
O projeto contém caminhos do ambiente original; ajuste-os ao importar em outro ambiente.
O inventário de links é o levantamento inicial de 2026-10-15; disponibilidade HTTP não equivale a revisão audiovisual completa dos outros módulos.

## Padrão reutilizável de roteiro
1. Identificar módulo/aula, SHA de origem, objetivo único e pré-requisitos.
2. Ler prática, desafio, correção e mini projeto para evitar spoilers. Usar dados diferentes dos exercícios.
3. Gancho concreto (15–25 s): uma situação cotidiana e uma pergunta.
4. Modelo mental (30–50 s): um conceito, termos simples e visual correspondente.
5. Demonstração (60–100 s): escrever código em etapas, explicar cada parte, fazer previsão, executar e mostrar saída verificada.
6. Erro comum (45–75 s): reproduzir, observar linha/mensagem, comparar esperado e observado, formular hipótese, alterar um detalhe e executar novamente.
7. Retomada e previsão final (20–35 s): uma pergunta sem resposta e retorno explícito à prática no app.
As faixas são orientativas, não somar silêncio para atingir duração. Alvo 3–7 min, um assunto principal.
Preservar no app: explicação curta → videoaula → exemplo → prática → desafio → correção → mini projeto → revisão. O vídeo não entrega nem substitui o desafio.
Para módulos amplos, propor capítulos focados sem mudar estrutura/IDs das aulas antes de revisar o plano.

## Padrão visual e sonoro proposto
16:9, 1920×1080, fundo #101827, painel #18253B, ciano #55D9E8, lilás #B69CFF, texto claro. Código monoespaçado, grande, sem geração de letras por modelo de imagem.
Editor e saída identificados; cursor visível, destaque na linha e zoom em detalhes. Demonstração ilustrada identificada como tal, sem fingir gravação do app.
Uma voz PT-BR, ritmo confortável; sem avatar no storyboard proposto, sem música ou efeitos distrativos.
Legendas sincronizadas em português, até duas linhas, margem segura e sem sobrepor código. Na prévia HTML existe narração escrita, mas NÃO existem áudio ou legendas sincronizadas.
Registrar voz/ID e parâmetros após validação para reutilizar nos lotes seguintes.

## Verificação do código do piloto
Executado em Python local real:
- produto = "Suco"; quantidade = 2; preco = 4.5; prints → Suco / 2 / 4.5.
- print("produto") e print(produto) → produto / Suco.
- print(Produto) após criar produto → NameError na linha 2.
- Corrigir P para p → Suco.
- Previsão final verificada internamente; não mostrar resposta no vídeo nem na prévia.
Não são exemplos copiados dos desafios atuais. Não mostrar soluções de prática, desafio, quiz ou mini projeto.

## Critérios antes da integração
- Assistir ao render inteiro, ouvir pronúncia e conferir sincronismo, código e legendas.
- Verificar legibilidade em celular, pausas, cursor, execução, erro e pergunta final.
- Confirmar duração real e URL durável acessível sem login; testar reprodução Android/Windows.
- Receber aprovação do usuário para o estilo do piloto antes de qualquer produção em lote.
- Arquivar link antigo com data e motivo; só então adicionar override de lesson_1_1 em video_urls.json para URL validada.
- Atualizar título/guia de vídeo somente se necessário para a nova videoaula.
Não alterar progresso, conta, Firebase, laboratório Python ou lógica pedagógica.



## Resultado deste lote
Criado: 1 piloto legendado da aula 1.1.
Links atualizados no PR: 1 (lesson_1_1).
Restantes: demais 12 aulas; estilo aprovado, novas gerações dependem de orçamento de créditos.
Próximo passo: Módulo 0; informar orçamento antes de gerar narração.
