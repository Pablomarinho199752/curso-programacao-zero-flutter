# Lote Maya — estado e continuidade

Autorização do usuário: avançar em todas as videoaulas usando o padrão aprovado, sem compra de créditos. Base de conteúdo: `c1ef42fe1fdaa17ac747bcb2769960b3e6bb91f8`.

## Orçamento
Saldo inicial Runway: 330. Cinco narrações geradas: módulo 0 (62), 2 (65), 3 (66), 4 (67), 5 (67), total 327. Saldo após geração: 3. Montagem via Higgsedit; não há valor de cobrança confirmado para esse processamento. Não gerar novas vozes sem saldo suficiente; manter Maya, PT-BR, velocidade 1.

## Produção deste lote
Piloto 1.1 já aprovado. Aulas 0.1, 2.1, 3.1, 4.1 e 5.1: roteiro e storyboard salvos por aula; vídeos finais renderizados, legendados, validados e hospedados. Links integrados ao curso no PR #7; os anteriores permanecem nos metadados.

## Continuidade: módulos 6 a 12
Os itens abaixo são pautas de produção, não roteiros finais nem vídeos renderizados. Antes da geração, conferir novamente a main e escrever a narração completa; alvo 3–7 minutos, código executado, erro reproduzido, hipótese, correção e pergunta final. Nas aulas de APIs, SQLite, venv e Git, consultar documentação oficial vigente ao detalhar comandos. Preservar os links anteriores até validar os novos.

### Aula 6.1
- Foco: Persistência: o arquivo continua depois da execução.
- Demonstração: Preferência de volume salva em configuracao.txt; comparar execução inicial e nova execução.
- Erro e investigação: Abrir em modo w para ler trunca o conteúdo; reproduzir apenas em arquivo temporário, comparar modos r/w e corrigir.
- Limites: Não usar tarefas.txt, notas.txt nem entregar o gerenciador do desafio.
- Pergunta final sem resposta: Com arquivo já existente, o que deve mudar se a próxima execução usar somente r?
- Estado: aguarda roteiro detalhado e saldo de narração; nenhum render/link novo.

### Aula 7.1
- Foco: Depurar com um teste que falha.
- Demonstração: Conversão de centímetros para metros; esperado versus observado e assert com 0, 50 e 100.
- Erro e investigação: Divisão por 10 em vez de 100; formular hipótese, corrigir um fator e repetir os testes.
- Limites: Não usar desconto, eh_par ou maior dos exercícios.
- Pergunta final sem resposta: Um teste que passa com zero basta para confiar na conversão?
- Estado: aguarda roteiro detalhado e saldo de narração; nenhum render/link novo.

### Aula 8.1
- Foco: Ler um JSON seguindo seu contrato.
- Demonstração: Contrato fictício identificado para biblioteca: objeto acervo contendo itens com titulo; json.loads em Python e acesso guiado.
- Erro e investigação: Confundir objeto com lista e acessar um índice no nível errado; inspecionar tipo e chaves antes de corrigir.
- Limites: Não fingir chamada HTTP real; não usar o endpoint placeholder example.com nem resolver buscar_dados.
- Pergunta final sem resposta: Se o contrato permitir lista vazia, o acesso ao primeiro item ainda será seguro?
- Estado: aguarda roteiro detalhado e saldo de narração; nenhum render/link novo.

### Aula 9.1
- Foco: Um registro entre duas execuções.
- Demonstração: Tabela temporária salas(id, nome); inserir, consultar, atualizar e excluir apenas registro de demonstração com parâmetros.
- Erro e investigação: Encerrar uma transação sem commit e observar a alteração ausente ao reabrir; corrigir e repetir.
- Limites: Banco temporário isolado; não mexer no Firebase nem usar tabela tarefas do desafio.
- Pergunta final sem resposta: Como você confirmaria que uma atualização permaneceu depois de fechar a conexão?
- Estado: aguarda roteiro detalhado e saldo de narração; nenhum render/link novo.

