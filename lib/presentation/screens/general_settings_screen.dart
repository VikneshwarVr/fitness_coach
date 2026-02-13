import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import '../components/fitness_card.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            FitnessCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.scale),
                    title: const Text('Weight Unit'),
                    trailing: SegmentedButton<WeightUnit>(
                      segments: const [
                        ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                        ButtonSegment(value: WeightUnit.lbs, label: Text('lb')),
                      ],
                      selected: {settingsProvider.weightUnit},
                      onSelectionChanged: (Set<WeightUnit> newSelection) {
                        settingsProvider.setWeightUnit(newSelection.first);
                      },
                    ),
                  ),
                  Divider(
                    height: 1, 
                    thickness: 0.5, 
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.timer),
                    title: const Text('Default Rest Timer'),
                    subtitle: Text('${settingsProvider.defaultRestTimer} seconds'),
                    onTap: () => _showTimerPicker(context, settingsProvider),
                    trailing: const Icon(LucideIcons.chevronRight, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const FitnessCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(LucideIcons.info),
                title: Text('Version'),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerPicker(BuildContext context, SettingsProvider provider) {
    int selectedValue = provider.defaultRestTimer;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Set Default Rest Timer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setModalState(() => selectedValue = (selectedValue - 15).clamp(15, 300)),
                        icon: const Icon(LucideIcons.minusCircle),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '$selectedValue',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () => setModalState(() => selectedValue = (selectedValue + 15).clamp(15, 300)),
                        icon: const Icon(LucideIcons.plusCircle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.setDefaultRestTimer(selectedValue);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
