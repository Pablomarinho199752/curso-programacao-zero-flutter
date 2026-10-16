# Aula 6.1 — Persistência e falhas esperadas

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai aprender três ideias que fazem um programa parecer muito mais real: salvar dados, lidar com falhas esperadas e separar código em módulos.

Até agora, muitas informações existiam apenas enquanto o programa estava rodando. Quando o programa terminava, elas desapareciam. Arquivos resolvem esse problema. Eles permitem persistir dados entre uma execução e outra.

Imagine um gerenciador de tarefas. Se você adiciona três tarefas e fecha o programa, espera encontrar essas tarefas quando abrir novamente. Para isso, precisamos salvar os dados em algum lugar.

Em Python, podemos usar with open para abrir um arquivo. O with ajuda a garantir que o arquivo seja fechado corretamente depois do uso. Se queremos escrever, podemos abrir tarefas.txt em modo de escrita. Se queremos ler, usamos o modo de leitura.

Vamos observar um exemplo de leitura. Escrevemos try, depois with open tarefas.txt, modo r, encoding utf-8, as arquivo. Dentro do bloco, usamos print arquivo read. Se o arquivo existir, o conteúdo é lido normalmente.

Mas e se for a primeira execução e tarefas.txt ainda não existir? Isso não precisa ser tratado como um desastre. É uma falha esperada. Podemos usar except FileNotFoundError e mostrar uma mensagem como “Ainda não há tarefas salvas”.

Repare que estamos tratando um erro específico. Isso é importante. Um except vazio, que captura qualquer coisa e simplesmente ignora, pode esconder problemas reais.

Imagine este código: try, numero igual a int de “abc”. Depois except, sem especificar o tipo, seguido de pass. O programa falha ao converter o texto, mas o erro desaparece sem nenhuma explicação. Isso pode deixar o programa parecer que funcionou quando na verdade existe um problema.

A ideia não é capturar todo erro. É tratar aquilo que você conhece e sabe como responder. Se um arquivo opcional ainda não existe, podemos criar um comportamento para isso. Se aparece um erro inesperado durante o desenvolvimento, muitas vezes é melhor enxergá-lo para conseguir investigar.

Agora vamos falar de escrita. Podemos abrir notas.txt em modo w e escrever duas linhas. Depois fechamos naturalmente ao sair do with. Em seguida, abrimos novamente em modo de leitura e conferimos o conteúdo. Esse ciclo de salvar e ler é a base da persistência com arquivos.

Com o programa crescendo, também fica útil separar responsabilidades em arquivos diferentes. Um módulo é um arquivo Python que pode conter funções, classes ou outras definições. Depois podemos usar import para reutilizar esse código em outro arquivo.

Por exemplo, podemos ter um módulo responsável por salvar e carregar tarefas e outro arquivo com o fluxo principal. Assim, cada parte do projeto fica mais fácil de entender.

Seu desafio será salvar duas linhas em notas.txt e depois ler o arquivo. Na leitura, trate especificamente FileNotFoundError. Nada de except vazio.

No mini projeto, vamos montar a base de um gerenciador de tarefas. O programa terá uma lista de tarefas, salvará os dados em tarefas.txt e tentará carregar o arquivo ao iniciar. Se for a primeira execução e o arquivo ainda não existir, o programa deve lidar com isso de forma clara.

A pergunta central desta aula é: quando uma falha é esperada? Se você sabe que algo pode acontecer e existe uma resposta razoável, vale tratar. Se você ainda não entende o erro, escondê-lo pode atrapalhar muito mais do que ajudar.

## Cenas previstas
1. Dados desaparecendo ao fechar versus dados salvos.
2. Arquivo `tarefas.txt` como memória persistente.
3. `with open` em leitura.
4. Caminho normal versus `FileNotFoundError`.
5. Exemplo ruim com `except:` e `pass`.
6. Escrita e leitura de `notas.txt`.
7. Separação em módulos.
8. Desafio de arquivo.
9. Mini projeto do gerenciador persistente.
