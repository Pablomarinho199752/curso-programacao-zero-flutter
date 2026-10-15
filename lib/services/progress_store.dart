import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_models.dart';

class LessonProgress {
  int step = 0;
  int updatedAtMs = 0;
  final Set<int> completed = {};
  final Map<String, String> drafts = {};
  final Set<String> checks = {};
  final Map<String, int> attempts = {};
  final Map<String, int> answers = {};

  Map<String, dynamic> toJson() => {
        'step': step,
        'updatedAtMs': updatedAtMs,
        'completed': completed.toList()..sort(),
        'drafts': drafts,
        'checks': checks.toList()..sort(),
        'attempts': attempts,
        'answers': answers,
      };

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    final progress = LessonProgress();
    final rawStep = json['step'];
    progress.step = rawStep is num ? rawStep.toInt().clamp(0, 7) : 0;
    final rawUpdatedAt = json['updatedAtMs'];
    progress.updatedAtMs = rawUpdatedAt is num ? rawUpdatedAt.toInt() : 0;

    final completed = json['completed'];
    if (completed is List) {
      progress.completed.addAll(
        completed
            .whereType<num>()
            .map((value) => value.toInt())
            .where((value) => value >= 0 && value < 8),
      );
    }

    final drafts = json['drafts'];
    if (drafts is Map) {
      for (final entry in drafts.entries) {
        if (entry.key is String && entry.value is String) {
          progress.drafts[entry.key as String] = entry.value as String;
        }
      }
    }

    final checks = json['checks'];
    if (checks is List) {
      progress.checks.addAll(checks.whereType<String>());
    }

    final attempts = json['attempts'];
    if (attempts is Map) {
      for (final entry in attempts.entries) {
        if (entry.key is String && entry.value is num) {
          progress.attempts[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }

    final answers = json['answers'];
    if (answers is Map) {
      for (final entry in answers.entries) {
        if (entry.key is String && entry.value is num) {
          progress.answers[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }
    return progress;
  }

  LessonProgress();
}

class ProgressStore extends ChangeNotifier {
  static const _lessonStorageKey = 'onboarding_v1';
  static const _masteryStorageKey = 'module_mastery_v1';
  static const _metaStorageKey = 'course_meta_v1';

  final Map<String, LessonProgress> _lessons = {};
  final Set<String> _masteredModules = {};
  SharedPreferences? _prefs;
  Future<void> _pending = Future.value();

  String? saveError;
  bool recoveredData = false;
  String? _lastLessonId;
  int _lastStep = 0;
  int _updatedAtMs = 0;

  String? get lastLessonId => _lastLessonId;
  int get lastStep => _lastStep;
  int get updatedAtMs => _updatedAtMs;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(_lessonStorageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.key is! String || entry.value is! Map) continue;
            try {
              _lessons[entry.key as String] = LessonProgress.fromJson(
                Map<String, dynamic>.from(entry.value as Map),
              );
            } catch (_) {
              recoveredData = true;
            }
          }
        }
      }

      final masteryRaw = _prefs!.getStringList(_masteryStorageKey);
      if (masteryRaw != null) {
        _masteredModules.addAll(
          masteryRaw.where((id) => id.startsWith('module_')),
        );
      }

      final metaRaw = _prefs!.getString(_metaStorageKey);
      if (metaRaw != null) {
        final decoded = jsonDecode(metaRaw);
        if (decoded is Map) {
          final meta = Map<String, dynamic>.from(decoded);
          final lessonId = meta['lastLessonId'];
          if (lessonId is String && lessonId.startsWith('lesson_')) {
            _lastLessonId = lessonId;
          }
          final step = meta['lastStep'];
          _lastStep = step is num ? step.toInt().clamp(0, 7) : 0;
          final updated = meta['updatedAtMs'];
          _updatedAtMs = updated is num ? updated.toInt() : 0;
        }
      }
    } catch (_) {
      recoveredData = true;
      saveError =
          'Não foi possível recuperar todo o progresso. Você pode continuar estudando e tentar salvar novamente.';
    }
    notifyListeners();
  }

  LessonProgress forLesson(String id) =>
      _lessons.putIfAbsent(id, LessonProgress.new);

