import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/progress_store.dart';
import 'lesson_screen.dart';
import 'module1_lesson_screen.dart';

Widget lessonDestination({
  required CourseLesson lesson,
  required ProgressStore progressStore,
}) {
  if (lesson.id.startsWith('lesson_1_')) {
    return Module1LessonScreen(lesson: lesson, progressStore: progressStore);
  }
  return LessonScreen(lesson: lesson, progressStore: progressStore);
}
