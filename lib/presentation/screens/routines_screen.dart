
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
            icon: Icon(LucideIcons.plus, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.push('/routines/create'),
            tooltip: 'New Routine',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<RoutineRepository>().loadRoutines(),
        child: Consumer<RoutineRepository>(
          builder: (context, repo, child) {
            final defaults = repo.defaultRoutines;
            final customs = repo.customRoutines;

            if (defaults.isEmpty && customs.isEmpty) {
              return Stack(
                children: [
                  ListView(), // For RefreshIndicator
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No routines yet',
                        style: TextStyle(color: Color(0xFF737373)),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Flatten items: Intro, Headers, Routines
            final List<dynamic> items = [];
            items.add('intro');
            if (defaults.isNotEmpty) {
              items.add('header_defaults');
              items.addAll(defaults);
            }
            if (customs.isNotEmpty) {
              items.add('header_customs');
              items.addAll(customs);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item == 'intro') {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Choose a workout routine to start training',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  );
                } else if (item == 'header_defaults') {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Default Routines',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  );
                } else if (item == 'header_customs') {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'My Routines',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  );
                } else if (item is Routine) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RoutineCard(routine: item),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
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
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      routine.level,
                      style: TextStyle(
                          fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(LucideIcons.pencil, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
