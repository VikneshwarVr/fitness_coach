import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/providers/settings_provider.dart';
import '../components/fitness_card.dart';

class OneRMCalculatorScreen extends StatefulWidget {
  const OneRMCalculatorScreen({super.key});

  @override
  State<OneRMCalculatorScreen> createState() => _OneRMCalculatorScreenState();
}

class _OneRMCalculatorScreenState extends State<OneRMCalculatorScreen> {
  final TextEditingController _weightController = TextEditingController(text: '100');
  int _reps = 5;
  String _selectedFormula = 'Epley';

  final List<String> _formulas = ['Epley', 'Brzycki', 'Lander', 'Lombardi', "O'Conner"];

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  double get _parsedWeight {
    return double.tryParse(_weightController.text) ?? 0.0;
  }

  double _calculate1RM(double weight, int reps, String formula) {
    if (weight <= 0 || reps <= 0) return 0.0;
    
    switch (formula) {
      case 'Epley':
        return weight * (1.0 + reps / 30.0);
      case 'Brzycki':
        if (reps >= 37) return weight;
        return weight / (1.0278 - 0.0278 * reps);
      case 'Lander':
        if (reps >= 38) return weight;
        return (100.0 * weight) / (101.3 - 2.6712 * reps);
      case 'Lombardi':
        return weight * math.pow(reps, 0.1);
      case "O'Conner":
        return weight * (1.0 + reps / 40.0);
      default:
        return weight * (1.0 + reps / 30.0);
    }
  }

  int _estimateRepsForPercentage(double percentage) {
    if (percentage >= 1.0) return 1;
    if (percentage >= 0.95) return 2;
    if (percentage >= 0.90) return 4;
    if (percentage >= 0.85) return 6;
    if (percentage >= 0.80) return 8;
    if (percentage >= 0.75) return 10;
    if (percentage >= 0.70) return 12;
    if (percentage >= 0.65) return 15;
    if (percentage >= 0.60) return 20;
    if (percentage >= 0.55) return 25;
    return 30;
  }

  void _adjustWeight(double amount) {
    final current = _parsedWeight;
    final next = (current + amount).clamp(0.0, 999.5);
    final text = next % 1 == 0 ? next.toStringAsFixed(0) : next.toStringAsFixed(1);
    
    setState(() {
      _weightController.text = text;
      _weightController.selection = TextSelection.fromPosition(
        TextPosition(offset: _weightController.text.length),
      );
    });
  }

  void _adjustReps(int amount) {
    setState(() {
      _reps = (_reps + amount).clamp(1, 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final unit = settings.unitLabel;
    
    final weightVal = _parsedWeight;
    final current1RM = _calculate1RM(weightVal, _reps, _selectedFormula);

    final display1RM = current1RM % 1 == 0 ? current1RM.toStringAsFixed(0) : current1RM.toStringAsFixed(1);
    final percentages = [1.0, 0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '1RM Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.p(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result Display
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA580C), Color(0xFFB45309)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.h(context, 28),
                  horizontal: Responsive.w(context, 16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated 1-Rep Max',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          display1RM,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.sp(context, 48),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: Responsive.w(context, 6)),
                        Text(
                          unit,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: Responsive.sp(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(context, 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Formula: $_selectedFormula',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(context, 12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(context, 24)),

              // Weight / Rep Inputs
              Text(
                'Lift Input Details',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.h(context, 12)),
              FitnessCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weight Lifted ($unit)',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            _QuickWeightButton(
                              label: '-10',
                              onPressed: () => _adjustWeight(-10.0),
                            ),
                            const SizedBox(width: 4),
                            _QuickWeightButton(
                              label: '-2.5',
                              onPressed: () => _adjustWeight(-2.5),
                            ),
                            const SizedBox(width: 8),
                            _QuickWeightButton(
                              label: '+2.5',
                              onPressed: () => _adjustWeight(2.5),
                            ),
                            const SizedBox(width: 4),
                            _QuickWeightButton(
                              label: '+10',
                              onPressed: () => _adjustWeight(10.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(context, 8)),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(LucideIcons.minus),
                          onPressed: () => _adjustWeight(-1.0),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Responsive.sp(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(LucideIcons.plus),
                          onPressed: () => _adjustWeight(1.0),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(context, 20)),

                    // Reps
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reps Performed',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$_reps Reps',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.sp(context, 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(context, 4)),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(LucideIcons.minus),
                          onPressed: () => _adjustReps(-1),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _reps.toDouble(),
                            min: 1.0,
                            max: 30.0,
                            divisions: 29,
                            label: '$_reps',
                            activeColor: Theme.of(context).colorScheme.primary,
                            inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            onChanged: (val) {
                              setState(() {
                                _reps = val.toInt();
                              });
                            },
                          ),
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(LucideIcons.plus),
                          onPressed: () => _adjustReps(1),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(context, 24)),

              // Formula Chips
              Text(
                'Estimation Formula',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.h(context, 10)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _formulas.map((formula) {
                    final isSelected = _selectedFormula == formula;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(formula),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: Responsive.sp(context, 12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFormula = formula;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: Responsive.h(context, 24)),

              // Comparison Table
              Text(
                'Formula Comparison',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.h(context, 12)),
              FitnessCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: _formulas.map((formula) {
                    final value = _calculate1RM(weightVal, _reps, formula);
                    final formattedVal = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
                    final isCurrent = _selectedFormula == formula;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.06)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                formula,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                  color: isCurrent
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontSize: Responsive.sp(context, 14),
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '$formattedVal $unit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.sp(context, 14),
                              color: isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: Responsive.h(context, 24)),

              // Rep Breakdown Table
              Text(
                'Percentage & Rep Breakdown',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.h(context, 12)),
              FitnessCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '% of 1RM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.sp(context, 12),
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Weight',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.sp(context, 12),
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Est. Reps',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.sp(context, 12),
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...percentages.map((pct) {
                      final targetWeight = current1RM * pct;
                      final targetWeightStr = targetWeight % 1 == 0 
                          ? targetWeight.toStringAsFixed(0) 
                          : targetWeight.toStringAsFixed(1);
                      final estReps = _estimateRepsForPercentage(pct);
                      final is100Percent = pct == 1.0;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${(pct * 100).toInt()}%',
                                style: TextStyle(
                                  fontWeight: is100Percent ? FontWeight.bold : FontWeight.w500,
                                  color: is100Percent 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontSize: Responsive.sp(context, 13),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '$targetWeightStr $unit',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.sp(context, 13),
                                  color: is100Percent 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                is100Percent ? '1 Rep' : '$estReps Reps',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: is100Percent ? FontWeight.bold : FontWeight.w500,
                                  color: is100Percent
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: Responsive.sp(context, 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickWeightButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickWeightButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(context, 11),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
