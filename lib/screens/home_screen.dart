import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/status_chip.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.modules,
    required this.progressStore,
  });

  final List<CourseModule> modules;
  final ProgressStore progressStore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lessons = modules.expand((m) => m.lessons).toList();
    final progress = progressStore.completionFor(lessons.map((l) => l.id));
    final nextLesson = lessons.cast<CourseLesson?>().firstWhere(
      (lesson) =>
          lesson != null &&
          progressStore.statusFor(lesson.id) != SkillStatus.mastered,
      orElse: () => lessons.isEmpty ? null : lessons.last,
    );
    final completedSteps = lessons.fold<int>(
      0,
      (total, lesson) => total + progressStore.forLesson(lesson.id).completed.length,
    );
    final totalSteps = lessons.length * 8;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.22),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final intro = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'SEU CURSO PESSOAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Aprenda programação\ncomeçando do zero.',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Um passo por vez: entender, testar, errar, corrigir e construir.',
                    style: TextStyle(color: Color(0xFFE8E7FF), fontSize: 16, height: 1.45),
                  ),
                ],
              );

              final progressBadge = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 7,
                            backgroundColor: Colors.white.withValues(alpha: 0.17),
                            color: Colors.white,
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progresso geral',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedSteps de $totalSteps etapas',
                          style: const TextStyle(color: Color(0xFFE8E7FF)),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 24),
                    progressBadge,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [intro, const SizedBox(height: 22), progressBadge],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        if (progressStore.recoveredData || progressStore.saveError != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: scheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    progressStore.saveError ??
                        'Parte do progresso anterior não pôde ser recuperada. Revise as etapas e suas respostas.',
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final progressCard = _InfoCard(
              icon: Icons.auto_graph_rounded,
              title: 'Seu progresso',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(value: progress, minHeight: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progress * 100).round()}% das etapas concluídas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Seu progresso fica salvo neste aparelho. Concluir o percurso não significa dominar sozinho.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );

            final continueCard = _InfoCard(
              icon: Icons.play_circle_fill_rounded,
              title: progress == 1 ? 'Revisar Módulo 0' : 'Continuar estudando',
              accent: true,
              child: nextLesson == null
                  ? const Text('Nenhuma aula disponível.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aula ${nextLesson.number}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextLesson.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        StatusChip(status: progressStore.statusFor(nextLesson.id)),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LessonScreen(
                                  lesson: nextLesson,
                                  progressStore: progressStore,
                                ),
                              ),
                            ),
                            icon: Icon(progress == 1 ? Icons.replay_rounded : Icons.play_arrow_rounded),
                            label: Text(progress == 1 ? 'Revisar percurso' : 'Continuar agora'),
                          ),
                        ),
                      ],
                    ),
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: continueCard),
                  const SizedBox(width: 18),
                  Expanded(child: progressCard),
                ],
              );
            }
            return Column(
              children: [continueCard, const SizedBox(height: 18), progressCard],
            );
          },
        ),
        const SizedBox(height: 28),
        Text(
          'Como você vai aprender',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'O curso não é só leitura: cada etapa exige uma ação diferente.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _MethodChip(Icons.menu_book_rounded, 'Explicação'),
            _MethodChip(Icons.ondemand_video_rounded, 'Videoaula'),
            _MethodChip(Icons.code_rounded, 'Exemplo'),
            _MethodChip(Icons.edit_rounded, 'Prática'),
            _MethodChip(Icons.local_fire_department_rounded, 'Desafio'),
            _MethodChip(Icons.build_circle_rounded, 'Correção'),
            _MethodChip(Icons.rocket_launch_rounded, 'Mini projeto'),
            _MethodChip(Icons.replay_circle_filled_rounded, 'Revisão'),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent ? scheme.primary.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
