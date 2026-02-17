import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';
import '../../data/providers/theme_provider.dart';
import '../../core/utils/responsive_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark || 
                  (themeProvider.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.p(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: Responsive.p(context, 40),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  backgroundImage: context.watch<AuthRepository>().profileImageUrl != null
                      ? NetworkImage(context.watch<AuthRepository>().profileImageUrl!)
                      : null,
                  child: context.watch<AuthRepository>().profileImageUrl == null
                      ? Icon(LucideIcons.user, size: Responsive.p(context, 40), color: Theme.of(context).colorScheme.onSurfaceVariant)
                      : null,
                ),
              ),
              SizedBox(height: Responsive.h(context, 16)),
              Center(
                child: Text(
                  context.watch<AuthRepository>().displayName,
                  style: TextStyle(fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: Responsive.h(context, 4)),
              Center(
                child: Text(
                  'Level 1 Athlete', 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: Responsive.sp(context, 14))
                ),
              ),
              SizedBox(height: Responsive.h(context, 24)),

              Text(
                'General', 
                style: TextStyle(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.bold)
              ),
              SizedBox(height: Responsive.h(context, 12)),
              
              _SettingsItem(
                icon: LucideIcons.userCircle,
                label: 'User Profile',
                onTap: () => context.push('/profile/user'),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              _SettingsItem(
                icon: LucideIcons.barChart2,
                label: 'Statistics',
                onTap: () => context.push('/profile/statistics'),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              _SettingsItem(
                icon: LucideIcons.calendar,
                label: 'Calendar',
                onTap: () => context.push('/profile/calendar'),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              _SettingsItem(
                icon: LucideIcons.history,
                label: 'Workout Log',
                onTap: () => context.push('/history'),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              _SettingsItem(
                icon: LucideIcons.settings,
                label: 'General',
                onTap: () => context.push('/profile/settings'),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              /* _SettingsItem(
                icon: LucideIcons.bell,
                label: 'Notifications',
                onTap: () {}, // Empty for now to enable
              ),
              const SizedBox(height: 8), */
              _SettingsItem(
                icon: isDark ? LucideIcons.moon : LucideIcons.sun,
                label: 'Dark Mode',
                onTap: () => themeProvider.toggleTheme(),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeThumbColor: Theme.of(context).colorScheme.primary,
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
              SizedBox(height: Responsive.h(context, 24)),
              Center(
                child: Text(
                  'Version 1.0.0', 
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: Responsive.sp(context, 12))
                ),
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
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.p(context, 16), 
          vertical: Responsive.p(context, 4)
        ), 
        onTap: onTap,
         child: SizedBox(
          height: Responsive.h(context, 48),
          child: Row(
            children: [
              Icon(icon, size: Responsive.sp(context, 20), color: Theme.of(context).colorScheme.onSurface),
              SizedBox(width: Responsive.w(context, 12)),
              Expanded(
                child: Text(
                  label, 
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: Responsive.sp(context, 14))
                )
              ),
              if (trailing != null) trailing! 
              else Icon(LucideIcons.chevronRight, size: Responsive.sp(context, 20), color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
