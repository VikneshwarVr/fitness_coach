import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_app/data/repositories/workout_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final List<Map<String, dynamic>> data;
  FakeSupabaseQueryBuilder(this.data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String? columns]) => FakeFilterBuilder(data);
}

class FakeFilterBuilder extends Fake implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> data;
  FakeFilterBuilder(this.data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;
  
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    return this;
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> range(int from, int to, {String? referencedTable}) {
    return this;
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {Function? onError}) {
    return Future.value(onValue(data));
  }
}

void main() {
  late WorkoutRepository repository;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    repository = WorkoutRepository(mockSupabase);

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
  });

  test('loadWorkouts updates local list on success', () async {
    final mockData = [
      {
        'id': '1',
        'name': 'Great Workout',
        'date': DateTime.now().toIso8601String(),
        'duration': 45,
        'total_volume': 5000,
        'mode': 'gym',
        'workout_exercises': []
      }
    ];

    when(() => mockSupabase.from('workouts')).thenAnswer((_) => FakeSupabaseQueryBuilder(mockData));

    await repository.loadWorkouts();

    expect(repository.workouts.length, 1);
    expect(repository.workouts[0].name, 'Great Workout');
  });
}
