import 'package:flutter/material.dart';

import 'data/course_repository.dart';
import 'models/course_models.dart';
import 'screens/home_screen.dart';
import 'screens/modules_screen.dart';
import 'screens/progress_screen.dart';
import 'services/progress_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progressStore = ProgressStore();
  await progressStore.initialize();
  runApp(CourseApp(progressStore: progressStore));
}

class CourseApp extends StatelessWidget {
  const CourseApp({super.key, required this.progressStore});

  final ProgressStore progressStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Curso de Programação do Zero',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4255FF)),
        inputDecorationTheme: const InputDecorationTheme(filled: true),
      ),
      home: CourseLoader(progressStore: progressStore),
    );
  }
}

class CourseLoader extends StatelessWidget {
  const CourseLoader({super.key, required this.progressStore});

  final ProgressStore progressStore;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CourseModule>>(
      future: const CourseRepository().loadModules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erro ao carregar o curso: ${snapshot.error}')),
          );
        }
        return CourseShell(
          modules: snapshot.data ?? const [],
          progressStore: progressStore,
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
  });

  final List<CourseModule> modules;
  final ProgressStore progressStore;

  @override
  State<CourseShell> createState() => _CourseShellState();
}

class _CourseShellState extends State<CourseShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(modules: widget.modules, progressStore: widget.progressStore),
      ModulesScreen(modules: widget.modules, progressStore: widget.progressStore),
      ProgressScreen(modules: widget.modules, progressStore: widget.progressStore),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 850;
        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) => setState(() => _index = value),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircleAvatar(child: Text('🐍')),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Início'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: Text('Módulos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Progresso'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
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
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
              NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Módulos'),
              NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progresso'),
            ],
          ),
        );
      },
    );
  }
}
