import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/nav_icon.dart';

class _NavDestination {
  final String path;
  final String label;
  final NavGlyph glyph;

  const _NavDestination(this.path, this.label, this.glyph);
}

const List<_NavDestination> _destinations = [
  _NavDestination('/', 'Beranda', NavGlyph.home),
  _NavDestination('/map', 'Peta', NavGlyph.map),
  _NavDestination('/volcanoes', 'Gunung', NavGlyph.volcano),
  _NavDestination('/education', 'Edukasi', NavGlyph.book),
  _NavDestination('/checklist', 'Checklist', NavGlyph.checklist),
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
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final background = Color.lerp(Colors.transparent, p.amb, t)!;
          final foreground = Color.lerp(inactive, AppColors.inkOnAmber, t)!;

          return Material(
            color: background,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 50,
                constraints: const BoxConstraints(minWidth: 50),
                padding: EdgeInsets.symmetric(horizontal: 14 * t),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.92 + 0.08 * t,
                      child: NavGlyphIcon(
                        glyph: destination.glyph,
                        size: 22,
                        color: foreground,
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.centerLeft,
                      child: selected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                destination.label.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: AppColors.inkOnAmber,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
