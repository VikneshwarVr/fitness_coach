import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import '../components/fitness_card.dart';
import '../../core/utils/responsive_utils.dart';

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
        padding: EdgeInsets.all(Responsive.p(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout',
              style: TextStyle(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
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
                    leading: Icon(LucideIcons.timer, size: Responsive.sp(context, 20)),
                    title: Text(
                      'Default Rest Timer', 
                      style: TextStyle(fontSize: Responsive.sp(context, 14))
                    ),
                    subtitle: Text(
                      settingsProvider.formatRestTimer,
                      style: TextStyle(fontSize: Responsive.sp(context, 12))
                    ),
                    onTap: () => _showTimerPicker(context, settingsProvider),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: settingsProvider.isRestTimerEnabled,
                          onChanged: (val) {
                            if (val) {
                              settingsProvider.setDefaultRestTimer(90); // Default to 90 if turned on
                            } else {
                              settingsProvider.setDefaultRestTimer(0);
                            }
                          },
                        ),
                        Icon(LucideIcons.chevronRight, size: Responsive.sp(context, 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 32)),
            Text(
              'About',
              style: TextStyle(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
            FitnessCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(LucideIcons.info, size: Responsive.sp(context, 20)),
                title: Text('Version', style: TextStyle(fontSize: Responsive.sp(context, 14))),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(context, 14),
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
    int selectedValue = provider.defaultRestTimer > 0 ? provider.defaultRestTimer : 90;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.all(Responsive.p(context, 24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Set Default Rest Timer',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 18), 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setModalState(() => selectedValue = (selectedValue - 15).clamp(0, 300)),
                        icon: Icon(LucideIcons.minusCircle, size: Responsive.sp(context, 24)),
                      ),
                      SizedBox(width: Responsive.w(context, 20)),
                      Column(
                        children: [
                          Text(
                            selectedValue > 0 ? '$selectedValue' : 'Off',
                            style: TextStyle(
                              fontSize: Responsive.sp(context, 32), 
                              fontWeight: FontWeight.bold,
                              color: selectedValue > 0 ? null : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          if (selectedValue > 0)
                            Text(
                              'seconds', 
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 12),
                                color: Theme.of(context).colorScheme.onSurfaceVariant
                              )
                            ),
                        ],
                      ),
                      SizedBox(width: Responsive.w(context, 20)),
                      IconButton(
                        onPressed: () => setModalState(() => selectedValue = (selectedValue + 15).clamp(0, 300)),
                        icon: Icon(LucideIcons.plusCircle, size: Responsive.sp(context, 24)),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 24)),
                  ElevatedButton(
                    onPressed: () {
                      provider.setDefaultRestTimer(selectedValue);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: Size(double.infinity, Responsive.h(context, 50)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Save', 
                      style: TextStyle(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.bold)
                    ),
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
