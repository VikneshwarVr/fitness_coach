import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/repositories/auth_repository.dart';
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
                      style: TextStyle(fontSize: Responsive.sp(context, 14)),
                    ),
                    subtitle: Text(
                      settingsProvider.formatRestTimer,
                      style: TextStyle(fontSize: Responsive.sp(context, 12)),
                    ),
                    onTap: () => _showTimerPicker(context, settingsProvider),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: settingsProvider.isRestTimerEnabled,
                          onChanged: (val) {
                            if (val) {
                              settingsProvider.setDefaultRestTimer(90);
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
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(LucideIcons.shield, size: Responsive.sp(context, 20)),
                    title: Text('Privacy Policy', style: TextStyle(fontSize: Responsive.sp(context, 14))),
                    trailing: Icon(LucideIcons.chevronRight, size: Responsive.sp(context, 20)),
                    onTap: () => context.push('/profile/privacy'),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                  ),
                  ListTile(
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
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 32)),
            Text(
              'Account',
              style: TextStyle(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
            FitnessCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(LucideIcons.trash2, size: Responsive.sp(context, 20), color: Colors.red),
                title: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 14),
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(LucideIcons.chevronRight, size: Responsive.sp(context, 20), color: Colors.red),
                onTap: () => _showDeleteAccountFlow(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountFlow(BuildContext context) async {
    final authRepo = context.read<AuthRepository>();

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account, profile, workouts, routines, and uploaded photos. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (proceed != true || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DeleteAccountConfirmDialog(
        isEmailUser: authRepo.isEmailUser,
        onDelete: (password) async {
          await authRepo.deleteAccount(password: password);
        },
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
                      fontWeight: FontWeight.bold,
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
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
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
                      style: TextStyle(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.bold),
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

class _DeleteAccountConfirmDialog extends StatefulWidget {
  final bool isEmailUser;
  final Future<void> Function(String? password) onDelete;

  const _DeleteAccountConfirmDialog({
    required this.isEmailUser,
    required this.onDelete,
  });

  @override
  State<_DeleteAccountConfirmDialog> createState() => _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState extends State<_DeleteAccountConfirmDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isEmailUser) {
      if (_passwordController.text.isEmpty) {
        setState(() => _errorMessage = 'Please enter your password.');
        return;
      }
    } else {
      if (_confirmController.text.trim() != 'DELETE') {
        setState(() => _errorMessage = 'Type DELETE to confirm.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onDelete(
        widget.isEmailUser ? _passwordController.text : null,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your account has been deleted.')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not delete account. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isEmailUser
                ? 'Enter your password to permanently delete your account.'
                : 'Type DELETE below to permanently delete your account.',
          ),
          const SizedBox(height: 16),
          if (widget.isEmailUser)
            TextField(
              controller: _passwordController,
              obscureText: true,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            )
          else
            TextField(
              controller: _confirmController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Type DELETE',
                border: OutlineInputBorder(),
              ),
            ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete Account'),
        ),
      ],
    );
  }
}
