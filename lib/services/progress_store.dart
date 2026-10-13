import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_models.dart';

class ProgressStore extends ChangeNotifier {
  final Map<String, SkillStatus> _statuses = {};
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  SkillStatus statusFor(String lessonId) {
    if (_statuses.containsKey(lessonId)) return _statuses[lessonId]!;
    final persisted = _prefs?.getString('lesson_status_$lessonId');
    final status = SkillStatusX.fromStorage(persisted);
    _statuses[lessonId] = status;
    return status;
  }

  Future<void> setStatus(String lessonId, SkillStatus status) async {
    _statuses[lessonId] = status;
    await _prefs?.setString('lesson_status_$lessonId', status.storageValue);
    notifyListeners();
  }

  double completionFor(Iterable<String> lessonIds) {
    final ids = lessonIds.toList();
    if (ids.isEmpty) return 0;
    final mastered = ids.where((id) => statusFor(id) == SkillStatus.mastered).length;
    return mastered / ids.length;
  }
}
