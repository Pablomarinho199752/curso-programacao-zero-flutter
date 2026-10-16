import 'package:flutter/material.dart';

import 'data/course_repository.dart';
import 'models/course_models.dart';
import 'screens/cloud_account_screen.dart';
import 'screens/home_screen.dart';
import 'screens/modules_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/python_lab_screen.dart';
import 'services/cloud_sync_service.dart';
import 'services/progress_store.dart';
import 'services/python_lab_service.dart';
import 'services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progressStore = ProgressStore();
  await progressStore.initialize();
  final cloudSync = CloudSyncService(progressStore);
  await cloudSync.initialize();
  final themeController = ThemeController();
  await themeController.initialize();
  runApp(
    CourseApp(
      progressStore: progressStore,
      cloudSync: cloudSync,
      themeController: themeController,
    ),
  );
}

ThemeData _courseTheme(Brightness brightness) {
  const seed = Color(0xFF4F46E5);
  final dark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        dark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
    cardColor: dark ? const Color(0xFF171A22) : Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor:
          dark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? colorScheme.surfaceContainerHighest : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 74,
      backgroundColor: dark ? colorScheme.surfaceContainer : Colors.white,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

class CourseApp extends StatelessWidget {
  const CourseApp({
    super.key,
    required this.progressStore,
    required this.cloudSync,
    required this.themeController,
  });

  final ProgressStore progressStore;
  final CloudSyncService cloudSync;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Curso de Programação do Zero',
        theme: _courseTheme(Brightness.light),
        darkTheme: _courseTheme(Brightness.dark),
        themeMode: themeController.themeMode,
        home: CourseLoader(
          progressStore: progressStore,
          cloudSync: cloudSync,
          themeController: themeController,
        ),
      ),
    );
  }
}

class CourseLoader extends StatefulWidget {
  const CourseLoader({
    super.key,
    required this.progressStore,
    required this.cloudSync,
    required this.themeController,
  });

  final ProgressStore progressStore;
  final CloudSyncService cloudSync;
  final ThemeController themeController;

  @override
  State<CourseLoader> createState() => _CourseLoaderState();
}

class _CourseLoaderState extends State<CourseLoader> {
  late Future<List<CourseModule>> _modules =
      const CourseRepository().loadModules();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CourseModule>>(
      future: _modules,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 44),
                    const SizedBox(height: 14),
                    const Text(
                      'Não foi possível carregar o conteúdo do curso.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => setState(
                        () => _modules =
                            const CourseRepository().loadModules(),
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return CourseShell(
          modules: snapshot.data!,
          progressStore: widget.progressStore,
          cloudSync: widget.cloudSync,
          themeController: widget.themeController,
        );
      },
    );
  }
}

class CourseShell extends StatefulWidget {
  const CourseShell({
    super.key,
    required this.modules,
    required this.progressStore,
    required this.themeController,
    this.cloudSync,
  });

  final List<CourseModule> modules;
  final ProgressStore progressStore;
  final CloudSyncService? cloudSync;
  final ThemeController themeController;

  @override
  State<CourseShell> createState() => _CourseShellState();
}

class _CourseShellState extends State<CourseShell> {
  int _index = 0;
  final PythonLabService _pythonLab = PythonLabService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.progressStore,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final pages = [
            HomeScreen(
              modules: widget.modules,
              progressStore: widget.progressStore,
            ),
            ModulesScreen(
              modules: widget.modules,
              progressStore: widget.progressStore,
            ),
            PythonLabScreen(lab: _pythonLab),
            ProgressScreen(
              modules: widget.modules,
              progressStore: widget.progressStore,
            ),
            widget.cloudSync == null
                ? const Center(child: Text('Sincronização indisponível neste teste.'))
                : CloudAccountScreen(cloudSync: widget.cloudSync!),
          ];
          final desktop = constraints.maxWidth >= 850;
          final scheme = Theme.of(context).colorScheme;

          if (desktop) {
            return Scaffold(
              body: Row(
                children: [
                  Container(
                    width: 230,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      border: Border(
                        right: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                    child: NavigationRail(
                      extended: true,
                      selectedIndex: _index,
                      backgroundColor: Colors.transparent,
                      onDestinationSelected: (value) =>
                          setState(() => _index = value),
                      labelType: NavigationRailLabelType.none,
                      indicatorColor: scheme.primaryContainer,
                      leading: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 22, 12, 26),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '🐍',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Código Zero',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: Icon(
                            widget.themeController.isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                          ),
                          title: Text(
                            widget.themeController.isDark
                                ? 'Modo claro'
                                : 'Modo escuro',
                          ),
                          onTap: widget.themeController.toggle,
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_rounded),
                          label: Text('Início'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.view_agenda_rounded),
                          label: Text('Módulos'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.terminal_rounded),
                          label: Text('Laboratório'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.insights_rounded),
                          label: Text('Progresso'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.cloud_rounded),
                          label: Text('Conta'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: pages[_index],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            body: SafeArea(child: pages[_index]),
            floatingActionButton: FloatingActionButton.small(
              heroTag: 'theme_toggle',
              tooltip: widget.themeController.isDark
                  ? 'Usar modo claro'
                  : 'Usar modo escuro',
              onPressed: widget.themeController.toggle,
              child: Icon(
                widget.themeController.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) =>
                  setState(() => _index = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_agenda_outlined),
                  selectedIcon: Icon(Icons.view_agenda_rounded),
                  label: 'Módulos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.terminal_outlined),
                  selectedIcon: Icon(Icons.terminal_rounded),
                  label: 'Lab',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: 'Progresso',
                ),
                NavigationDestination(
                  icon: Icon(Icons.cloud_outlined),
                  selectedIcon: Icon(Icons.cloud_rounded),
                  label: 'Conta',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
