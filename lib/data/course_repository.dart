import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course_models.dart';

class CourseRepository {
  const CourseRepository();

  Future<List<CourseModule>> loadModules() async {
    final raw = await rootBundle.loadString('assets/content/modules.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final moduleMaps = (decoded['modules'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();

    final module1Raw = await rootBundle.loadString(
      'assets/content/module_1_lessons.json',
    );
    final module1Decoded = jsonDecode(module1Raw) as Map<String, dynamic>;
    final module1 = moduleMaps.firstWhere((module) => module['id'] == 'module_1');
    module1['lessons'] = module1Decoded['lessons'] as List<dynamic>;

    final advancedRaw = await rootBundle.loadString(
      'assets/content/module_2_12_lessons.json',
    );
    final advancedDecoded = jsonDecode(advancedRaw) as Map<String, dynamic>;
    final advancedModules =
        (advancedDecoded['modules'] as Map).cast<String, dynamic>();

    for (final module in moduleMaps) {
      final id = module['id'] as String;
      final advanced = advancedModules[id];
      if (advanced is Map<String, dynamic>) {
        module['lessons'] = advanced['lessons'] as List<dynamic>;
      } else if (advanced is Map) {
        module['lessons'] = advanced['lessons'] as List<dynamic>;
      }
    }

    final videoRaw = await rootBundle.loadString(
      'assets/content/video_urls.json',
    );
    final videoDecoded = jsonDecode(videoRaw) as Map<String, dynamic>;
    final videoUrls = (videoDecoded['lessons'] as Map).cast<String, dynamic>();

    for (final module in moduleMaps) {
      final lessons = (module['lessons'] as List<dynamic>?) ?? const [];
      for (final lesson in lessons) {
        if (lesson is! Map) continue;
        final lessonId = lesson['id'];
        if (lessonId is! String) continue;
        final stableUrl = videoUrls[lessonId];
        if (stableUrl is String && stableUrl.isNotEmpty) {
          lesson['newVideoUrl'] = stableUrl;
        }
      }
    }

    return moduleMaps.map(CourseModule.fromJson).toList();
  }
}
