import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/theme.dart';
import '../../data/providers/workout_provider.dart';
import '../components/buttons.dart';
import '../components/fitness_card.dart';

class FinishWorkoutScreen extends StatefulWidget {
  final String? workoutId;
  const FinishWorkoutScreen({super.key, this.workoutId});

  @override
  State<FinishWorkoutScreen> createState() => _FinishWorkoutScreenState();
}

class _FinishWorkoutScreenState extends State<FinishWorkoutScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.workoutId != null;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WorkoutProvider>();
    _titleController.text = provider.workoutName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () {
                // Resume workout if going back
                // Or simply pop, as provider state is preserved
                context.pop();
              },
            ),
            title: Text(isEditing ? 'Edit Workout' : 'Workout Summary', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Stats
                Text(isEditing ? 'Update your workout' : 'Great job!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(isEditing ? 'Make changes to your saved session.' : 'Here is a summary of your session.', style: const TextStyle(color: AppTheme.mutedForeground)),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: _SummaryStat(
                      label: 'Duration',
                      value: provider.formattedTime,
                      icon: LucideIcons.clock,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryStat(
                      label: 'Volume',
                      value: provider.totalVolume >= 1000 
                        ? '${(provider.totalVolume / 1000).toStringAsFixed(1)}k'
                        : '${provider.totalVolume}',
                      subValue: 'kg',
                      icon: LucideIcons.trendingUp,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _SummaryStat(
                      label: 'Sets',
                      value: '${provider.totalSets}',
                      icon: LucideIcons.layers,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryStat(
                      label: 'PRs',
                      value: '${provider.totalPRsAchieved}',
                      icon: LucideIcons.trophy,
                    )),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Details Form
                const Text('Workout Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Workout Title',
                    hintText: 'e.g., Chest Day',
                    prefixIcon: Icon(LucideIcons.dumbbell),
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.all(Radius.circular(12)),
                       borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'How did it feel?',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(LucideIcons.fileText), // Aligned top? No, simplified
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.all(Radius.circular(12)),
                       borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => _showPhotoSourceSheet(provider),
                  child: Row(
                    children: [
                      DottedBorder(
                        color: AppTheme.mutedForeground.withOpacity(0.4),
                        strokeWidth: 1.5,
                        dashPattern: const [6, 4],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(16),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: provider.workoutPhotoPath != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: provider.workoutPhotoPath!.startsWith('http')
                                          ? Image.network(provider.workoutPhotoPath!, fit: BoxFit.cover, width: 100, height: 100)
                                          : Image.file(File(provider.workoutPhotoPath!), fit: BoxFit.cover, width: 100, height: 100),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => provider.setWorkoutPhoto(null),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(LucideIcons.x, color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Icon(LucideIcons.imagePlus, color: AppTheme.mutedForeground, size: 32),
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Add a photo / video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                
                // Actions
                _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : PrimaryButton(
                  label: isEditing ? 'Update Workout' : 'Save Workout',
                  icon: isEditing ? LucideIcons.check : LucideIcons.save,
                  onPressed: () async {
                    if (provider.totalVolume <= 0) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Nothing to Save?'),
                          content: const Text('This workout doesn\'t have any recorded volume. Add some sets with weight and reps to save your session!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Oops, let me add some'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                      if (isEditing) {
                        await provider.saveUpdate(id: widget.workoutId!, name: _titleController.text);
                      } else {
                        await provider.addWorkout(name: _titleController.text);
                      }
                      if (context.mounted) context.go('/');
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save workout: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Discard Workout?'),
                        content: const Text('Are you sure you want to discard this workout? All progress will be lost.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.cancelWorkout();
                              Navigator.pop(context);
                              context.go('/');
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Discard'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Discard Workout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotoSourceSheet(WorkoutProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Select Photo Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppTheme.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.camera, provider);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: AppTheme.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.gallery, provider);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCropImage(ImageSource source, WorkoutProvider provider) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo (1:1)',
            toolbarColor: AppTheme.background,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            activeControlsWidgetColor: AppTheme.primary,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Photo (1:1)',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );

      if (croppedFile != null) {
        provider.setWorkoutPhoto(croppedFile.path);
      }
    }
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;

  const _SummaryStat({
    required this.label,
    required this.value,
    this.subValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (subValue != null) ...[
                const SizedBox(width: 2),
                Text(subValue!, style: const TextStyle(fontSize: 10, color: AppTheme.mutedForeground)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
