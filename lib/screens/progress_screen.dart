import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/status_chip.dart';

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
        Text('Seu progresso', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('A cor muda conforme você demonstra domínio nas atividades.'),
        const SizedBox(height: 20),
        ...lessons.map(
          (lesson) => Card(
            child: ListTile(
              title: Text('Aula ${lesson.number} — ${lesson.title}'),
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
