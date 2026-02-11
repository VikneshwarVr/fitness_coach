
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.muted,
                  child: Icon(LucideIcons.user, size: 40, color: AppTheme.mutedForeground),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  context.watch<AuthRepository>().displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text('Level 1 Athlete', style: TextStyle(color: AppTheme.primary, fontSize: 14)),
              ),
              const SizedBox(height: 24),
              
              const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Consumer<WorkoutRepository>(
                builder: (context, repo, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'Workouts',
                          value: '${repo.workouts.length}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          label: 'Total Volume',
                          value: '${(repo.totalVolume / 1000).toStringAsFixed(1)}k',
                          unit: 'kg',
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),
              const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              _SettingsItem(
                icon: LucideIcons.settings,
                label: 'General',
                onTap: () {},
              ),
               const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.bell,
                label: 'Notifications',
                onTap: () {},
              ),
               const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.moon,
                label: 'Dark Mode',
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeThumbColor: AppTheme.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              SecondaryButton(
                label: 'Sign Out',
                icon: LucideIcons.logOut,
                onPressed: () async {
                  await context.read<AuthRepository>().signOut();
                },
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text('Version 1.0.0', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const _StatBox({required this.label, required this.value, this.unit});

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
           Text(label, style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
           const SizedBox(height: 4),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.baseline,
             textBaseline: TextBaseline.alphabetic,
             children: [
               Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
               if (unit != null) ...[
                 const SizedBox(width: 4),
                 Text(unit!, style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
               ],
             ],
           ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Slimmer
      onTap: onTap,
       child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.foreground),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
            if (trailing != null) trailing! else const Icon(LucideIcons.chevronRight, size: 20, color: AppTheme.mutedForeground),
          ],
        ),
      ),
    );
  }
}
