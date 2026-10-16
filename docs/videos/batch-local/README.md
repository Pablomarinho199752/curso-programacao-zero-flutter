# Videoaulas 6–12: montagem local

Este lote utiliza Kokoro ONNX, voz feminina brasileira `pf_dora`, velocidade 0.75, pausas de 0.55 s entre frases e 6 s entre cenas. Não consome créditos de geração de vídeo/voz pagos.

Estado final: as sete aulas 6–12 foram reproduzidas a partir do pipeline salvo, renderizadas, hospedadas e conectadas ao mapa `assets/content/video_urls.json`. Os sete links públicos foram conferidos por leitura remota com FFprobe e permanecem entre 3 e 7 minutos. O conteúdo pedagógico, Firebase, conta, progresso, Python e modo escuro não foram alterados por este lote.

## Reprodução

1. Instalar Python com `kokoro-onnx`, `numpy`, `Pillow` e FFmpeg no ambiente de produção audiovisual.
2. Baixar `kokoro-v1.0.onnx` e `voices-v1.0.bin` da versão `model-files-v1.1` do projeto `kokoro-onnx` e colocar como `models/kokoro.onnx` e `models/voices.bin`.
3. Copiar `../batch-juno/production.json` para esta pasta como `production.json`.
4. Executar `generate_audio.py` e depois `render_batch.py`.
5. Conferir duração real, legibilidade, pronúncia de nomes técnicos, legendas e exemplos antes de nova substituição.

## Validação final

- 7/7 MP4 com áudio e vídeo;
- 7/7 entre 3 e 7 minutos;
- cobertura do roteiro nas legendas;
- exemplos de código conferidos separadamente;
- 7/7 URLs públicas lidas remotamente por FFprobe;
- nenhum crédito pago consumido nesta reprodução local;
- reprodução em aparelho Android/Windows real continua sendo a checagem final de uso depois do build.

As legendas usam o roteiro, segmentadas por frase e pelo tempo real da síntese. Trechos longos são repartidos proporcionalmente; não há alinhamento palavra a palavra. A tela do editor é uma composição didática, não uma gravação de IDE.
