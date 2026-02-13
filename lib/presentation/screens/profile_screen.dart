import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.muted,
                  backgroundImage: context.watch<AuthRepository>().profileImageUrl != null
                      ? NetworkImage(context.watch<AuthRepository>().profileImageUrl!)
                      : null,
                  child: context.watch<AuthRepository>().profileImageUrl == null
                      ? const Icon(LucideIcons.user, size: 40, color: AppTheme.mutedForeground)
                      : null,
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

              const Text('General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              _SettingsItem(
                icon: LucideIcons.userCircle,
                label: 'User Profile',
                onTap: () => context.push('/profile/user'),
              ),
              const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.barChart2,
                label: 'Statistics',
                onTap: () => context.push('/profile/statistics'),
              ),
              const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.calendar,
                label: 'Calendar',
                onTap: () => context.push('/profile/calendar'),
              ),
              const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.history,
                label: 'Workout Log',
                onTap: () => context.push('/history'),
              ),
               const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.settings,
                label: 'General',
                onTap: null,
              ),
               const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.bell,
                label: 'Notifications',
                onTap: null,
              ),
               const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.moon,
                label: 'Dark Mode',
                onTap: null,
                trailing: Switch(
                  value: true,
                  onChanged: null,
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
    return Opacity(
      opacity: onTap == null ? 0.5 : 1.0,
      child: FitnessCard(
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
      ),
    );
  }
}
