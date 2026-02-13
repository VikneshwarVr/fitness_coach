import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../components/active_workout_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          const ActiveWorkoutBar(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
          color: AppTheme.card,
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _buildDestination(LucideIcons.home, 'Home', 0),
            _buildDestination(LucideIcons.folderOpen, 'Routines', 1),
            _buildDestination(LucideIcons.user, 'Profile', 2),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(IconData icon, String label, int index) {
    final isSelected = navigationShell.currentIndex == index;
    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected ? AppTheme.primary : AppTheme.mutedForeground,
        size: 20,
      ),
      label: label,
      selectedIcon: Icon(
        icon,
        color: AppTheme.primary,
        size: 20,
      ),
    );
  }
}