### Aula 10.1
- Foco: Um objeto reúne estado e comportamento.
- Demonstração: Classe Temporizador com segundos_restantes e método avancar; comparar duas instâncias independentes.
- Erro e investigação: Alterar variável local em vez de self.segundos_restantes; observar estado que não muda e corrigir referência.
- Limites: Não usar Produto, Usuario ou Tarefa dos exercícios; mencionar venv sem transformar em tutorial de instalação.
- Pergunta final sem resposta: Se criarmos dois objetos, avançar um precisa mudar o estado do outro?
- Estado: aguarda roteiro detalhado e saldo de narração; nenhum render/link novo.

### Aula 11.1
- Foco: Revisar o que vai entrar no commit.
- Demonstração: Repositório descartável local; mudar mensagem em aviso.py, status, diff, add de arquivo explícito, diff --staged e commit.
- Erro e investigação: Editar novamente depois de git add; comparar diff com diff --staged e corrigir seleção antes do commit.
- Limites: Nenhum push em conta real; branch exemplo diferente de feat/calculadora; não entregar sequência pronta do desafio.
- Pergunta final sem resposta: Salvar no editor depois de git add atualiza automaticamente o que está preparado para o commit?
- Estado: aguarda roteiro detalhado e saldo de narração; nenhum render/link novo.

### Aula 12.1
- Foco: Transformar uma dúvida em um experimento.
- Demonstração: Requisito pequeno: ordenar três horários representados como números; planejar teste e consultar comportamento de sorted.
- Erro e investigação: Confundir retorno de sorted com modificação da lista original; executar experimento e registrar evidência.
- Limites: Não criar projeto final pronto nem dar resposta às perguntas do curso; código curto serve só ao método.
- Pergunta final sem resposta: Que experimento pequeno separaria uma suposição de algo que você verificou?
- Estado: aguarda roteiro detalhado e saldo de narração; nenhum render/link novo.

## Reprodução do lote
A composição comum está em edit.jsx. Cada pacote de fontes inclui áudio, roteiro, clock de legendas, SRT, projeto e relatório. Ajuste LESSON_ROOT para a pasta extraída e execute higgsedit build edit.jsx. A duração e os cortes vêm da fala transcrita, não de tempo estimado. Reutilize as fontes Inter e JetBrains Mono. Nenhum arquivo do app além de video_urls.json deve mudar.

## Vídeos entregues

| Aula | Duração | Vídeo | Fontes |
|---|---|---|---|
| 0.1 | 3:26 | [MP4](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/17238b76-e402-475f-8ed5-9a5cb28ca63c.mp4) | [ZIP](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/3be5566e-12c5-47ac-90c1-3eef65e256f3.zip) |
| 2.1 | 3:47 | [MP4](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/4c21fbf3-33ed-4a95-b957-9d6bddcf3304.mp4) | [ZIP](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/bc908764-b767-4cea-97f3-26786aa3c733.zip) |
| 3.1 | 3:39 | [MP4](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/8b74769f-4f27-44e4-bdee-33cf5775a81d.mp4) | [ZIP](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/e6ba2529-f1fa-4efa-b840-4b442150829a.zip) |
| 4.1 | 3:54 | [MP4](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/60eeb04d-1cf8-4232-bd5f-690604440472.mp4) | [ZIP](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/49a1bad3-5145-453f-b712-8eb661f9ef20.zip) |
| 5.1 | 3:49 | [MP4](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/64145054-9e99-4cf1-82de-465d04b77280.mp4) | [ZIP](https://d2ol7oe51mr4n9.cloudfront.net/user_3Ke119x65sh4FYjNFHHZNJMSh6l/e55911aa-c71e-4029-818e-138d3bbd6743.zip) |

Validação: 100% das palavras dos cinco roteiros nas legendas; similaridade de transcrição entre 93,75% e 99,02%; durações de áudio/vídeo compatíveis; quadros com legendas e código inspecionados; indentação visual corrigida; exemplos executados em Python. Todos os MP4 finais responderam HTTP 200, video/mp4, sem login. Teste de reprodução em dispositivos Android/Windows ainda não realizado.

Criados neste lote: 5. Substituições de links neste lote: 5, mais o piloto 1.1 aprovado anteriormente. Total no novo padrão: 6 de 13. Restantes: módulos 6 a 12. O bloqueio é saldo para novas narrações, não autorização do usuário.
