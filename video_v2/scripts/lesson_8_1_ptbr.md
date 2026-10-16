# Aula 8.1 — APIs e JSON: aprender pela documentação

## Padrão de produção
- Voz: Maya
- Idioma: português do Brasil (pt-BR)
- Velocidade: 0,80
- Duração-alvo: 3 a 5 minutos
- Resolução: 1920×1080

## Narração

Nesta aula, você vai aprender como um programa pode conversar com um serviço externo usando uma API. Mais importante do que decorar comandos, você vai aprender a descobrir como uma API funciona usando documentação.

Imagine um aplicativo de clima. Seu programa não precisa possuir todos os dados meteorológicos dentro dele. Em vez disso, pode fazer uma requisição para um serviço que já oferece essas informações. A API funciona como uma interface combinada: ela explica quais pedidos podemos fazer e qual resposta podemos esperar.

Em Python, uma biblioteca muito usada para requisições HTTP é requests. Podemos escrever import requests e depois resposta igual a requests.get de uma URL, usando também um timeout. O timeout evita que o programa fique esperando para sempre caso o serviço não responda.

Depois da requisição, uma das primeiras coisas que podemos observar é o status HTTP. Um status de sucesso nos ajuda a saber que a requisição foi atendida. Outros status podem indicar que o pedido está incorreto, que algo não foi encontrado ou que o serviço encontrou um problema.

O ponto principal é não tratar toda resposta como se fosse sucesso. Antes de usar os dados, verifique o que o serviço realmente devolveu.

Muitas APIs retornam dados em JSON. Quando esse JSON é convertido para Python, ele costuma aparecer como uma combinação de dicionários e listas.

Imagine o seguinte dado: usuarios contém uma lista e, dentro dela, existe um dicionário com nome igual a Ana. Se tentarmos acessar dados nome diretamente, o programa vai procurar a chave nome no nível errado. Primeiro precisamos entrar em usuarios, depois escolher um item da lista e só então acessar nome.

Esse tipo de erro fica mais fácil de resolver quando você olha para a estrutura dos dados em vez de tentar chaves aleatórias.

É aqui que a documentação se torna fundamental. Quando você encontra uma API nova, não comece procurando um código completo para copiar. Faça perguntas específicas. Qual é a URL base? Qual endpoint entrega o dado que eu quero? Precisa de autenticação? Quais parâmetros são aceitos? Qual formato da resposta? Quais status podem aparecer?

Depois faça o menor experimento possível. Uma única requisição. Mostre o status. Se funcionar, veja o JSON. Só depois transforme os dados em algo útil para seu aplicativo.

Seu desafio será criar uma função chamada buscar_dados que receba uma URL, faça requests.get com timeout, verifique se o status é duzentos e retorne resposta.json quando estiver tudo certo.

Depois, pense no que fazer quando algo der errado. Pode existir uma falha de rede, um timeout ou um status inesperado. O programa precisa ter uma resposta razoável para aquilo que é esperado.

No mini projeto, você vai planejar um aplicativo que consulta uma API pública. Terá uma função responsável pela consulta, outra responsável por transformar o JSON em uma mensagem e pelo menos um tratamento de falha.

O objetivo não é sair desta aula conhecendo todas as APIs. Isso seria impossível. O objetivo é aprender um processo que funciona quando você encontra uma API que nunca viu: leia a documentação, transforme sua dúvida em uma pergunta pequena, faça um experimento mínimo, observe a resposta e evolua uma etapa de cada vez.

Essa habilidade vale muito mais do que decorar uma integração pronta, porque novas APIs vão aparecer durante toda a sua vida como programador.

## Cenas previstas
1. Aplicativo conversando com serviço externo.
2. Requisição → API → resposta.
3. `requests.get` com `timeout`.
4. Status HTTP como sinal de sucesso ou falha.
5. JSON virando listas e dicionários.
6. Erro de acessar `dados["nome"]` no nível errado.
7. Navegação correta na estrutura JSON.
8. Checklist de leitura de documentação.
9. Mini projeto de integração com API pública.
