import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Spell checking is supported by native mobile text input. Desktop and
/// headless widget tests may not have a platform spell-checking service.
SpellCheckConfiguration? get writingSpellCheckConfiguration {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS =>
      const SpellCheckConfiguration(),
    _ => null,
  };
}
