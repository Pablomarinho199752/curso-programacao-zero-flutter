# Aula 1.1 — Valores e variáveis: dando nome aos dados

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai entender uma das ideias mais importantes da programação: valores e variáveis. Parece um assunto pequeno, mas ele aparece em praticamente todo programa que você vai criar.

Comece pensando em três caixas. Na primeira caixa existe a etiqueta apelido. Dentro dela está o texto Pythonista. Na segunda caixa, a etiqueta projetos, com o número dois. Na terceira, a etiqueta meta, com o número sete vírgula cinco. A etiqueta funciona como o nome da variável. O conteúdo da caixa é o valor guardado.

Em Python, podemos escrever apelido igual a “Pythonista”. Nesse caso, apelido é o nome da variável e “Pythonista” é um valor de texto. Depois escrevemos projetos igual a dois. Aqui temos um número inteiro. E meta igual a sete ponto cinco guarda um número com parte decimal.

O sinal de igual merece atenção. Aqui ele não está perguntando se duas coisas são iguais. Ele representa uma atribuição. Pense assim: pegue o valor da direita e associe esse valor ao nome que está à esquerda.

Depois que o valor está guardado, podemos reutilizar o nome. Se escrevemos print apelido, o Python procura o valor associado ao nome apelido e mostra Pythonista. Ele não imprime a palavra apelido. Ele mostra o conteúdo guardado naquela variável.

Faça uma previsão. Se o código diz idade igual a quarenta e dois e, na linha seguinte, print idade, qual será a saída? A resposta é quarenta e dois. A palavra idade é apenas o nome usado para acessar esse valor.

Agora repare nos tipos de valor. Texto precisa ficar entre aspas. Números inteiros, como dois ou quarenta e dois, não usam aspas. Números decimais, como sete ponto cinco, também são números e não precisam de aspas. Neste momento, você não precisa decorar nomes técnicos. O mais importante é reconhecer que o programa pode trabalhar com tipos diferentes de informação.

Os nomes das variáveis também fazem diferença. Compare projeto, tarefas e versao com nomes como x, y e z. Os dois jeitos podem funcionar, mas nomes claros tornam o código muito mais fácil de entender. Quando você voltar ao programa depois, projeto já explica o que está guardado. Um nome como x exige que você descubra isso de novo.

Existe ainda um erro muito comum. Imagine que você cria nome igual a “Pablo”. Depois escreve print nom, sem a última letra e. Para nós, os nomes parecem parecidos. Para o Python, nome e nom são identificadores diferentes. Como nom nunca foi criado, o programa gera um erro.

Quando isso acontecer, não comece trocando várias coisas ao mesmo tempo. Leia a linha indicada pelo erro. Compare o nome usado com o nome criado anteriormente, letra por letra. Corrija apenas o que está diferente e execute novamente.

Também é importante saber que letras maiúsculas e minúsculas podem mudar o identificador. nome e Nome não são necessariamente a mesma variável. Por isso, consistência ajuda muito.

Agora faça uma prática. Escolha três informações sobre uma ideia de projeto. A primeira deve ser um texto. Por exemplo, o nome do projeto. A segunda deve ser um número inteiro, como quantidade de tarefas. A terceira deve ser um número decimal, como uma versão. Crie nomes claros para as três variáveis.

Depois use print para mostrar os valores. Antes de executar, preveja a saída. Confira se a ordem e os valores correspondem ao que você planejou.

Seu mini projeto é criar uma ficha simples de projeto. Você pode escrever projeto igual a “Meu app”, tarefas igual a três e versao igual a um ponto zero, mas escolha valores e nomes que façam sentido para você. Depois mostre as três informações na saída.

A ideia principal desta aula é simples: valor é a informação; variável é o nome que usamos para acessar essa informação; e a atribuição liga um nome a um valor. Quando isso ficar claro, os próximos assuntos — entrada de dados, contas, decisões e projetos maiores — começam a fazer muito mais sentido.

## Cenas previstas
1. Abertura com três caixas de dados.
2. Texto, inteiro e decimal.
3. Atribuição: nome à esquerda, valor à direita.
4. `print(variavel)` buscando o conteúdo.
5. Comparação entre nomes claros e nomes genéricos.
6. Erro `nome` versus `nom`.
7. Correção passo a passo.
8. Prática com três variáveis.
9. Mini projeto da ficha de projeto.
