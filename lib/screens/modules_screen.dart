import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/status_chip.dart';
import 'generic_module_mastery_screen.dart';
import 'lesson_destination.dart';
import 'module_mastery_screen.dart';

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
          'Todos os módulos ficam visíveis desde o começo. Concluir aulas não abre o próximo módulo: primeiro você precisa comprovar domínio com tarefas variadas.',
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
          final nextNumber = index + 1 < modules.length ? modules[index + 1].number : null;
          final readyForMastery =
              unlocked && module.lessons.isNotEmpty && completion >= 1 && !mastered;

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
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Módulo ${module.number} — ${module.title}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
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
                  _ProjectCard(module: module, unlocked: unlocked),
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
                              '🔒 Libera quando o Módulo $previousNumber estiver dominado. Concluir o percurso anterior, sozinho, não basta.',
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
                      child: const Text('Conteúdo em produção.'),
                    ),
                  ],
                  if (readyForMastery) ...[
                    const SizedBox(height: 12),
                    Container(
                      key: ValueKey('${module.id}_mastery_callout'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primaryContainer,
                            scheme.secondaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Percurso concluído. Falta provar domínio.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            module.number == 0
                                ? 'Faça o desafio de previsão, correção, criação e explicação. Ao passar, o Módulo $nextNumber abre automaticamente.'
                                : nextNumber == null
                                    ? 'Reúna evidências de entender, corrigir, criar, explicar e executar em ambiente real para concluir o domínio do curso.'
                                    : 'Reúna evidências de entender, corrigir, criar, explicar e executar em ambiente real. Ao passar, o Módulo $nextNumber abre automaticamente.',
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            key: module.number == 0
                                ? const ValueKey('module_0_mastery_button')
                                : ValueKey('${module.id}_mastery_button'),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => module.number == 0
                                    ? Module0MasteryScreen(
                                        progressStore: progressStore,
                                      )
                                    : GenericModuleMasteryScreen(
                                        module: module,
                                        progressStore: progressStore,
                                        nextModuleNumber: nextNumber,
                                      ),
                              ),
                            ),
                            icon: const Icon(Icons.lock_open_rounded),
                            label: Text(
                              nextNumber == null
                                  ? 'Fazer desafio final de domínio'
                                  : 'Fazer desafio de domínio',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (unlocked && mastered) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              nextNumber == null
                                  ? 'Domínio final registrado. Você concluiu a trilha e o projeto final continua aberto para evoluir.'
                                  : 'Domínio comprovado. O Módulo $nextNumber está liberado.',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
                                              ?.copyWith(fontWeight: FontWeight.w800),
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

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.module, required this.unlocked});

  final CourseModule module;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
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
            color: unlocked ? scheme.primary : scheme.onSurfaceVariant,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
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
      ),
    );
  }
}
