# Aula 2.1 — Decisões: transformar regras em caminhos

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080
- Estrutura: conceito → exemplo visual → código passo a passo → erro comum → prática → desafio/projeto → fechamento

## Narração

Nesta aula, você vai aprender a fazer o programa tomar decisões. Até agora, nosso código executava uma sequência de instruções. Mas programas úteis precisam escolher caminhos diferentes dependendo dos dados. É aí que entram if, elif e else.

Vamos começar com uma regra em português: se a nota for maior ou igual a sete, mostre Aprovado. Caso contrário, mostre Revisar. Antes de pensar em Python, perceba que temos uma pergunta: a nota é maior ou igual a sete? Essa pergunta só pode resultar em verdadeiro ou falso.

No Python, escrevemos nota igual a oito. Depois, if nota maior ou igual a sete, dois-pontos. Na linha de baixo, com indentação, print Aprovado. Em seguida, else, dois-pontos, e print Revisar. Como oito é maior que sete, a condição é verdadeira e o primeiro caminho é executado.

Agora troque a nota para seis. A pergunta continua sendo a mesma: seis é maior ou igual a sete? Não. Então o Python ignora o bloco do if e entra no else. A saída passa a ser Revisar.

O detalhe importante está no símbolo maior ou igual. Se a regra diz que sete também vale, usar apenas maior que sete cria um erro justamente no limite. Com nota igual a sete, maior que sete seria falso. Por isso, quando uma regra tem limite, teste sempre três valores: um abaixo, exatamente o limite e um acima. Neste caso: seis, sete e oito.

Também podemos ter mais de dois caminhos. Imagine uma regra: nota maior ou igual a sete significa Aprovado; nota maior ou igual a cinco significa Recuperação; qualquer valor abaixo disso significa Reprovado. Primeiro usamos if para a condição mais alta. Depois usamos elif para a segunda possibilidade. Por último, else cobre tudo o que sobrou.

A ordem é muito importante. O Python testa de cima para baixo e para no primeiro caminho verdadeiro. Se você colocar primeiro uma condição muito ampla, ela pode capturar valores que deveriam chegar a outra regra. Então pense nas faixas antes de escrever o código.

Além de maior ou igual, temos outros comparadores. Dois sinais de igual perguntam se os valores são iguais. Exclamação seguida de igual pergunta se são diferentes. Menor ou igual inclui o valor do limite. E podemos combinar condições com and e or.

Por exemplo, um aluno só é aprovado se tiver nota maior ou igual a sete e frequência maior ou igual a setenta e cinco. Nesse caso usamos and, porque as duas condições precisam ser verdadeiras. Se uma delas falhar, o resultado inteiro fica falso.

Agora um erro comum: idade igual a dezoito, mas o código usa if idade maior que dezoito para permitir entrada. A regra diz a partir de dezoito. Então dezoito precisa estar incluído. A correção é simples: idade maior ou igual a dezoito.

Outro ponto essencial é a indentação. As linhas que pertencem ao if, elif ou else precisam ficar recuadas. Essa organização não é só visual. No Python, ela define quais instruções fazem parte de cada caminho.

Para praticar, monte mentalmente três testes. Primeiro, nota seis. Depois, nota sete. Depois, nota nove. Antes de executar, diga qual caminho você espera em cada caso. Esse hábito de prever, executar e comparar ajuda muito a encontrar erros.

Seu desafio será criar uma regra de faixa etária com pelo menos três caminhos usando if, elif e else. Depois, faça um pequeno sistema de aprovação usando duas variáveis: nota e frequência. Para aprovação, exija nota maior ou igual a sete e frequência maior ou igual a setenta e cinco. Crie também um caminho de recuperação e outro de reprovação.

Não tente decorar todos os símbolos de uma vez. O mais importante é saber transformar uma regra escrita em português em uma pergunta que resulta em verdadeiro ou falso. Depois, teste os limites. Se você fizer isso, decisões em Python começam a ficar muito mais previsíveis. Na próxima prática, você vai escrever essas regras e verificar cada caminho com valores diferentes.

## Cenas previstas
1. Abertura: decisão como bifurcação visual.
2. Regra em português virando uma pergunta verdadeiro/falso.
3. Código `if/else` com `nota = 8` e saída “Aprovado”.
4. Mesmo código com `nota = 6` e saída “Revisar”.
5. Casos de limite: 6, 7 e 8.
6. Três caminhos: Aprovado / Recuperação / Reprovado.
7. Operadores `>=`, `<=`, `==`, `!=`, `and`, `or`.
8. Erro comum `idade > 18` e correção para `idade >= 18`.
9. Indentação destacada visualmente.
10. Prática guiada e mini projeto de aprovação com nota + frequência.
