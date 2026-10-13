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
    final lessons = modules.expand((m) => m.lessons).toList();
    final progress = progressStore.completionFor(lessons.map((l) => l.id));
    final nextLesson = lessons.cast<CourseLesson?>().firstWhere(
          (lesson) => lesson != null && progressStore.statusFor(lesson.id) != SkillStatus.mastered,
          orElse: () => lessons.isEmpty ? null : lessons.last,
        );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Curso de Programação do Zero', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Aprenda Python praticando, errando, corrigindo e construindo projetos.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seu progresso', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress, minHeight: 10),
                const SizedBox(height: 8),
                Text('${(progress * 100).round()}% concluído'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (nextLesson != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Continuar estudando', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('Aula ${nextLesson.number} — ${nextLesson.title}'),
                  const SizedBox(height: 10),
                  StatusChip(status: progressStore.statusFor(nextLesson.id)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          lesson: nextLesson,
                          progressStore: progressStore,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Abrir aula'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text('Como vamos aprender', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Explicação curta')),
            Chip(label: Text('Videoaula')),
            Chip(label: Text('Exemplo')),
            Chip(label: Text('Prática')),
            Chip(label: Text('Desafio')),
            Chip(label: Text('Correção por pistas')),
            Chip(label: Text('Mini projeto')),
            Chip(label: Text('Revisão')),
          ],
        ),
      ],
    );
  }
}
