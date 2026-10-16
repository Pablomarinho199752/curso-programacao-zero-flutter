# Aula 9.1 — SQLite e CRUD: dados estruturados que permanecem

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai dar um passo além dos arquivos de texto e começar a trabalhar com um banco de dados. O foco será SQLite, uma opção simples e muito útil para guardar informações estruturadas dentro de um arquivo.

Imagine um controle de estoque. Você quer guardar vários produtos, cada um com nome, quantidade e preço. Um arquivo de texto até poderia funcionar em casos pequenos, mas conforme você precisa buscar, atualizar e excluir registros específicos, um banco de dados começa a fazer mais sentido.

No SQLite, os dados são organizados em tabelas. Pense em uma tabela como uma planilha. Cada linha representa um registro e cada coluna representa um campo.

Vamos começar criando uma conexão. Importamos sqlite3 e escrevemos con igual a sqlite3.connect de app.db. Se o arquivo ainda não existir, o SQLite pode criá-lo.

Depois criamos um cursor. O cursor é o objeto que usamos para executar comandos SQL. Podemos mandar um CREATE TABLE IF NOT EXISTS para criar uma tabela tarefas com id e titulo. O id pode ser a chave principal e titulo guarda o texto da tarefa.

Depois usamos commit para confirmar alterações e close para fechar a conexão.

Agora entra uma sigla importante: CRUD. Ela representa quatro operações básicas. Create é criar ou inserir dados. Read é ler. Update é atualizar. Delete é excluir.

Se você consegue fazer essas quatro operações, já tem a base de muitos sistemas de cadastro.

Vamos imaginar a inserção de uma tarefa. Em vez de montar o comando SQL juntando texto do usuário diretamente, usamos parâmetros. Podemos escrever INSERT INTO tarefas titulo VALUES ponto de interrogação e passar o valor separadamente.

Por que isso é melhor? Porque o comando SQL fica separado do dado. Isso evita vários problemas de formatação e também reduz riscos importantes quando os valores vêm de entrada externa.

Compare com um código que faz cur.execute juntando a string do comando com a variável titulo. Mesmo que pareça funcionar em um exemplo simples, esse jeito torna o código mais frágil. A consulta parametrizada é a opção correta para valores.

Depois de inserir, podemos usar SELECT para ler os registros. O resultado pode ser percorrido e mostrado na tela. Para atualizar, usamos UPDATE com uma condição que indica qual registro deve mudar. Para excluir, usamos DELETE também com uma condição bem definida.

Um cuidado importante: antes de atualizar ou excluir, saiba exatamente qual registro está sendo selecionado. Um comando amplo demais pode alterar mais dados do que você pretendia.

Seu desafio será conectar a app.db, inserir uma tarefa usando ponto de interrogação como parâmetro e depois fazer um SELECT para listar os registros.

No mini projeto, escolha entre um controle de estoque ou um controle financeiro. Crie uma tabela própria e planeje funções para inserir, listar, atualizar e excluir registros. Não precisa transformar tudo em uma interface bonita agora. O objetivo é fazer o ciclo completo de dados funcionar.

Compare isso com uma lista em memória. Uma lista desaparece quando o programa termina, a menos que você salve de alguma forma. O banco de dados permanece e ainda permite consultas estruturadas.

Ao final, guarde três ideias: tabela organiza registros e campos; CRUD representa as quatro operações básicas; e valores devem ser enviados para o SQL usando parâmetros. Com isso, você já tem uma base sólida para começar a construir aplicações que realmente preservam e manipulam dados.

## Cenas previstas
1. Lista em memória versus banco persistente.
2. Banco como arquivo `app.db`.
3. Tabela visual com linhas e colunas.
4. Conexão, cursor e `CREATE TABLE`.
5. CRUD como quatro ações visuais.
6. Inserção com parâmetro `?`.
7. Comparação com concatenação insegura de texto.
8. `SELECT`, `UPDATE` e `DELETE`.
9. Mini projeto de estoque ou finanças.
