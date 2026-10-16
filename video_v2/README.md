# Código Zero — Videoaulas V2

Pipeline audiovisual do curso usando **TypeScript + Remotion + FFmpeg**.

## Objetivo visual

- Full HD 1920x1080, 16:9.
- Português do Brasil.
- Personagem-apresentadora estilizada com movimento leve e sincronização visual com a fala.
- Trocas de cena acompanhando a narração.
- Código real aparecendo passo a passo.
- Motion graphics para conceitos abstratos.
- Legendas/cartões com apenas a ideia importante da cena.
- Momentos mais cinematográficos reservados para desafios, comparações e aberturas de módulo.

## Regra pedagógica

O vídeo reforça a aula, mas não substitui prática, desafio, correção e revisão. A ordem visual deve favorecer compreensão: ideia curta → exemplo visual → código → erro comum → aplicação.

## Estado

- `lesson_0_1`: piloto V2 implementado e renderizado em Full HD.
- `lesson_1_1` até `lesson_12_1`: catalogadas para produção no mesmo motor.
- Os vídeos antigos continuam no aplicativo até cada V2 estar completo e validado.

## Execução

```bash
cd video_v2
npm install
npm run studio
npm run render:lesson0
```

A narração do piloto deve ser colocada em `public/voice.wav`. Os próximos vídeos seguirão o mesmo padrão e ganharão composições próprias conforme os roteiros forem fechados.
