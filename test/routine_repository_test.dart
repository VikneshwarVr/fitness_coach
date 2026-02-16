import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_app/data/repositories/routine_repository.dart';

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
  }) => this;

  @override
  Future<R> then<R>(FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {Function? onError}) {
    return Future.value(onValue(data));
  }
}

void main() {
  late RoutineRepository repository;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() async {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    repository = RoutineRepository(mockSupabase);

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
  });

  test('loadRoutines parses data correctly', () async {
    final mockData = [
      {
        'id': '1',
        'name': 'Custom Routine',
        'description': 'Description',
        'level': 'Beginner',
        'duration': 30,
        'mode': 'gym',
        'routine_exercises': [
          {
            'id': 'e1',
            'exercise_name': 'Pushups',
            'category': 'Bodyweight',
            'sets': [
              {'id': 's1', 'weight': 0, 'reps': 10},
              {'id': 's2', 'weight': 0, 'reps': 12},
            ]
          }
        ]
      }
    ];

    when(() => mockSupabase.from('routines')).thenAnswer((_) => FakeSupabaseQueryBuilder(mockData));

    await repository.loadRoutines();

    expect(repository.customRoutines.length, 1);
    expect(repository.customRoutines[0].name, 'Custom Routine');
    expect(repository.customRoutines[0].exercises.length, 1);
    expect(repository.customRoutines[0].exercises[0].sets.length, 2);
  });
}
