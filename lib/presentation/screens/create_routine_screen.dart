import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/routine.dart';
import '../../data/repositories/routine_repository.dart';
import '../components/fitness_card.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '45');
  
  String _selectedLevel = 'Intermediate';
  List<String> _selectedExercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectExercises() async {
    final result = await context.push<List<String>>(
      '/workout/add',
      extra: {
        'isMultiSelect': true,
        'initialSelectedExercises': _selectedExercises,
      },
    );

    if (result != null) {
      setState(() {
        _selectedExercises = result;
      });
    }
  }

  Future<void> _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one exercise')),
        );
        return;
      }

      final routine = Routine.create(
        name: _nameController.text,
        description: _descriptionController.text,
        exerciseNames: _selectedExercises,
        level: _selectedLevel,
        duration: int.tryParse(_durationController.text) ?? 45,
        isCustom: true,
      );

      await context.read<RoutineRepository>().addRoutine(routine);
      
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Routine'),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            child: const Text('Save', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            FitnessCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Routine Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., My Upper Body Workout',
                      filled: true,
                      fillColor: AppTheme.input,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a routine name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            FitnessCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Describe your routine...',
                      filled: true,
                      fillColor: AppTheme.input,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Level and Duration
            Row(
              children: [
                Expanded(
                  child: FitnessCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Level', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLevel,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: AppTheme.input,
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: ['Beginner', 'Intermediate', 'Advanced']
                              .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FitnessCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Duration (min)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: AppTheme.input,
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise Selection
            FitnessCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _selectExercises,
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: Text(_selectedExercises.isEmpty ? 'Select' : 'Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedExercises.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No exercises selected',
                          style: TextStyle(color: AppTheme.mutedForeground),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _selectedExercises.map((exercise) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.input,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.activity, size: 16, color: AppTheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(exercise, style: const TextStyle(fontSize: 14)),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedExercises.remove(exercise);
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
