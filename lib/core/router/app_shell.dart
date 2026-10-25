import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/map')) {
      return 1;
    }
    if (location.startsWith('/volcanoes')) {
      return 2;
    }
    if (location.startsWith('/education')) {
      return 3;
    }
    if (location.startsWith('/checklist')) {
      return 4;
    }
    return 0; // Beranda
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/volcanoes');
        break;
      case 3:
        context.go('/education');
        break;
      case 4:
        context.go('/checklist');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.volcano_outlined),
            selectedIcon: Icon(Icons.volcano_rounded),
            label: 'Gunung',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Edukasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Checklist',
          ),
        ],
      ),
    );
  }
}
