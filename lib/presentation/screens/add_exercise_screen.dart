import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedExercises = List.from(widget.initialSelectedExercises);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get unique tags from data + 'All'
  List<String> get _tags {
    final tags = ExerciseData.exercises.map((e) => e['tag']!).toSet().toList();
    tags.sort();
    return ['All', ...tags];
  }

  // Filter exercises based on selection and search
  List<Map<String, String>> get _filteredExercises {
    return ExerciseData.exercises.where((e) {
      final matchesTag = _selectedTag == 'All' || e['tag'] == _selectedTag;
      final matchesSearch = e['name']!.toLowerCase().contains(_searchQuery);
      return matchesTag && matchesSearch;
    }).toList();
  }

  void _onExerciseTapped(String name) {
    if (widget.initialSelectedExercises.contains(name)) return;

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
              onPressed: () {
                final newSelections = _selectedExercises
                    .where((e) => !widget.initialSelectedExercises.contains(e))
                    .toList();
                context.pop(newSelections);
              },
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(height: 1),

          // Exercise List
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center( // Removed const
                    child: Text(
                      'No exercises found',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant), // Use theme color
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      final name = exercise['name']!;
                      final isSelected = _selectedExercises.contains(name);
                      final isAlreadyAdded = widget.initialSelectedExercises.contains(name);
                      
                      return ListTile(
                        enabled: !isAlreadyAdded,
                        title: Text(
                          name, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isAlreadyAdded ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface,
                          )
                        ),
                        subtitle: Text(exercise['tag']!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        trailing: widget.isMultiSelect
                            ? Opacity(
                                opacity: isAlreadyAdded ? 0.5 : 1.0,
                                child: Icon(
                                  isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              )
                            : isAlreadyAdded 
                                ? Text('Added', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))
                                : Icon(LucideIcons.plusCircle, color: Theme.of(context).colorScheme.primary),
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
