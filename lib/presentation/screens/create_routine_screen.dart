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
  final Routine? initialRoutine;

  const CreateRoutineScreen({super.key, this.initialRoutine});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '45');
  
  String _selectedLevel = 'Intermediate';
  List<RoutineExercise> _selectedExercises = []; // Changed type
  bool _isLoading = false;
  bool get _isEditing => widget.initialRoutine != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRoutine;
    if (initial != null) {
      _nameController.text = initial.name;
      _descriptionController.text = initial.description;
      _durationController.text = initial.duration.toString();
      _selectedLevel = initial.level;
      // Copy existing exercises including sets/reps
      _selectedExercises = List<RoutineExercise>.from(initial.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectExercises() async {
    // Create a temporary routine with current exercises to pass to editor
    final tempRoutine = Routine(
      id: 'temp', 
      name: _nameController.text, 
      description: '', 
      exercises: _selectedExercises, 
      level: _selectedLevel, 
      duration: 0
    );

    final result = await context.push<List<RoutineExercise>>(
      '/workout/edit',
      extra: tempRoutine,
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

      setState(() {
        _isLoading = true;
      });

      try {
        final repo = context.read<RoutineRepository>();

        if (_isEditing && widget.initialRoutine!.isCustom) {
          // Update existing custom routine
          final updated = Routine(
            id: widget.initialRoutine!.id,
            name: _nameController.text,
            description: _descriptionController.text,
            exercises: _selectedExercises,
            level: _selectedLevel,
            duration: int.tryParse(_durationController.text) ?? 45,
            isCustom: true,
          );
          await repo.updateRoutine(updated);
        } else if (_isEditing && !widget.initialRoutine!.isCustom) {
          // Editing a default routine -> ask to save as custom
          String customName = _nameController.text;
          await showDialog(
            context: context,
            builder: (context) {
              final controller = TextEditingController(text: customName);
              return AlertDialog(
                title: const Text('Save as Custom Routine'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Custom routine name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      customName = controller.text.isNotEmpty ? controller.text : customName;
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );

          if (!mounted) return;

          final routine = Routine.create(
            name: customName,
            description: _descriptionController.text,
            exerciseNames: _selectedExercises.map((e) => e.name).toList(),
            detailedExercises: _selectedExercises,
            level: _selectedLevel,
            duration: int.tryParse(_durationController.text) ?? 45,
            isCustom: true,
          );
          await repo.addRoutine(routine);
        } else {
          // Creating brand new custom routine
          final routine = Routine.create(
            name: _nameController.text,
            description: _descriptionController.text,
            exerciseNames: _selectedExercises.map((e) => e.name).toList(),
            detailedExercises: _selectedExercises,
            level: _selectedLevel,
            duration: int.tryParse(_durationController.text) ?? 45,
            isCustom: true,
          );
          await repo.addRoutine(routine);
        }
        
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          String message = 'Error saving routine: $e';
          if (e.toString().contains('unique_routine_name_per_user') || 
              e.toString().contains('duplicate key') ||
              e.toString().contains('23505')) {
            message = 'A routine with this name already exists.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Routine' : 'Create Routine'),
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ),
              )
            : TextButton(
                onPressed: _saveRoutine,
                child: Text('Save', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: Form(
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
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Level', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLevel,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: const OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                const SizedBox(width: 8),
                Expanded(
                  child: FitnessCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Duration (min)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: const OutlineInputBorder(borderSide: BorderSide.none),
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No exercises selected',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.activity, size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(exercise.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Text(
                                        '${exercise.sets.length} sets',
                                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}
