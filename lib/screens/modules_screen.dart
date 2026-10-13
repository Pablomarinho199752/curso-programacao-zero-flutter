import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/status_chip.dart';
import 'lesson_screen.dart';

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
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            title: Text('Módulo ${module.number} — ${module.title}'),
            subtitle: Text(module.description),
            children: module.lessons.map((lesson) {
              final status = progressStore.statusFor(lesson.id);
              return ListTile(
                title: Text('Aula ${lesson.number} — ${lesson.title}'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(status: status),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(
                      lesson: lesson,
                      progressStore: progressStore,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
