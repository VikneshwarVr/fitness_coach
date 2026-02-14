import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';

class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SizedBox(
          height: 40,
          child: AnimatedToggleSwitch<WorkoutMode>.dual(
            current: settings.workoutMode,
            first: WorkoutMode.home,
            second: WorkoutMode.gym,
            spacing: 30.0,
            style: ToggleStyle(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF27272A) 
                  : const Color(0xFFE4E4E7),
              borderColor: Colors.transparent,
              boxShadow: const [],
            ),
            borderWidth: 4.0,
            height: 40,
            onChanged: (mode) => settings.setWorkoutMode(mode),
            styleBuilder: (mode) => ToggleStyle(
              indicatorColor: mode == WorkoutMode.home 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.primary,
            ),
            iconBuilder: (value) => Icon(
              value == WorkoutMode.home ? LucideIcons.home : LucideIcons.dumbbell,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            textBuilder: (value) => Center(
              child: Text(
                value == WorkoutMode.home ? 'Home' : 'Gym',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
