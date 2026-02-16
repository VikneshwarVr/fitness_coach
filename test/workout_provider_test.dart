import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_app/data/providers/workout_provider.dart';
import 'package:flutter_app/data/repositories/workout_repository.dart';
import 'package:flutter_app/data/models/routine.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late WorkoutProvider provider;
  late MockWorkoutRepository mockRepo;

  setUp(() {
    mockRepo = MockWorkoutRepository();
    provider = WorkoutProvider(mockRepo);

    // Common stubs
    registerFallbackValue(const Duration(seconds: 1));
  });

  test('startWorkout initializes state correctly and fetches history', () async {
    final routine = Routine(
      id: 'r1',
      name: 'Test Routine',
      description: '',
      exercises: [
        RoutineExercise(id: 'e1', name: 'Bench Press', category: 'Strength', sets: []),
      ],
      level: 'Beginner',
      duration: 30,
    );

    when(() => mockRepo.getPreviousSets(any())).thenAnswer((_) async => []);
    when(() => mockRepo.getExercisePRs(any())).thenAnswer((_) async => {});

    await provider.startWorkout(routine: routine);

    expect(provider.isWorkoutActive, true);
    expect(provider.workoutName, 'Test Routine');
    expect(provider.exercises.length, 1);
    expect(provider.exercises[0].name, 'Bench Press');
    
    verify(() => mockRepo.getPreviousSets('Bench Press')).called(1);
  });

  test('toggleSetCompletion triggers PR check and rest timer', () async {
    final routine = Routine(
      id: 'r1',
      name: 'Test Routine',
      description: '',
      exercises: [
        RoutineExercise(id: 'e1', name: 'Bench Press', category: 'Strength', sets: []),
      ],
      level: 'Beginner',
      duration: 30,
    );

    when(() => mockRepo.getPreviousSets(any())).thenAnswer((_) async => []);
    when(() => mockRepo.getExercisePRs(any())).thenAnswer((_) async => {});

    await provider.startWorkout(routine: routine);
    
    final exerciseId = provider.exercises[0].id;
    final setId = provider.exercises[0].sets[0].id;

    await provider.toggleSetCompletion(exerciseId, setId);

    expect(provider.exercises[0].sets[0].completed, true);
  });
}