  Future<void> update(String id, void Function(LessonProgress) change) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final progress = forLesson(id);
    change(progress);
    progress.updatedAtMs = now;
    _lastLessonId = id;
    _lastStep = progress.step.clamp(0, 7);
    _updatedAtMs = now;
    notifyListeners();
    return save();
  }

  Future<void> markVisited(String lessonId, int step) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _lastLessonId = lessonId;
    _lastStep = step.clamp(0, 7);
    _updatedAtMs = now;
    notifyListeners();
    return save();
  }

  Map<String, dynamic> cloudState() => {
        'schemaVersion': 2,
        'updatedAtMs': _updatedAtMs,
        'lastLessonId': _lastLessonId,
        'lastStep': _lastStep,
        'masteredModules': _masteredModules.toList()..sort(),
        'lessons': _lessons.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

  Future<void> mergeCloudState(Map<String, dynamic> remote) async {
    final remoteLessons = remote['lessons'];
    if (remoteLessons is Map) {
      for (final entry in remoteLessons.entries) {
        if (entry.key is! String || entry.value is! Map) continue;
        final lessonId = entry.key as String;
        final incoming = LessonProgress.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
        final local = _lessons[lessonId];
        if (local == null) {
          _lessons[lessonId] = incoming;
          continue;
        }

        local.completed.addAll(incoming.completed);
        local.checks.addAll(incoming.checks);
        local.step = local.step > incoming.step ? local.step : incoming.step;

        final attemptKeys = <String>{
          ...local.attempts.keys,
          ...incoming.attempts.keys,
        };
        for (final key in attemptKeys) {
          final localValue = local.attempts[key] ?? 0;
          final remoteValue = incoming.attempts[key] ?? 0;
          local.attempts[key] =
              localValue > remoteValue ? localValue : remoteValue;
        }

        if (incoming.updatedAtMs > local.updatedAtMs) {
          local.drafts
            ..clear()
            ..addAll(incoming.drafts);
          local.answers
            ..clear()
            ..addAll(incoming.answers);
          local.updatedAtMs = incoming.updatedAtMs;
        }
      }
    }

    final remoteMastery = remote['masteredModules'];
    if (remoteMastery is List) {
      _masteredModules.addAll(
        remoteMastery.whereType<String>().where((id) => id.startsWith('module_')),
      );
    }

    final remoteUpdated = remote['updatedAtMs'];
    final remoteUpdatedAtMs = remoteUpdated is num ? remoteUpdated.toInt() : 0;
    if (remoteUpdatedAtMs > _updatedAtMs) {
      final remoteLastLesson = remote['lastLessonId'];
      if (remoteLastLesson is String && remoteLastLesson.startsWith('lesson_')) {
        _lastLessonId = remoteLastLesson;
      }
      final remoteStep = remote['lastStep'];
      if (remoteStep is num) {
        _lastStep = remoteStep.toInt().clamp(0, 7);
      }
      _updatedAtMs = remoteUpdatedAtMs;
    }

    notifyListeners();
    await save();
  }

  Future<void> save() {
    final lessonSnapshot = jsonEncode(
      _lessons.map((key, value) => MapEntry(key, value.toJson())),
    );
    final masterySnapshot = _masteredModules.toList()..sort();
    final metaSnapshot = jsonEncode({
      'lastLessonId': _lastLessonId,
      'lastStep': _lastStep,
      'updatedAtMs': _updatedAtMs,
    });

    _pending = _pending.then((_) async {
      try {
        _prefs ??= await SharedPreferences.getInstance();
        final lessonOk = await _prefs!.setString(_lessonStorageKey, lessonSnapshot);
        final masteryOk =
            await _prefs!.setStringList(_masteryStorageKey, masterySnapshot);
        final metaOk = await _prefs!.setString(_metaStorageKey, metaSnapshot);
        if (!lessonOk || !masteryOk || !metaOk) {
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

  bool isModuleMastered(String moduleId) =>
      _masteredModules.contains(moduleId);

  bool isModuleUnlocked(List<CourseModule> modules, int index) {
    if (index <= 0) return true;
    return isModuleMastered(modules[index - 1].id);
  }

  Future<void> setModuleMastered(String moduleId, bool mastered) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (mastered) {
      _masteredModules.add(moduleId);
    } else {
      _masteredModules.remove(moduleId);
    }
    _updatedAtMs = now;
    notifyListeners();
    return save();
  }

  SkillStatus statusFor(String id) {
    final progress = forLesson(id);
    if (progress.completed.length == 8) return SkillStatus.mastered;
    return progress.completed.isNotEmpty ||
            progress.drafts.isNotEmpty ||
            progress.checks.isNotEmpty
        ? SkillStatus.inProgress
        : SkillStatus.notStarted;
  }

  double completionFor(Iterable<String> ids) {
    final all = ids.toList();
    if (all.isEmpty) return 0;
    return all.fold<int>(
          0,
          (sum, id) => sum + forLesson(id).completed.length,
        ) /
        (all.length * 8);
  }
}
