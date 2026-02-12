
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models/routine.dart';
import '../../data/repositories/routine_repository.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineRepository>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppTheme.primary),
            onPressed: () => context.push('/routines/create'),
            tooltip: 'New Routine',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<RoutineRepository>().loadRoutines(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Choose a workout routine to start training',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.mutedForeground)),
                const SizedBox(height: 24),
                Consumer<RoutineRepository>(
                  builder: (context, repo, child) {
                    final defaults = repo.defaultRoutines;
                    final customs = repo.customRoutines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (defaults.isNotEmpty) ...[
                          const Text('Default Routines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...defaults.map((routine) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RoutineCard(routine: routine),
                              )),
                          const SizedBox(height: 16),
                        ],
                        if (customs.isNotEmpty) ...[
                          const Text('My Routines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...customs.map((routine) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RoutineCard(routine: routine),
                              )),
                        ],
                        if (defaults.isEmpty && customs.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No routines yet',
                                style: TextStyle(color: AppTheme.mutedForeground),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      '${routine.exerciseNames.length} exercises • ${routine.duration} min',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.mutedForeground),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      routine.level,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.mutedForeground),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, size: 18, color: AppTheme.mutedForeground),
                    onPressed: () {
                      context.push('/routines/create', extra: routine);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (routine.isCustom) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Routine?'),
                            content: Text('Are you sure you want to delete "${routine.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<RoutineRepository>().deleteRoutine(routine.id);
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            routine.description,
            style: const TextStyle(fontSize: 12, color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Start Routine',
            icon: LucideIcons.play,
            onPressed: () {
               context.push('/workout', extra: routine);
            },
          ),
        ],
      ),
    );
  }
}
