import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:curso_programacao_zero/services/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('modo claro é o padrão', () async {
    final controller = ThemeController();
    await controller.initialize();

    expect(controller.isDark, isFalse);
    expect(controller.themeMode, ThemeMode.light);
  });

  test('modo escuro fica salvo entre inicializações', () async {
    final first = ThemeController();
    await first.initialize();
    await first.setDark(true);

    final second = ThemeController();
    await second.initialize();

    expect(second.isDark, isTrue);
    expect(second.themeMode, ThemeMode.dark);
  });

  test('toggle alterna claro e escuro', () async {
    final controller = ThemeController();
    await controller.initialize();

    await controller.toggle();
    expect(controller.isDark, isTrue);

    await controller.toggle();
    expect(controller.isDark, isFalse);
  });
}
