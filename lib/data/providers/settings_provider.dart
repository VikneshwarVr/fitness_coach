import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WeightUnit { kg, lbs }

class SettingsProvider extends ChangeNotifier {
  static const String _weightUnitKey = 'weight_unit';
  static const String _restTimerKey = 'rest_timer';

  WeightUnit _weightUnit = WeightUnit.kg;
  int _defaultRestTimer = 90; // Default 90 seconds

  WeightUnit get weightUnit => _weightUnit;
  int get defaultRestTimer => _defaultRestTimer;

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
}
