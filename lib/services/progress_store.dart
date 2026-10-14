import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_models.dart';

class LessonProgress {
  int step = 0;
  final Set<int> completed = {};
  final Map<String, String> drafts = {};
  final Set<String> checks = {};
  final Map<String, int> attempts = {};
  final Map<String, int> answers = {};

  Map<String, dynamic> toJson() => {
    'step': step,
    'completed': completed.toList(),
    'drafts': drafts,
    'checks': checks.toList(),
    'attempts': attempts,
    'answers': answers,
  };

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    final p = LessonProgress();
    p.step = (json['step'] as int).clamp(0, 7);
    p.completed.addAll(
      (json['completed'] as List).cast<int>().where((n) => n >= 0 && n < 8),
    );
    p.drafts.addAll((json['drafts'] as Map).cast<String, String>());
    p.checks.addAll((json['checks'] as List).cast<String>());
    p.attempts.addAll((json['attempts'] as Map).cast<String, int>());
    p.answers.addAll((json['answers'] as Map).cast<String, int>());
    return p;
  }
  LessonProgress();
}

class ProgressStore extends ChangeNotifier {
  final Map<String, LessonProgress> _lessons = {};
  final Set<String> _masteredModules = {};
  SharedPreferences? _prefs;
  Future<void> _pending = Future.value();
  String? saveError;
  bool recoveredData = false;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString('onboarding_v1');
      if (raw != null) {
        final decoded = (jsonDecode(raw) as Map).cast<String, dynamic>();
        for (final entry in decoded.entries) {
          try {
            _lessons[entry.key] = LessonProgress.fromJson(
              (entry.value as Map).cast<String, dynamic>(),
            );
          } catch (_) {
            recoveredData = true;
          }
        }
      }
      final masteryRaw = _prefs!.getStringList('module_mastery_v1');
      if (masteryRaw != null) {
        _masteredModules.addAll(masteryRaw.where((id) => id.startsWith('module_')));
      }
    } catch (_) {
      recoveredData = true;
      saveError =
          'Não foi possível recuperar o progresso. Você pode estudar e tentar salvar novamente.';
    }
    notifyListeners();
  }

  LessonProgress forLesson(String id) =>
      _lessons.putIfAbsent(id, LessonProgress.new);

  Future<void> update(String id, void Function(LessonProgress) change) {
    change(forLesson(id));
    notifyListeners();
    return save();
  }

  Future<void> save() {
    final snapshot = jsonEncode(
      _lessons.map((key, value) => MapEntry(key, value.toJson())),
    );
    _pending = _pending.then((_) async {
      try {
        _prefs ??= await SharedPreferences.getInstance();
        if (!await _prefs!.setString('onboarding_v1', snapshot)) {
          throw StateError('save failed');
        }
        saveError = null;
      } catch (_) {
        saveError =
            'Não foi possível salvar no aparelho. Mantenha o app aberto e tente novamente.';
      }
      notifyListeners();
    });
    return _pending;
  }

  bool isModuleMastered(String moduleId) => _masteredModules.contains(moduleId);

  bool isModuleUnlocked(List<CourseModule> modules, int index) {
    if (index <= 0) return true;
    return isModuleMastered(modules[index - 1].id);
  }

  Future<void> setModuleMastered(String moduleId, bool mastered) {
    if (mastered) {
      _masteredModules.add(moduleId);
    } else {
      _masteredModules.remove(moduleId);
    }
    notifyListeners();
    final masterySnapshot = _masteredModules.toList()..sort();
    _pending = _pending.then((_) async {
      try {
        _prefs ??= await SharedPreferences.getInstance();
        if (!await _prefs!.setStringList('module_mastery_v1', masterySnapshot)) {
          throw StateError('save failed');
        }
        saveError = null;
      } catch (_) {
        saveError =
            'Não foi possível salvar no aparelho. Mantenha o app aberto e tente novamente.';
      }
      notifyListeners();
    });
    return _pending;
  }

  SkillStatus statusFor(String id) {
    final p = forLesson(id);
    if (p.completed.length == 8) return SkillStatus.mastered;
    return p.completed.isNotEmpty || p.drafts.isNotEmpty || p.checks.isNotEmpty
        ? SkillStatus.inProgress
        : SkillStatus.notStarted;
  }

  double completionFor(Iterable<String> ids) {
    final all = ids.toList();
    if (all.isEmpty) return 0;
    return all.fold<int>(0, (sum, id) => sum + forLesson(id).completed.length) /
        (all.length * 8);
  }
}
