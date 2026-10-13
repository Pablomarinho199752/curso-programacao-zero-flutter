# Curso de Programação do Zero

Aplicativo educacional multiplataforma construído com **Flutter + Dart** para acompanhar um curso de programação do absoluto zero, com foco inicial em **Python**.

## Objetivo

O projeto foi desenhado para funcionar como a “escola” do curso:

- Android (APK)
- Windows (aplicativo + instalador `.exe`)
- aulas organizadas por módulos
- videoaulas
- prática e desafios
- progresso por habilidade: 🟢 Domina, 🟡 Em desenvolvimento, 🔴 Ainda não domina
- conteúdo expansível módulo por módulo

## Método de estudo

Explicação curta → videoaula → exemplo → prática → desafio → correção → mini projeto → revisão.

O progresso deve ser baseado no domínio real do aluno, e não apenas em aulas concluídas.

## Primeira versão

A v0.1.0 contém a fundação do app e o Módulo 0 como demonstração inicial.

## Builds

Os workflows em `.github/workflows/` foram preparados para:

- validar o projeto Flutter
- gerar APK Android
- gerar build Windows
- empacotar a versão Windows em instalador `.exe`
- criar releases automáticas por tag

## Desenvolvimento local

1. Instale o Flutter.
2. Rode `flutter pub get`.
3. Rode `flutter run`.

Para preparar os diretórios de plataforma caso ainda não existam:

```bash
flutter create . --platforms=android,windows
```

## Estrutura

- `lib/`: aplicativo Flutter
- `assets/content/`: conteúdo estruturado do curso
- `docs/`: mapa mestre e planejamento pedagógico
- `installer/`: configuração do instalador Windows
- `.github/workflows/`: CI e releases

O curso será expandido gradualmente conforme o aluno avançar.
