# Aula 10.1 — Projetos maiores: estrutura, classes e ambiente

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai aprender como organizar um projeto quando ele começa a ficar maior. O objetivo não é criar dezenas de pastas ou usar orientação a objetos em tudo. É separar responsabilidades de um jeito que torne o projeto mais fácil de entender, testar e manter.

Quando um programa é pequeno, colocar tudo em um arquivo pode ser aceitável. Mas conforme aparecem persistência, regras de negócio, interface e integração com outros serviços, misturar tudo começa a dificultar mudanças.

Uma boa estrutura nasce das responsabilidades. Por exemplo, um módulo pode cuidar dos dados. Outro pode cuidar das regras. Outro pode cuidar da apresentação. Não crie pastas apenas para parecer profissional. Crie separações quando elas ajudam a localizar e entender o código.

Agora vamos falar de classes. Uma classe pode ser útil quando dados e comportamentos pertencem ao mesmo conceito.

Imagine uma tarefa. Ela tem um título e um estado dizendo se está concluída. Também existe um comportamento natural: concluir a tarefa. Podemos criar uma classe Tarefa. No método __init__, recebemos titulo, guardamos esse valor em self.titulo e começamos self.concluida como False. Depois criamos um método concluir que muda esse estado para True.

Aqui a classe faz sentido porque os dados e a ação pertencem ao mesmo objeto conceitual.

Mas nem todo problema precisa de classe. Se você só precisa receber dois números e calcular uma média, uma função simples pode ser mais clara. Usar orientação a objetos sem necessidade pode criar mais estrutura do que benefício.

Observe um erro comum. Temos class Usuario e def __init__(nome). O problema é que o método precisa receber self para representar a instância. Além disso, escrever nome igual a nome não guarda o valor dentro do objeto. Precisamos de self.nome igual a nome.

Então um construtor típico seria def __init__(self, nome), seguido de self.nome igual a nome.

Outro assunto importante em projetos maiores são as dependências. Se seu programa usa bibliotecas externas, outra pessoa precisa conseguir instalar as mesmas versões ou pelo menos saber do que o projeto depende.

Para isso, usamos um ambiente virtual. Ele ajuda a isolar as dependências de um projeto das dependências de outros projetos no mesmo computador.

Depois podemos registrar as dependências em um arquivo de requisitos. Assim o projeto fica mais fácil de reproduzir em outra máquina.

Seu desafio será criar uma classe Produto com nome e preco no __init__. Depois crie um método aplicar_desconto que altere o preço de acordo com um percentual. Teste com pelo menos dois produtos e confira o resultado.

Depois pense: esse conceito realmente ficou mais claro como classe? O objetivo não é usar classe porque chegou o módulo de orientação a objetos. É aprender a reconhecer quando ela ajuda.

No mini projeto, organize um aplicativo em pelo menos três responsabilidades. Descreva quais módulos você teria. Inclua uma classe apenas em uma parte em que dados e comportamento realmente pertençam ao mesmo conceito. Depois registre quais dependências externas seriam necessárias.

A principal lição é que projeto profissional não significa projeto complicado. Uma boa organização torna as responsabilidades visíveis. Classes são uma ferramenta, não uma obrigação. E ambientes virtuais ajudam a manter as dependências controladas e reproduzíveis.

Se você conseguir explicar por que cada arquivo existe, por que uma classe foi usada e quais dependências o projeto precisa, sua estrutura está começando a trabalhar a favor do código em vez de apenas deixá-lo maior.

## Cenas previstas
1. Arquivo único crescendo e ficando confuso.
2. Separação por responsabilidades.
3. Classe `Tarefa` como dados + comportamento.
4. Instância mudando de `concluida = False` para `True`.
5. Função simples versus classe.
6. Erro no `__init__` sem `self`.
7. Correção com `self.nome`.
8. Ambiente virtual e arquivo de requisitos.
9. Mini projeto organizado em três responsabilidades.
