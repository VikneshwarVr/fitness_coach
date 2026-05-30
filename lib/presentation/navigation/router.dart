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
import '../screens/exercise_list_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/general_settings_screen.dart';
import '../screens/one_rm_calculator_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/utils/router_utils.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorRoutinesKey = GlobalKey<NavigatorState>(debugLabel: 'shellRoutines');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

GoRouter createRouter(AuthRepository authRepo) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authRepo,
    redirect: (context, state) {
      final isAuthenticated = authRepo.isAuthenticated;
      final location = state.matchedLocation;
      final isPublicRoute = location == '/login' || location == '/profile/privacy';

      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }
      if (isAuthenticated && location == '/login') {
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
                    builder: (context, state) {
                      return CreateRoutineScreen(
                        initialRoutine: routineFromExtra(state.extra),
                      );
                    },
                  ),
                ],
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
           return WorkoutScreen(initialRoutine: routineFromExtra(state.extra));
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
            path: 'edit',
            builder: (context, state) {
               final routine = routineFromExtra(state.extra);
               return WorkoutScreen(
                 initialRoutine: routine,
                 isEditing: true,
               );
            },
          ),
          GoRoute(
            path: 'edit-log',
            builder: (context, state) {
               // Provider should be pre-loaded by the caller (WorkoutDetailsScreen)
               return const WorkoutScreen(isEditingLog: true);
            },
          ),
          GoRoute(
            path: 'finish/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return FinishWorkoutScreen(workoutId: id == 'new' ? null : id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/workout-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkoutDetailsScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/exercises',
        builder: (context, state) => const ExerciseListScreen(),
      ),
      GoRoute(
        path: '/profile/user',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/profile/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/profile/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const GeneralSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/1rm-calculator',
        builder: (context, state) => const OneRMCalculatorScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
}
