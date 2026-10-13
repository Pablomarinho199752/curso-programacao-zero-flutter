import 'package:flutter/material.dart';

import '../models/course_models.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final SkillStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      SkillStatus.notStarted => scheme.errorContainer,
      SkillStatus.inProgress => scheme.tertiaryContainer,
      SkillStatus.mastered => scheme.primaryContainer,
    };

    return Chip(
      avatar: Text(status.emoji),
      label: Text(status.label),
      backgroundColor: color,
    );
  }
}
