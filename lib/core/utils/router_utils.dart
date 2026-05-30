import '../../data/models/routine.dart';

Routine? routineFromExtra(Object? extra) {
  if (extra == null) return null;
  if (extra is Routine) return extra;
  if (extra is Map) {
    return Routine.fromJson(Map<String, dynamic>.from(extra));
  }
  return null;
}
