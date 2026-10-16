# Aula 3.1 — Repetições: automatizar sem perder o controle

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai aprender a repetir tarefas sem copiar a mesma linha de código várias vezes. Repetições, ou loops, servem para automatizar aquilo que precisa acontecer várias vezes.

Existem duas ideias principais aqui: for e while. O for é muito útil quando temos uma sequência para percorrer ou quando sabemos quantas vezes queremos repetir alguma coisa. O while é útil quando a repetição depende de uma condição e não sabemos exatamente quantas voltas serão necessárias.

Vamos começar com um exemplo simples. Imagine total igual a zero. Depois usamos for numero in range de um até quatro. Esse range produz os valores um, dois e três. Em cada volta, fazemos total igual a total mais numero.

Na primeira volta, total começa em zero e recebe um. Agora total vale um. Na segunda volta, numero vale dois. Então total vira três. Na terceira volta, numero vale três. Total vira seis. Depois que o loop termina, usamos print total e aparece seis.

Esse tipo de variável que guarda um resultado enquanto o loop avança é chamado de acumulador. O mais importante não é decorar o nome. É perceber que o valor muda a cada repetição.

Quando um resultado de loop estiver errado, uma boa estratégia é acompanhar os valores por volta. Anote o valor antes e depois da atualização. Assim você consegue descobrir exatamente em qual repetição o comportamento ficou diferente do esperado.

Agora compare com while. Imagine contador igual a um. Enquanto contador for menor ou igual a cinco, mostramos contador. Mas existe um problema se nunca mudarmos contador. A condição continuará verdadeira para sempre. O programa fica preso repetindo a mesma coisa.

Por isso, toda vez que você usar while, faça uma pergunta antes de executar: o que faz esse loop terminar? No exemplo, precisamos atualizar contador dentro do while. Podemos escrever contador igual a contador mais um. Assim, a cada volta, ele se aproxima do momento em que a condição fica falsa.

Então existe uma diferença prática. Se você quer percorrer uma lista ou repetir uma quantidade conhecida, for costuma ser a escolha mais natural. Se você quer repetir até alguma condição acontecer, while pode fazer mais sentido.

Vamos fazer uma prática mental. Use range de um até onze. Isso gera os números de um a dez. Agora queremos somar apenas os pares. Podemos verificar numero módulo dois igual a zero. Se for verdadeiro, adicionamos esse número ao total. No fim, mostramos apenas o total final.

Repare também onde o print fica. Se você colocar print dentro do loop, verá um resultado a cada volta. Se colocar fora, verá apenas o resultado final. A indentação muda o comportamento do programa.

Seu desafio é percorrer os números de um a dez, somar somente os pares e mostrar o total no final. Antes de executar, tente prever o resultado.

Depois, vamos para um mini projeto: um jogo de adivinhação simplificado. Temos um numero_secreto igual a sete e uma lista de palpites, como três, nove e sete. Percorremos os palpites com for. Se o palpite for menor, mostramos uma pista. Se for maior, mostramos outra. Quando o palpite for igual ao número secreto, mostramos que acertou e usamos break para encerrar a repetição.

A ideia mais importante desta aula é que todo loop precisa de controle. Pergunte sempre: o que se repete, o que muda a cada volta e quando termina? Se você souber responder essas três perguntas, fica muito mais difícil criar um loop sem entender o que ele está fazendo.

## Cenas previstas
1. Repetição manual versus loop.
2. `for` percorrendo 1, 2 e 3.
3. Acumulador mudando 0 → 1 → 3 → 6.
4. Comparação visual entre `for` e `while`.
5. Exemplo de loop infinito.
6. Correção com `contador = contador + 1`.
7. Soma dos pares de 1 a 10.
8. Efeito da indentação no `print`.
9. Mini projeto de adivinhação com `break`.
