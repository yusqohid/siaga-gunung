import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/map/screens/volcano_map_screen.dart';
import '../../features/volcano/screens/volcano_list_screen.dart';
import '../../features/volcano/screens/volcano_detail_screen.dart';
import '../../features/education/screens/education_screen.dart';
import '../../features/checklist/screens/checklist_screen.dart';
import '../../features/about/screens/about_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: VolcanoMapScreen(),
          ),
        ),
        GoRoute(
          path: '/volcanoes',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: VolcanoListScreen(),
          ),
        ),
        GoRoute(
          path: '/education',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EducationScreen(),
          ),
        ),
        GoRoute(
          path: '/checklist',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ChecklistScreen(),
          ),
        ),
      ],
    ),
    // Sub-screens outside bottom navigation shell
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/volcanoes/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return VolcanoDetailScreen(volcanoId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
