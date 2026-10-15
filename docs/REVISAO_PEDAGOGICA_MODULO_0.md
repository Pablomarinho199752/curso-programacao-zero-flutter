# Módulo 0 — revisão antes da próxima versão

Estado: proposta para revisão. Não publicar tag/release nem iniciar o Módulo 1 antes da validação pedagógica.

## Intenção

Uma aula, oito etapas. Para quem nunca programou, sem instalação de Python e sem conceitos de variáveis, condições ou repetição. O app usa Flutter; o conteúdo introdutório usa Python. Tempo sugerido: blocos de 10 minutos, no ritmo do aluno, sem cronômetro nem cobrança.

## Percurso e evidências

| Etapa | O aluno faz | O que permite continuar |
| --- | --- | --- |
| Explicação curta | Entende algoritmo, código, programa e print | Confirma que entendeu a proposta |
| Videoaula | Assiste à introdução existente ou lê alternativa offline | Confirma consumo; abrir link não conta |
| Exemplo | Prevê mentalmente duas saídas e executa | Executa o exemplo no simulador |
| Prática | Escreve a saída prevista | Acerta o texto, com pistas em tentativas erradas |
| Desafio | Planeja o robô em português | Registra 4–6 passos em linhas separadas |
| Correção | Revisa seu plano e corrige o parêntese ausente | Autoavalia 3 critérios e executa os dois textos originais |
| Mini projeto | Cria cartão com apelido e objetivo | Executa dois textos próprios e autoavalia 2 critérios |
| Revisão | Responde 3 perguntas e reflete | 3 acertos e reflexão de pelo menos 3 palavras |

Os limites de linhas/palavras são verificações de preenchimento, não avaliação semântica. O app não afirma que o aluno domina programação. A autoavaliação do algoritmo e a reflexão precisam de revisão humana/ChatGPT. O laboratório simula somente `print` de texto simples, uma instrução por linha. Não é interpretador Python. Aceita aspas simples ou duplas pareadas; não aceita escapes nem aspas dentro do texto.

## Decisões a validar no ChatGPT

1. A explicação deixa clara a diferença entre plano, código e execução?
2. O aluno consegue prever a saída sem decorar o exemplo?
3. O cenário do robô é concreto o suficiente? Os critérios ajudam a detectar ambiguidades?
4. As pistas orientam sem entregar a solução imediatamente?
5. O cartão demonstra transferência para dois textos próprios?
6. O aluno consegue explicar a correção e apontar uma dúvida real?
7. A videoaula existente cobre a introdução e usa linguagem adequada? Seu conteúdo audiovisual ainda precisa de revisão humana; não foi substituído nem certificado nesta mudança.

## Prompt para a revisão

> Revise o Módulo 0 abaixo como experiência para um aluno que nunca programou. Avalie clareza, carga de informação, sequência, qualidade das pistas e evidências de compreensão. Não avance para o Módulo 1. Primeiro identifique problemas pedagógicos concretos e sugira apenas os ajustes necessários. O app distingue autoavaliação de validação automática e usa um simulador limitado de print.

Cole o conteúdo de `docs/MODULO_0.md` junto com esse prompt. Para revisar um aluno real, ele pode usar **Copiar minha revisão para o ChatGPT** na etapa final. Isso copia o relatório local; não envia mensagens ou respostas automaticamente.

## Critério para aprovar a próxima versão

- [ ] Revisar integralmente conteúdo, vídeo, pistas e gabaritos.
- [ ] Realizar o percurso com um iniciante e identificar onde precisa de ajuda.
- [ ] Executar checklist técnico de Android e Windows.
- [ ] Resolver dúvidas pedagógicas e aprovar a versão explicitamente.

Sem nova aula e sem Módulo 1 nesta proposta.
