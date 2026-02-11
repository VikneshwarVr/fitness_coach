import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../data/constants/exercise_data.dart';

class AddExerciseScreen extends StatefulWidget {
  final bool isMultiSelect;
  final List<String> initialSelectedExercises;

  const AddExerciseScreen({
    super.key,
    this.isMultiSelect = false,
    this.initialSelectedExercises = const [],
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  String _selectedTag = 'All';
  late List<String> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _selectedExercises = List.from(widget.initialSelectedExercises);
  }

  // Get unique tags from data + 'All'
  List<String> get _tags {
    final tags = ExerciseData.exercises.map((e) => e['tag']!).toSet().toList();
    tags.sort();
    return ['All', ...tags];
  }

  // Filter exercises based on selection
  List<Map<String, String>> get _filteredExercises {
    if (_selectedTag == 'All') {
      return ExerciseData.exercises;
    }
    return ExerciseData.exercises.where((e) => e['tag'] == _selectedTag).toList();
  }

  void _onExerciseTapped(String name) {
    if (widget.isMultiSelect) {
      setState(() {
        if (_selectedExercises.contains(name)) {
          _selectedExercises.remove(name);
        } else {
          _selectedExercises.add(name);
        }
      });
    } else {
      context.pop(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isMultiSelect ? 'Select Exercises' : 'Add Exercise'),
        actions: [
          if (widget.isMultiSelect)
            TextButton(
              onPressed: () => context.pop(_selectedExercises),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                         _selectedTag = tag;
                      });
                    },
                    backgroundColor: AppTheme.card,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.foreground,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Exercise List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                final name = exercise['name']!;
                final isSelected = _selectedExercises.contains(name);
                
                return ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(exercise['tag']!, style: const TextStyle(color: AppTheme.mutedForeground)),
                  trailing: widget.isMultiSelect
                      ? Icon(
                          isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                          color: isSelected ? AppTheme.primary : AppTheme.mutedForeground,
                        )
                      : const Icon(LucideIcons.plusCircle, color: AppTheme.primary),
                  onTap: () => _onExerciseTapped(name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
