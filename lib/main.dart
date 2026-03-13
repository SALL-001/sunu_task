import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'providers/comment_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/projects/project_form_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/tasks/task_form_screen.dart';
import 'screens/tasks/task_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les providers
  final appProvider = AppProvider();
  final authProvider = AuthProvider();
  final projectProvider = ProjectProvider();
  final taskProvider = TaskProvider();
  final commentProvider = CommentProvider();

  // Init de l'application
  await appProvider.init();
  await authProvider.init();

  runApp(
    SunuTaskApp(
      appProvider: appProvider,
      authProvider: authProvider,
      projectProvider: projectProvider,
      taskProvider: taskProvider,
      commentProvider: commentProvider,
    ),
  );
}

class SunuTaskApp extends StatelessWidget {
  final AppProvider appProvider;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final CommentProvider commentProvider;

  const SunuTaskApp({
    super.key,
    required this.appProvider,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
    required this.commentProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appProvider,
      builder: (_, __) {
        return MaterialApp(
          title: 'SunuTask',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Localisation pour le français
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
            Locale('en', 'US'),
          ],
          locale: const Locale('fr', 'FR'),

          // Route initiale
          initialRoute: '/splash',

          // Routes nommées
          onGenerateRoute: (settings) {
            switch (settings.name) {
              // ── Splash ──────────────────────────────────────────
              case '/splash':
                return _fade(
                  SplashScreen(
                    appProvider: appProvider,
                    authProvider: authProvider,
                  ),
                );

              // ── Onboarding ──────────────────────────────────────
              case '/onboarding':
                return _fade(
                  OnboardingScreen(appProvider: appProvider),
                );

              // ── Auth ────────────────────────────────────────────
              case '/login':
                return _slide(
                  LoginScreen(authProvider: authProvider),
                );
              case '/register':
                return _slide(
                  RegisterScreen(authProvider: authProvider),
                );

              // ── Home ────────────────────────────────────────────
              case '/home':
                return _fade(
                  HomeScreen(
                    authProvider: authProvider,
                    projectProvider: projectProvider,
                    taskProvider: taskProvider,
                  ),
                );

              // ── Projets ─────────────────────────────────────────
              case '/project/new':
                return _slide(
                  ProjectFormScreen(
                    authProvider: authProvider,
                    projectProvider: projectProvider,
                  ),
                );
              case '/project/edit': {
                final projectId = settings.arguments as String;
                final project = projectProvider.allProjects.firstWhere(
                  (p) => p.id == projectId,
                );
                return _slide(
                  ProjectFormScreen(
                    project: project,
                    authProvider: authProvider,
                    projectProvider: projectProvider,
                  ),
                );
              }
              case '/project/detail': {
                final projectId = settings.arguments as String;
                return _slide(
                  ProjectDetailScreen(
                    projectId: projectId,
                    authProvider: authProvider,
                    projectProvider: projectProvider,
                    taskProvider: taskProvider,
                  ),
                );
              }

              // ── Tâches ──────────────────────────────────────────
              case '/task/new': {
                final projectId = settings.arguments as String;
                return _slide(
                  TaskFormScreen(
                    projectId: projectId,
                    taskProvider: taskProvider,
                  ),
                );
              }
              case '/task/edit': {
                final taskId = settings.arguments as String;
                final task = taskProvider.allTasks.firstWhere(
                  (t) => t.id == taskId,
                );
                return _slide(
                  TaskFormScreen(
                    task: task,
                    taskProvider: taskProvider,
                  ),
                );
              }
              case '/task/detail': {
                final taskId = settings.arguments as String;
                return _slide(
                  TaskDetailScreen(
                    taskId: taskId,
                    authProvider: authProvider,
                    taskProvider: taskProvider,
                    commentProvider: commentProvider,
                  ),
                );
              }

              default:
                return _fade(
                  const Scaffold(
                    body: Center(child: Text('Page introuvable')),
                  ),
                );
            }
          },
        );
      },
    );
  }


  PageRoute _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }


  PageRoute _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
