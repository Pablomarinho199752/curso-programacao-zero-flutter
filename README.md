# Curso de Programação do Zero

Aplicativo Flutter para Android e Windows. Conteúdo introdutório em Python, para quem nunca programou.

## Módulo 0 em revisão

Uma aula guiada com oito etapas:
**explicação curta → videoaula → exemplo → prática → desafio → correção → mini projeto → revisão**.

Inclui retomada da etapa, rascunhos e tentativas salvos no aparelho; pistas antes da solução; laboratório offline limitado a `print`; algoritmo com autoavaliação; cartão de apresentação; três perguntas e relatório copiável para revisão no ChatGPT. Vídeo externo com alternativa textual offline. Progresso por etapas, sem confundir conclusão com domínio. Nenhum conteúdo de Módulo 1.

- [Conteúdo completo para revisar no ChatGPT](docs/MODULO_0.md)
- [Decisões e aprovação pedagógica](docs/REVISAO_PEDAGOGICA_MODULO_0.md)
- [Checklist Android/Windows e limites dos builds](docs/TESTES_MODULO_0.md)
- [Arquitetura](ARCHITECTURE.md)

## Desenvolvimento

Use Flutter **3.35.7**. Na raiz do repositório:

```bash
bash scripts/bootstrap.sh
```

No PowerShell: `./scripts/bootstrap.ps1`. Os scripts geram os diretórios Android/Windows, resolvem dependências e executam análise e testes. Depois use `flutter run -d windows` em Windows com ferramentas de compilação instaladas, ou `flutter run` com Android conectado.

## Artefatos para avaliação

O workflow **Build Android e Windows**, executado em PRs para `main`, gera APK e instalador Windows x64 em **Actions → execução → Artifacts**. Baixe e extraia o ZIP; no Windows use o instalador completo, não apenas o executável isolado.

Não criar tag de versão antes da revisão pedagógica e dos testes em aparelhos reais. O workflow de release continua reservado a tags `v*`. Os artefatos do PR são builds para avaliação: assinatura Android persistente e assinatura Windows ainda precisam ser preparadas antes de distribuição/atualizações estáveis.
