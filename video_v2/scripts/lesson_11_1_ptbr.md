# Aula 11.1 — Git e GitHub: histórico para experimentar com segurança

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai aprender por que Git e GitHub mudam a forma como você experimenta com código. A ideia principal não é decorar comandos. É criar um histórico confiável para poder testar, comparar e corrigir sem medo de perder uma versão que funcionava.

Git é um sistema de controle de versão. Ele registra mudanças do seu projeto em commits. Pense em um commit como um ponto importante do histórico: naquele momento, você decidiu guardar um conjunto coerente de alterações.

Antes de criar um commit, um dos comandos mais úteis é git status. Ele mostra quais arquivos mudaram, quais alterações ainda não foram adicionadas e o estado atual do repositório.

Depois, também é importante conferir o que realmente mudou. Um diff permite comparar versões e perceber se entrou alguma alteração que você não pretendia.

Só então adicionamos os arquivos desejados e criamos um commit com uma mensagem que explica a intenção. Uma mensagem como “feat: adicionar validação de entrada” informa muito mais do que simplesmente escrever “mudancas”.

O histórico fica mais útil quando os commits representam passos compreensíveis. Se você mistura dez assuntos diferentes em um único commit, fica mais difícil descobrir depois qual mudança provocou um problema.

Agora entram as branches. Uma branch é uma linha de trabalho separada. Você pode criar uma branch para desenvolver uma funcionalidade sem mexer diretamente na linha principal do projeto.

Imagine que o programa está funcionando e você quer criar uma calculadora nova. Em vez de alterar tudo na main imediatamente, cria uma branch chamada feat/calculadora. Trabalha, testa, faz commits e compara as mudanças antes de integrar.

Essa separação dá liberdade para experimentar. Se a ideia não funcionar, o histórico anterior continua disponível.

O GitHub entra como um serviço que hospeda o repositório. Ele facilita publicar o projeto, sincronizar o histórico e revisar alterações. Uma pull request deixa explícita a diferença entre uma branch e outra e cria um espaço para revisar antes de integrar.

Existe um erro de hábito que vale observar. Imagine executar git add ponto e git commit “mudancas” sem olhar git status nem conferir o diff. O commit pode funcionar tecnicamente, mas você não verificou o que está registrando. Pode acabar incluindo arquivos ou alterações que não deveriam entrar.

Por isso, crie um pequeno ritual: status, conferir diferenças, adicionar o que faz sentido, conferir novamente e só depois fazer o commit.

Seu desafio será escrever a sequência de comandos para criar uma branch chamada feat/calculadora, mudar para ela, adicionar as alterações e criar um commit. Mais importante do que decorar a sequência é entender em que momento cada passo acontece.

No mini projeto, você vai publicar um projeto completo no GitHub. O repositório deve ter um README explicando o objetivo e como executar. O histórico deve ter commits coerentes. Pelo menos uma funcionalidade será feita em uma branch e revisada pelo diff antes da integração.

Quando você usa Git desse jeito, errar fica menos assustador. Você pode comparar, voltar ao histórico, criar uma nova tentativa e entender como o código evoluiu.

Então guarde esta ideia: Git não serve apenas para “salvar código na nuvem”. Git registra a história do trabalho. E uma história bem organizada permite experimentar com muito mais segurança.

## Cenas previstas
1. Código evoluindo em uma linha do tempo.
2. `git status` mostrando o estado do projeto.
3. Diff destacando mudanças.
4. Commit como ponto do histórico.
5. Mensagem vaga versus mensagem com intenção.
6. Branch separando uma funcionalidade.
7. Main versus `feat/calculadora`.
8. GitHub e pull request como revisão explícita.
9. Mini projeto com README, commits e branch.
