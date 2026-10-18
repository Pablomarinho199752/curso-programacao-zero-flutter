import 'package:flutter/widgets.dart';

/// Predictive suggestions and autocorrection are supplied by the user's
/// installed Android keyboard via TextField's autocorrect/enableSuggestions.
/// An explicit Flutter spell-check service is not required and can fail in
/// headless widget tests or on platforms without a spell-check provider.
SpellCheckConfiguration? get writingSpellCheckConfiguration => null;
