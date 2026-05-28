double estimateOneRepMax({required double weight, required double reps}) {
  if (weight <= 0 || reps <= 0) return 0.0;
  if (reps <= 1) return weight;
  if (reps <= 10) {
    final denominator = 37.0 - reps;
    if (denominator <= 0) return weight;
    return weight * (36.0 / denominator);
  }
  return weight * (1 + (reps / 30.0));
}
