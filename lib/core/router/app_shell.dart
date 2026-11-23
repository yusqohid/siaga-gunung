import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class _NavDestination {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavDestination(this.path, this.label, this.icon, this.selectedIcon);
}

const List<_NavDestination> _destinations = [
  _NavDestination('/','Beranda', Icons.home_outlined, Icons.home_rounded),
  _NavDestination('/map','Peta', Icons.map_outlined, Icons.map_rounded),
  _NavDestination('/volcanoes','Gunung', Icons.volcano_outlined, Icons.volcano_rounded),
  _NavDestination('/education','Edukasi', Icons.menu_book_outlined, Icons.menu_book_rounded),
  _NavDestination('/checklist','Checklist', Icons.checklist_outlined, Icons.checklist_rounded),
];

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/volcanoes')) return 2;
    if (location.startsWith('/education')) return 3;
    if (location.startsWith('/checklist')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: p.dk,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_destinations.length, (index) {
                final destination = _destinations[index];
                final isSelected = index == selectedIndex;
                return _NavItem(
                  destination: destination,
                  selected: isSelected,
                  onTap: () => context.go(destination.path),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const inactive = Color(0xFFB9B9B2);

    return Tooltip(
      message: destination.label,
      child: Material(
        color: selected ? p.amb : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 50,
            constraints: const BoxConstraints(minWidth: 50),
            padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 22,
                  color: selected ? AppColors.inkOnAmber : inactive,
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Text(
                    destination.label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: AppColors.inkOnAmber,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
