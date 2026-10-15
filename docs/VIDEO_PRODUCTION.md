# Produção audiovisual — Código Zero

Este documento registra a origem e o estado dos vídeos do curso sem confundir **render iniciado** com **link público integrado ao aplicativo**.

## Identidade

- Formato: 16:9.
- Linguagem: português do Brasil, simples e direta.
- Voz nova dos módulos 1–12: `Sofia Brazil - Friendly`, HeyGen voice id `0edbc867be6f48c5be8ff8b0fbca0802`.
- Visual: fundo azul-marinho, acentos roxo/ciano, editor de código e cartões de dados.
- Imagens-base dos novos vídeos foram produzidas no Runway com `nano-banana-2-lite`.
- Método pedagógico dentro do vídeo: ideia curta → previsão → exemplo → erro comum → aplicação/projeto. Assistir ao vídeo nunca comprova domínio sozinho.

## Estado por módulo

| Módulo | Tema | Produção | Identificador | Link estável no app |
| --- | --- | --- | --- | --- |
| 0 | Começando do absoluto zero | publicado | Descript `849f1543-a681-4a02-9d3c-c656ae0c681b` | https://share.descript.com/view/zboVy82eLM0 |
| 1 | Valores, variáveis e entrada de dados | nova versão em renderização | HeyGen `23575c20a945ba6ebca44ef0b3fa9b9a` | versão curta atual: https://share.descript.com/view/LYmNVlmGLyW |
| 2 | Decisões com if, elif e else | em renderização | HeyGen `6b2ed308d1aa30e57515c7e80ed16d03` | pendente |
| 3 | Repetições e automação | em renderização | HeyGen `5c5691069e00098202ff035548281350` | pendente |
| 4 | Listas, dicionários e coleções | em renderização | HeyGen `2e7069188e8e387f12566aa85268a00f` | pendente |
| 5 | Funções e organização do raciocínio | em renderização | HeyGen `f0cd62b2ca92c9df5596fb17209cf9bf` | pendente |
| 6 | Arquivos, erros e módulos | em renderização | HeyGen `27912784275958e5a92d1abd9db1c841` | pendente |
| 7 | Debugging, testes e refatoração | em renderização | HeyGen `3bcb4152c303baeed81d80b95c60cd56` | pendente |
| 8 | APIs, JSON e documentação | em renderização | HeyGen `9c9126cba89555b4f3b032c0ce70ea9c` | pendente |
| 9 | Banco de dados com SQLite | em renderização | HeyGen `e3d93c7fb93ec7efa517a70a8c2b9bb9` | pendente |
| 10 | Projetos maiores, OOP e ambientes | em renderização | HeyGen `1188d7f4439b0f1a1b7530f7f7bd90ce` | pendente |
| 11 | Git e GitHub na prática | em renderização | HeyGen `e52e100a1279e81f19bbc33aca2c2e1a` | pendente |
| 12 | Desenvolvimento independente | em renderização | HeyGen `9590722ae35591925245d7c7c7e2818d` | pendente |

## Regra para integração

Um vídeo só deve receber `videoUrl` definitivo no conteúdo do aplicativo quando existir uma URL pública/estável adequada para o aluno. Identificador de renderização, URL assinada temporária ou tela interna do provedor não deve ser tratada como link definitivo.

Se for necessário migrar o vídeo final para um host estável, manter o mesmo roteiro e registrar aqui a nova origem antes de substituir `videoUrl`.
