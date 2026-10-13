# Arquitetura v0.1

- `lib/models`: modelos de curso, quiz e domínio.
- `lib/data`: carregamento dos módulos em JSON.
- `lib/services`: persistência do progresso.
- `lib/screens`: telas de Início, Módulos, Progresso e Aula.
- `lib/widgets`: componentes reutilizáveis.
- `assets/content/modules.json`: conteúdo pedagógico separado do código da UI.
- `.github/workflows`: CI e releases Android/Windows.
- `installer`: definição do instalador Windows via Inno Setup.

## Regra de evolução

Adicionar conteúdo primeiro no JSON e criar novos componentes somente quando um tipo novo de atividade realmente exigir. Evitar transformar a primeira versão em uma arquitetura complexa antes de validar a experiência de estudo.
