# Aula 5.1 — Funções: dividir o problema em responsabilidades

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai aprender a dividir um problema grande em pequenas responsabilidades. A principal ferramenta para isso será a função.

Uma função é um bloco de código que recebe um nome porque realiza uma tarefa específica. Pense em uma máquina pequena: você entrega uma entrada, ela faz um trabalho e pode devolver um resultado.

Vamos começar com um exemplo simples. Criamos def dobro, abrimos parênteses com o parâmetro numero e colocamos dois-pontos. Dentro da função, retornamos numero vezes dois. Depois chamamos dobro passando quatro. O valor quatro entra no parâmetro numero, a função calcula oito e return devolve esse resultado.

Então podemos escrever resultado igual a dobro quatro e depois print resultado. A saída será oito.

Agora repare em duas ideias diferentes: print e return. Print mostra uma informação na tela. Return entrega um valor para outra parte do programa usar. Essa diferença fica muito importante quando queremos fazer novos cálculos com o resultado.

Imagine uma função soma que recebe a e b. Dentro dela, em vez de return, usamos print a mais b. Depois escrevemos resultado igual a soma dois e três. A função mostra cinco na tela, mas não devolve cinco para resultado. Por isso, quando tentamos multiplicar resultado por dois, surge um problema. Mostrar e devolver não são a mesma coisa.

A correção é usar return a mais b. Agora resultado realmente recebe cinco e pode continuar sendo usado em outras operações.

Os parâmetros funcionam como espaços de entrada. Em calcular_media, por exemplo, podemos receber nota1 e nota2. A função soma as duas notas, divide por dois e retorna a média. Assim o mesmo código funciona para vários pares de valores.

E por que criar funções? Primeiro, para evitar repetição. Se o mesmo cálculo aparece em vários lugares, podemos escrevê-lo uma vez e reutilizar. Segundo, para melhorar a leitura. Um nome como calcular_media explica a intenção melhor do que várias linhas soltas no meio do programa.

Mas isso não significa transformar cada linha em uma função. Uma boa função costuma ter uma responsabilidade que você consegue explicar em uma frase. “Validar um preço.” “Calcular uma média.” “Formatar uma mensagem.” Quando uma função tenta fazer dez tarefas diferentes ao mesmo tempo, ela começa a ficar difícil de entender.

Seu desafio será criar uma função chamada calcular_media que receba duas notas e retorne a média. Depois chame a função com valores diferentes e mostre os resultados. Antes de executar, tente prever cada saída.

Depois, para o mini projeto, vamos dividir um pequeno aplicativo em pelo menos três funções. Uma função valida um valor. Outra faz um cálculo. A terceira prepara a mensagem final. O objetivo não é criar um programa enorme. É perceber como as responsabilidades ficam mais claras quando cada parte tem um nome.

Durante a prática, faça uma pergunta importante: este trecho merece virar uma função separada? Se ele representa uma tarefa clara, pode ser reutilizado ou deixa o fluxo principal mais fácil de entender, provavelmente sim.

Funções são uma das ferramentas que mais ajudam um programa a crescer sem virar bagunça. Você não precisa decorar todos os detalhes agora. Foque em três ideias: parâmetros recebem dados, return devolve um resultado e uma função boa costuma fazer uma coisa bem definida.

## Cenas previstas
1. Problema grande dividido em blocos menores.
2. Função como máquina com entrada e saída.
3. `dobro(numero)` passo a passo.
4. Diferença visual entre `print` e `return`.
5. Erro da função `soma` que apenas imprime.
6. Correção usando `return`.
7. Função `calcular_media` com parâmetros.
8. Quando vale criar uma função.
9. Mini projeto em três responsabilidades.
