import 'package:flutter/material.dart';

import '../models/course_models.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final SkillStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = switch (status) {
      SkillStatus.notStarted => const Color(0xFFFFECEC),
      SkillStatus.inProgress => const Color(0xFFFFF4D6),
      SkillStatus.mastered => const Color(0xFFE4F8EA),
    };
    final foreground = switch (status) {
      SkillStatus.notStarted => const Color(0xFFB42318),
      SkillStatus.inProgress => const Color(0xFF8A5700),
      SkillStatus.mastered => const Color(0xFF177245),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 7),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (status == SkillStatus.mastered) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_rounded, size: 16, color: scheme.primary),
          ],
        ],
      ),
    );
  }
}
