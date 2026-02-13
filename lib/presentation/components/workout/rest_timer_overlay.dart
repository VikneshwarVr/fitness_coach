import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../data/providers/workout_provider.dart';

class RestTimerOverlay extends StatelessWidget {
  const RestTimerOverlay({super.key});

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        if (!provider.isRestTimerRunning) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rest Time',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.minus, color: AppTheme.primary),
                    onPressed: () => provider.adjustRestTimer(-15),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _formatTime(provider.currentRestSeconds),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: AppTheme.primary),
                    onPressed: () => provider.adjustRestTimer(15),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: provider.stopRestTimer,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.mutedForeground,
                  ),
                  child: const Text('Skip Rest'),
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: provider.restTimerProgress,
                  backgroundColor: AppTheme.muted,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
