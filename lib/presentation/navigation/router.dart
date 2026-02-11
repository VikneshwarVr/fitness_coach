import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'scaffold_with_navbar.dart';
import '../screens/home_screen.dart'; 
import '../screens/workout_screen.dart';
import '../screens/add_exercise_screen.dart';
import '../screens/finish_workout_screen.dart';
import '../screens/routines_screen.dart';
import '../screens/workout_details_screen.dart';
import '../screens/create_routine_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../../data/models/routine.dart';
import '../../data/repositories/auth_repository.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorRoutinesKey = GlobalKey<NavigatorState>(debugLabel: 'shellRoutines');
final GlobalKey<NavigatorState> _shellNavigatorHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

GoRouter createRouter(AuthRepository authRepo) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authRepo,
    redirect: (context, state) {
      final isAuthenticated = authRepo.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      if (isAuthenticated && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorRoutinesKey,
            routes: [
              GoRoute(
                path: '/routines',
                builder: (context, state) => const RoutinesScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CreateRoutineScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHistoryKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Top-level workout route (not in shell)
      GoRoute(
        path: '/workout',
        builder: (context, state) {
           final routine = state.extra as Routine?;
           return WorkoutScreen(initialRoutine: routine);
        },
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddExerciseScreen(
                isMultiSelect: extra?['isMultiSelect'] ?? false,
                initialSelectedExercises: extra?['initialSelectedExercises'] ?? const [],
              );
            },
          ),
          GoRoute(
            path: 'finish',
            builder: (context, state) => const FinishWorkoutScreen(),
          ),
          GoRoute(
            path: 'details/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return WorkoutDetailsScreen(workoutId: id);
            },
          ),
        ],
      ),
    ],
  );
}
