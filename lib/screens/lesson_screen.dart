import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import '../widgets/section_card.dart';
import '../widgets/status_chip.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.progressStore,
  });

  final CourseLesson lesson;
  final ProgressStore progressStore;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _practiceController = TextEditingController();
  late final List<int?> _answers = List<int?>.filled(widget.lesson.quiz.length, null);
  String? _practiceFeedback;
  bool _quizChecked = false;

  @override
  void initState() {
    super.initState();
    if (widget.progressStore.statusFor(widget.lesson.id) == SkillStatus.notStarted) {
      widget.progressStore.setStatus(widget.lesson.id, SkillStatus.inProgress);
    }
  }

  @override
  void dispose() {
    _practiceController.dispose();
    super.dispose();
  }

  Future<void> _openVideo() async {
    final uri = Uri.parse(widget.lesson.videoUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a videoaula.')),
      );
    }
  }

  void _checkPractice() {
    final value = _practiceController.text.trim();
    final correct = value == widget.lesson.practiceAnswer.trim();
    setState(() {
      _practiceFeedback = correct
          ? 'Boa! Esse é exatamente o resultado que o programa mostra.'
          : 'Ainda não. Dica: o print mostra o texto que está dentro dos parênteses, sem as aspas.';
    });
  }

  void _checkQuiz() {
    setState(() => _quizChecked = true);
    final allAnswered = _answers.every((answer) => answer != null);
    final allCorrect = allAnswered && List.generate(
      widget.lesson.quiz.length,
      (index) => _answers[index] == widget.lesson.quiz[index].correctIndex,
    ).every((e) => e);

    if (allCorrect) {
      widget.progressStore.setStatus(widget.lesson.id, SkillStatus.mastered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(
        title: Text('Aula ${lesson.number}'),
      ),
      body: AnimatedBuilder(
        animation: widget.progressStore,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(lesson.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(lesson.objective, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(status: widget.progressStore.statusFor(lesson.id)),
              ),
              const SizedBox(height: 20),
              SectionCard(
                title: '1. Explicação curta',
                icon: Icons.menu_book,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lesson.theory
                      .map((paragraph) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(paragraph),
                          ))
                      .toList(),
                ),
              ),
              SectionCard(
                title: '2. Videoaula',
                icon: Icons.ondemand_video,
                child: FilledButton.icon(
                  onPressed: _openVideo,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Assistir videoaula'),
                ),
              ),
              SectionCard(
                title: '3. Exemplo',
                icon: Icons.code,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    lesson.code,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                  ),
                ),
              ),
              SectionCard(
                title: '4. Prática',
                icon: Icons.edit_note,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.practicePrompt),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _practiceController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Digite o resultado',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(onPressed: _checkPractice, child: const Text('Verificar')),
                    if (_practiceFeedback != null) ...[
                      const SizedBox(height: 10),
                      Text(_practiceFeedback!),
                    ],
                  ],
                ),
              ),
              SectionCard(
                title: '5. Desafio',
                icon: Icons.local_fire_department,
                child: Text(lesson.challenge),
              ),
              SectionCard(
                title: '6. Três perguntas',
                icon: Icons.quiz,
                child: Column(
                  children: [
                    for (var i = 0; i < lesson.quiz.length; i++) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${i + 1}. ${lesson.quiz[i].question}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (var option = 0; option < lesson.quiz[i].options.length; option++)
                        RadioListTile<int>(
                          value: option,
                          groupValue: _answers[i],
                          title: Text(lesson.quiz[i].options[option]),
                          onChanged: (value) => setState(() {
                            _answers[i] = value;
                            _quizChecked = false;
                          }),
                        ),
                      if (_quizChecked && _answers[i] != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _answers[i] == lesson.quiz[i].correctIndex
                                ? '✅ Correto. ${lesson.quiz[i].explanation}'
                                : '❌ Ainda não. ${lesson.quiz[i].explanation}',
                          ),
                        ),
                      const Divider(height: 28),
                    ],
                    FilledButton.icon(
                      onPressed: _checkQuiz,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Conferir respostas'),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: '7. Revisão',
                icon: Icons.replay,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lesson.review.map((item) => Text('• $item')).toList(),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => widget.progressStore.setStatus(
                  lesson.id,
                  SkillStatus.inProgress,
                ),
                icon: const Text('🟡'),
                label: const Text('Marcar como em desenvolvimento'),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
