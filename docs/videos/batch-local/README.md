# Videoaulas 6–12: montagem local

O usuário aprovou o estilo da prévia e pediu fala mais lenta. Este lote utiliza Kokoro ONNX, voz feminina brasileira pf_dora, velocidade 0.75, pausas de 0.55 s entre frases e 6 s entre cenas. É uma voz diferente da Juno. Não consome créditos Higgsfield/Runway/HeyGen.

Estado: produção de prévias completas para revisão da nova voz. Não substituir links do app antes de conferir áudio e vídeo; a aprovação anterior foi do estilo e da amostra Juno. Nenhum código do app é alterado.

## Reprodução

1. Instalar Python com `kokoro-onnx`, `numpy`, `Pillow` e FFmpeg no ambiente de produção audiovisual.
2. Baixar `kokoro-v1.0.onnx` e `voices-v1.0.bin` da versão `model-files-v1.1` em https://github.com/thewh1teagle/kokoro-onnx/releases e colocar como `models/kokoro.onnx` e `models/voices.bin`.
3. Copiar `../batch-juno/production.json` para esta pasta como `production.json`.
4. Executar `generate_audio.py` e depois `render_batch.py`. Preferir disco temporário local para os quadros intermediários; copiar somente os resultados concluídos.
5. Conferir duração real, legibilidade, pronúncia de nomes técnicos, legendas e exemplos antes de integração.

Modelo Kokoro-82M: https://huggingface.co/hexgrad/Kokoro-82M (Apache-2.0). Runtime: https://github.com/thewh1teagle/kokoro-onnx . As dependências e modelos são do ambiente de vídeo e não entram no aplicativo Flutter.

## Limites da prévia

Legendas usam o roteiro, segmentadas por frase e pelo tempo real da síntese. Trechos longos são repartidos proporcionalmente; não há alinhamento palavra a palavra. Tela do editor é uma composição didática, não uma gravação de IDE. Exemplos foram executados separadamente na conferência dos roteiros. A audição completa e a aprovação da nova voz estão pendentes. Nenhum link final público do lote foi integrado.
