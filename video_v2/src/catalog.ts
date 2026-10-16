export type VideoLessonPlan = {
  id: string;
  module: number;
  title: string;
  visualHook: string;
};

export const videoLessons: VideoLessonPlan[] = [
  {id: 'lesson_0_1', module: 0, title: 'Primeiros passos: pensar, testar e corrigir', visualHook: 'robô, algoritmo e primeiro print'},
  {id: 'lesson_1_1', module: 1, title: 'Valores e variáveis: dando nome aos dados', visualHook: 'caixas de dados, rótulos e memória'},
  {id: 'lesson_2_1', module: 2, title: 'Decisões: transformar regras em caminhos', visualHook: 'bifurcações, if/elif/else e limites'},
  {id: 'lesson_3_1', module: 3, title: 'Repetições: automatizar sem perder o controle', visualHook: 'loops, contador e repetição visual'},
  {id: 'lesson_4_1', module: 4, title: 'Coleções: escolher uma estrutura para os dados', visualHook: 'listas, cartões e dicionários'},
  {id: 'lesson_5_1', module: 5, title: 'Funções e organização do raciocínio', visualHook: 'blocos reutilizáveis e fluxo modular'},
  {id: 'lesson_6_1', module: 6, title: 'Arquivos, erros e módulos', visualHook: 'arquivos, salvamento e tratamento de falhas'},
  {id: 'lesson_7_1', module: 7, title: 'Debugging, testes e refatoração', visualHook: 'investigação de bugs e antes/depois'},
  {id: 'lesson_8_1', module: 8, title: 'APIs, JSON e documentação', visualHook: 'requisição, resposta e dados viajando'},
  {id: 'lesson_9_1', module: 9, title: 'Banco de dados com SQLite', visualHook: 'tabelas, CRUD e persistência'},
  {id: 'lesson_10_1', module: 10, title: 'Projetos maiores, OOP e ambientes', visualHook: 'arquitetura, pastas e objetos'},
  {id: 'lesson_11_1', module: 11, title: 'Git e GitHub na prática', visualHook: 'commits, branches e linha do tempo'},
  {id: 'lesson_12_1', module: 12, title: 'Desenvolvimento independente', visualHook: 'planejar, pesquisar, construir e testar sozinho'},
];
