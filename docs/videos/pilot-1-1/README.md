# Piloto audiovisual 1.1 — Código Zero
Data: 2026-10-15. Base: `feat/python-lab-cloud-progress`, commit `9d5e95b4888fc007e8a5bce97872d078082de1dd` (PR #4).
## Estado
Piloto ainda NÃO renderizado. Prévia visual em `preview.html`; roteiro integral em `pilot-script.json`.
Título proposto: **Variáveis: nomes para os dados**.
Módulo 1, aula `lesson_1_1` — Valores e variáveis: dando nome aos dados.
Duração alvo: 3–7 minutos (estimativa 4–5); duração real: pendente.
Link final: pendente. Link antigo preservado: https://share.descript.com/view/LYmNVlmGLyW
Ferramentas tentadas: Descript Agent Underlord (bloqueado por créditos de IA insuficientes); HeyGen síntese (bloqueada: workspace exige Orca, chamada Starfish rejeitada). Nenhum áudio/vídeo novo gerado.
Voz candidata: Will, `f8ae4c0d76fa4f5ebd133bbef14e1c67`, catálogo português. Ainda não sintetizada nem aprovada. Não fixar como padrão sem ouvir a voz.
Não houve uso de Runway ou renderização no Higgsfield. Não houve cobrança/compra autorizada.
Próximo passo: confirmar nova tentativa de síntese HeyGen com motor compatível após erro; produzir e avaliar o piloto completo antes dos demais vídeos.

## Auditoria
Lidos: modules.json, module_1_lessons.json, module_2_12_lessons.json, video_urls.json, course_repository.dart e documentação audiovisual.
A branch mais completa incorpora conta e laboratório; os quatro arquivos de conteúdo têm os mesmos blobs da main neste instante.
Existem **13 aulas carregadas, uma por módulo (0–12)**. Todos os 13 links efetivos responderam HTTP 200 em HEAD. Isso verifica disponibilidade HTTP, não reprodução, áudio ou aderência pedagógica integral.
Em módulos 2–12, videoUrl vazio no JSON da aula é preenchido pelo mapa video_urls.json; não é ausência de vídeo no app.
Nenhuma URL provisória aparente entre os links efetivos. Os IDs antigos de render dos módulos 3–12 não identificam os MP4s efetivamente usados: conforme VIDEO_PRODUCTION.md, tentativas HeyGen falharam e foram substituídas por vídeos narrados hospedados no Higgsfield.
Aula 1.1: projeto publicado `dc7f72a3-669b-4791-9e36-142478ef1e07`, composição de **45,96 s**, é só abertura e não demonstra todo o objetivo da aula. Transcrição consultada.
Outra versão no Descript: `ed4741bc-1e8e-48fa-a83b-07f83570c521`, **233,92 s**, sem publicação. A transcrição mistura variáveis, input e conversões, além do foco da aula atual.
Módulo 0: publicação existente confirmada pelo Descript, duração **235,76 s**. Aderência visual completa ainda pendente.
Módulos 2–12: URLs disponíveis; revisão audiovisual detalhada fica para os lotes após aprovação do piloto. Não afirmar que o conteúdo deles foi assistido ou aprovado.
Inventário completo e URLs preservadas: inventory.json.

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

## Relatório do lote
Criados: roteiro, padrão reutilizável, inventário e storyboard interativo.
Vídeos criados: 0. Substituídos: 0.
Faltam: render e validação do piloto 1.1; depois, refação das demais 12 aulas, uma etapa por vez conforme aprovação.
Bloqueios: créditos Descript; incompatibilidade de motor da síntese HeyGen.
Ação do usuário: autorizar nova tentativa HeyGen com Orca; avaliar piloto renderizado antes de continuar.
