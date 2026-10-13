# Validação do Módulo 0

## Automatizada

SDK fixado em Flutter 3.35.7 nos workflows. `flutter analyze` e `flutter test` precedem os builds Android e Windows. CI produz APK e instalador Windows x64 como artefatos do PR, sem publicar uma release. O runtime nativo é gerado pelo bootstrap como na arquitetura original.

Testes cobrem: contrato do conteúdo, simulador e seus limites, dados inválidos, persistência/retomada, não herdar o antigo status de domínio, percurso completo com erro e pista, mini projeto, três perguntas, revisão, invalidação após edição, atualização do progresso e navegação desktop.

## Manual em aparelhos reais — necessário antes de publicar

| Verificação | Android | Windows |
| --- | --- | --- |
| Instalar e abrir o artefato do PR | Pendente | Pendente |
| Concluir percurso sem internet usando alternativa textual | Pendente | Pendente |
| Fechar/reabrir no meio da prática e recuperar texto/etapa | Pendente | Pendente |
| Fechar/reabrir após mini projeto e recuperar código | Pendente | Pendente |
| Abrir vídeo no navegador e voltar sem perder posição | Pendente | Pendente |
| Testar ausência de navegador/falha de abertura | Pendente | Pendente |
| Errar prática: pista antes de explicação; corrigir e continuar | Pendente | Pendente |
| Quiz incompleto/errado não conclui módulo | Pendente | Pendente |
| Editar atividade concluída: progresso exige revalidação | Pendente | Pendente |
| Copiar relatório e colar no ChatGPT | Pendente | Pendente |
| Tela estreita, rotação/redimensionamento e fonte ampliada | Pendente | Pendente |
| Teclado não cobre campo/botões; rolagem funciona | Pendente | Pendente |
| Leitor de tela, Tab/Enter/Espaço e foco nas alternativas | Pendente | Pendente |
| Instalador cria atalhos e abre com DLLs/assets presentes | N/A | Pendente |

Não confundir teste de widgets com instalação em aparelho. O ambiente local teve execução Flutter bloqueada por auto-review após tentativa de acesso ao serviço de metadados da infraestrutura; a execução de análise, testes e builds é delegada ao GitHub Actions. Registrar os resultados do PR antes de aprovar.

## Dados e limitações

- Respostas ficam no aparelho, em SharedPreferences. Não há servidor, conta ou sincronização.
- Escritas são serializadas; erro de salvamento fica visível e pode ser tentado novamente.
- Modificar uma atividade invalida sua conclusão e as posteriores; rascunhos são preservados.
- A v0.1 armazenava apenas domínio autodeclarado/quiz. A nova chave `onboarding_v1` não transforma esse dado em conclusão das oito etapas. Chaves antigas permanecem intactas.
- Desinstalar/apagar dados pode remover respostas. O relatório copiável serve à revisão, não é backup importável.
- O APK atual usa a assinatura de desenvolvimento gerada pelo template Flutter. Serve à avaliação, mas a publicação e atualização estável exigem configurar chave de assinatura persistente. Não prometer atualização sobre builds antigos assinados com outra chave.
- O instalador Windows ainda não é assinado digitalmente. A aprovação pedagógica não substitui os testes de instalação.
