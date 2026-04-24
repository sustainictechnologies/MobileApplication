import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

class JalBottomNav extends StatelessWidget {
  const JalBottomNav({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home, route: AppRoutes.home),
    _TabItem(label: 'Map', icon: Icons.map_outlined, activeIcon: Icons.map, route: AppRoutes.map),
    _TabItem(label: 'History', icon: Icons.history_outlined, activeIcon: Icons.history, route: AppRoutes.history),
    _TabItem(label: 'Profile', icon: Icons.person_outline, activeIcon: Icons.person, route: AppRoutes.profile),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => context.go(_tabs[index].route),
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                activeIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
