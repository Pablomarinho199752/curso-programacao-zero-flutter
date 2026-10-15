import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import 'generic_module_lesson_screen.dart';
import 'lesson_screen.dart';
import 'lesson_workspace_screen.dart';
import 'module1_lesson_screen.dart';

Widget lessonDestination({
  required CourseLesson lesson,
  required ProgressStore progressStore,
}) {
  final Widget lessonChild;

  if (lesson.id.startsWith('lesson_1_')) {
    lessonChild = Module1LessonScreen(
      lesson: lesson,
      progressStore: progressStore,
    );
  } else if (!lesson.id.startsWith('lesson_0_')) {
    lessonChild = GenericModuleLessonScreen(
      lesson: lesson,
      progressStore: progressStore,
    );
  } else {
    lessonChild = LessonScreen(
      lesson: lesson,
      progressStore: progressStore,
    );
  }

  return LessonWorkspaceScreen(
    lesson: lesson,
    progressStore: progressStore,
    lessonChild: lessonChild,
  );
}
