import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/status_chip.dart';
import 'lesson_screen.dart';

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
    final lessons = modules.expand((m) => m.lessons).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Seu progresso',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'As oito etapas registram o percurso. O desafio tem autoavaliação; revise sua compreensão com o ChatGPT.',
        ),
        const SizedBox(height: 20),
        ...lessons.map(
          (lesson) => Card(
            child: ListTile(
              title: Text('Aula ${lesson.number} — ${lesson.title}'),
              trailing: Text(
                '${progressStore.forLesson(lesson.id).completed.length}/8',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    lesson: lesson,
                    progressStore: progressStore,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(status: progressStore.statusFor(lesson.id)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
