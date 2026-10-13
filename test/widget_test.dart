import 'package:flutter_test/flutter_test.dart';
import 'package:curso_programacao_zero/models/course_models.dart';

void main() {
  test('SkillStatus converte valor persistido corretamente', () {
    expect(SkillStatusX.fromStorage('mastered'), SkillStatus.mastered);
    expect(SkillStatusX.fromStorage('in_progress'), SkillStatus.inProgress);
    expect(SkillStatusX.fromStorage(null), SkillStatus.notStarted);
  });
}
