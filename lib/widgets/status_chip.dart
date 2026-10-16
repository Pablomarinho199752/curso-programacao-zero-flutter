import 'package:flutter/material.dart';

import '../models/course_models.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final SkillStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = switch (status) {
      SkillStatus.notStarted => scheme.errorContainer,
      SkillStatus.inProgress => scheme.secondaryContainer,
      SkillStatus.mastered => scheme.tertiaryContainer,
    };
    final foreground = switch (status) {
      SkillStatus.notStarted => scheme.onErrorContainer,
      SkillStatus.inProgress => scheme.onSecondaryContainer,
      SkillStatus.mastered => scheme.onTertiaryContainer,
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
          Flexible(
            child: Text(
              status.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (status == SkillStatus.mastered) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_rounded, size: 16, color: foreground),
          ],
        ],
      ),
    );
  }
}
