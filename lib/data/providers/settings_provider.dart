import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WeightUnit { kg, lbs }
enum WorkoutMode { home, gym }

class SettingsProvider extends ChangeNotifier {
  static const String _weightUnitKey = 'weight_unit';
  static const String _restTimerKey = 'rest_timer';
  static const String _workoutModeKey = 'workout_mode';

  WeightUnit _weightUnit = WeightUnit.kg;
  int _defaultRestTimer = 90; // Default 90 seconds
  WorkoutMode _workoutMode = WorkoutMode.gym;

  WeightUnit get weightUnit => _weightUnit;
  int get defaultRestTimer => _defaultRestTimer;
  bool get isRestTimerEnabled => _defaultRestTimer > 0;
  WorkoutMode get workoutMode => _workoutMode;
  bool get isGymMode => _workoutMode == WorkoutMode.gym;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final unitIndex = prefs.getInt(_weightUnitKey);
    if (unitIndex != null) {
      _weightUnit = WeightUnit.values[unitIndex];
    }

    final timer = prefs.getInt(_restTimerKey);
    if (timer != null) {
      _defaultRestTimer = timer;
    }

    final modeIndex = prefs.getInt(_workoutModeKey);
    if (modeIndex != null) {
      _workoutMode = WorkoutMode.values[modeIndex];
    }
    
    notifyListeners();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    _weightUnit = unit;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weightUnitKey, unit.index);
  }

  Future<void> setDefaultRestTimer(int seconds) async {
    _defaultRestTimer = seconds;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_restTimerKey, seconds);
  }

  Future<void> setWorkoutMode(WorkoutMode mode) async {
    _workoutMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_workoutModeKey, mode.index);
  }
  
  void toggleWorkoutMode() {
    setWorkoutMode(_workoutMode == WorkoutMode.gym ? WorkoutMode.home : WorkoutMode.gym);
  }

  // Conversion Helpers
  double convertToDisplay(num kg) {
    if (_weightUnit == WeightUnit.kg) return kg.toDouble();
    return kg * 2.20462;
  }

  double convertToKg(num displayWeight) {
    if (_weightUnit == WeightUnit.kg) return displayWeight.toDouble();
    return displayWeight / 2.20462;
  }

  String formatWeight(num kg, {bool showUnit = true}) {
    final displayWeight = convertToDisplay(kg);
    final formatted = displayWeight.toStringAsFixed(displayWeight % 1 == 0 ? 0 : 1);
    if (!showUnit) return formatted;
    return '$formatted ${_weightUnit == WeightUnit.kg ? 'kg' : 'lb'}';
  }

  String get unitLabel => _weightUnit == WeightUnit.kg ? 'kg' : 'lb';

  String get formatRestTimer => _defaultRestTimer > 0 ? '$_defaultRestTimer seconds' : 'Off';
}
