import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course_models.dart';

class CourseRepository {
  const CourseRepository();

  Future<List<CourseModule>> loadModules() async {
    final raw = await rootBundle.loadString('assets/content/modules.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['modules'] as List<dynamic>)
        .map((e) => CourseModule.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
