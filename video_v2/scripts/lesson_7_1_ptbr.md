# Aula 7.1 — Debugging e testes: transformar erro em evidência

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai aprender a investigar bugs de um jeito mais organizado. Em vez de tentar mudanças aleatórias até o código funcionar, vamos transformar o erro em evidência.

Debugging começa por uma pergunta simples: eu consigo reproduzir o problema? Se o erro aparece uma vez e depois some, fica difícil descobrir a causa. Por isso, primeiro usamos uma entrada que faça o bug acontecer de forma confiável.

Depois formulamos uma hipótese. Por exemplo: “acho que a função está devolvendo o valor errado quando o segundo número é maior”. Uma hipótese é melhor do que simplesmente pensar “o código está quebrado”, porque podemos criar um teste específico para confirmar ou negar essa ideia.

Vamos olhar uma função simples chamada eh_par. Ela recebe um número e retorna se numero módulo dois é igual a zero. Depois escrevemos assert eh_par quatro igual a True e assert eh_par cinco igual a False.

O assert compara o que esperamos com o que o código realmente produz. Se a condição for verdadeira, o programa continua. Se for falsa, o teste falha e nos mostra que alguma coisa não está de acordo com o esperado.

Isso nos dá uma rede de segurança. Imagine que a função funciona hoje. Amanhã você reorganiza o código e, sem perceber, muda o comportamento. Se os testes continuarem ali, basta executá-los de novo para descobrir que algo que antes funcionava agora quebrou.

Agora observe uma função com bug. Def maior recebe a e b. Se a for maior que b, retorna a. Depois, fora do if, retorna a novamente. Perceba o problema: mesmo quando b é maior, a função ainda devolve a.

Em vez de adivinhar, podemos criar testes. Assert maior dez e cinco igual a dez. Esse talvez passe. Depois assert maior dois e nove igual a nove. Agora o bug aparece de forma clara.

A hipótese fica testável: o caminho em que b é maior está devolvendo o valor errado. Então corrigimos somente esse trecho, mudando o retorno final para b.

Depois da correção, executamos todos os testes novamente. Só então pensamos em refatoração.

Refatorar significa melhorar a estrutura sem mudar o comportamento. Podemos melhorar nomes, eliminar repetição ou simplificar uma função. Mas fazer isso sem testes pode ser arriscado porque você não tem uma forma rápida de provar que o comportamento continua igual.

Seu desafio será criar uma função desconto que receba preco e percentual. Depois crie pelo menos três asserts. Inclua um caso normal, um percentual igual a zero e mais um caso que ajude a testar um limite ou situação diferente.

Depois vem o mini projeto: um hospital de código. Escolha duas funções pequenas. Primeiro, escreva testes que descrevam o comportamento esperado. Depois identifique ou introduza um bug de propósito. Reproduza o problema, formule uma hipótese, corrija e execute os testes novamente. Por último, melhore nomes ou elimine alguma repetição sem quebrar os testes.

Repare na mudança de postura. Debugging não é tentar dez coisas ao mesmo tempo. É reproduzir, observar, criar uma hipótese, testar, corrigir uma parte pequena e verificar novamente.

Quando você trabalha assim, o erro deixa de ser apenas algo irritante. Ele vira uma pista. E os testes deixam de ser uma obrigação extra. Eles passam a ser uma forma de proteger aquilo que você já conseguiu fazer funcionar.

## Cenas previstas
1. Bug como pista de investigação.
2. Fluxo reproduzir → hipótese → teste → correção.
3. Função `eh_par` e asserts.
4. Teste passando e teste falhando.
5. Função `maior` com bug.
6. Dois testes revelando o caminho quebrado.
7. Correção e reexecução dos testes.
8. Refatoração protegida por testes.
9. Mini projeto “hospital de código”.
