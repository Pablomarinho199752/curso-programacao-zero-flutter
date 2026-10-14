import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/status_chip.dart';
import 'lesson_destination.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({
    super.key,
    required this.modules,
    required this.progressStore,
  });

  final List<CourseModule> modules;
  final ProgressStore progressStore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      children: [
        Text(
          'Mapa completo do curso',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Você pode enxergar toda a trilha desde o começo. O próximo módulo só abre depois que o domínio do anterior for comprovado — concluir telas ou acertar um quiz, sozinho, não basta.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        ...modules.asMap().entries.map((entry) {
          final index = entry.key;
          final module = entry.value;
          final unlocked = progressStore.isModuleUnlocked(modules, index);
          final mastered = progressStore.isModuleMastered(module.id);
          final lessonIds = module.lessons.map((lesson) => lesson.id);
          final completion = progressStore.completionFor(lessonIds);
          final previousNumber = index > 0 ? modules[index - 1].number : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Material(
              color: unlocked ? Colors.white : const Color(0xFFF2F3F8),
              elevation: unlocked ? 2 : 0,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(26),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                initiallyExpanded: index == 0,
                tilePadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: const Border(),
                collapsedShape: const Border(),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: unlocked
                      ? Text(
                          '${module.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : Icon(
                          Icons.lock_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Módulo ${module.number} — ${module.title}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (mastered)
                      const _ModuleStateChip(
                        icon: Icons.verified_rounded,
                        label: 'Dominado',
                      )
                    else if (!unlocked)
                      const _ModuleStateChip(
                        icon: Icons.lock_rounded,
                        label: 'Bloqueado',
                      )
                    else
                      const _ModuleStateChip(
                        icon: Icons.play_arrow_rounded,
                        label: 'Disponível',
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(module.description),
                      if (module.lessons.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: completion,
                            minHeight: 7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? scheme.primaryContainer.withValues(alpha: 0.35)
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.rocket_launch_rounded,
                          color: unlocked
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Projeto do módulo',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(module.project),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!unlocked) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lock_clock_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '🔒 Libera quando o Módulo $previousNumber estiver realmente dominado. O domínio será validado por tarefas variadas: entender, modificar, criar, corrigir e explicar código.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (unlocked && module.lessons.isEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Conteúdo em produção. A estrutura deste módulo já faz parte da trilha e as aulas serão adicionadas antes de ele ser liberado para estudo.',
                      ),
                    ),
                  ],
                  if (unlocked)
                    ...module.lessons.map((lesson) {
                      final status = progressStore.statusFor(lesson.id);
                      final done = progressStore.forLesson(lesson.id).completed.length;
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Material(
                          color: const Color(0xFFF8F9FD),
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => lessonDestination(
                                  lesson: lesson,
                                  progressStore: progressStore,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.school_rounded,
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
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 9),
                                        StatusChip(status: status),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    children: [
                                      Text(
                                        '$done/8',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ModuleStateChip extends StatelessWidget {
  const _ModuleStateChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
