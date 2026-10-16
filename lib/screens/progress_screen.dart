import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/status_chip.dart';
import 'lesson_destination.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.modules,
    required this.progressStore,
  });

  final List<CourseModule> modules;
  final ProgressStore progressStore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unlockedModules = modules.asMap().entries
        .where((entry) => progressStore.isModuleUnlocked(modules, entry.key))
        .map((entry) => entry.value)
        .toList();
    final lessons = unlockedModules.expand((module) => module.lessons).toList();
    final progress = progressStore.completionFor(lessons.map((lesson) => lesson.id));
    final completedSteps = lessons.fold<int>(
      0,
      (total, lesson) =>
          total + progressStore.forLesson(lesson.id).completed.length,
    );
    final totalSteps = lessons.length * 8;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      children: [
        Text(
          'Seu progresso',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Aqui aparecem somente os módulos já desbloqueados. Conclusão e domínio continuam separados: o que vale é o que você consegue entender, criar, corrigir e explicar.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final ring = SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              );
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completedSteps de $totalSteps etapas disponíveis concluídas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress == 1
                        ? 'Percurso disponível concluído. O próximo módulo continua dependendo da validação de domínio.'
                        : 'Continue no seu ritmo. Módulos bloqueados não diminuem sua porcentagem atual.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              );
              if (constraints.maxWidth >= 620) {
                return Row(
                  children: [
                    ring,
                    const SizedBox(width: 24),
                    Expanded(child: text),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ring,
                  const SizedBox(height: 20),
                  text,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Aulas e evidências',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...lessons.map((lesson) {
          final done = progressStore.forLesson(lesson.id).completed.length;
          final lessonProgress = done / 8;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => lessonDestination(
                      lesson: lesson,
                      progressStore: progressStore,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.task_alt_rounded,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aula ${lesson.number}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  lesson.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$done/8',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: lessonProgress,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StatusChip(status: progressStore.statusFor(lesson.id)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.psychology_alt_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'O app registra o percurso. A confirmação de domínio continua sendo feita pelas suas respostas, seus códigos, suas correções e sua capacidade de explicar o que fez.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
