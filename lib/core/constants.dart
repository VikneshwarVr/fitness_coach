class AppConstants {
  static const String appName = 'Elevate';

  /// Deep link used by Supabase OAuth (must match Dashboard → Redirect URLs).
  static const String oauthRedirectUrl = 'io.supabase.fitness://login-callback/';

  // Storage Keys
  static const String workoutsKey = 'workouts';
  static const String routinesKey = 'routines';
  static const String profileKey = 'profile';
  
  // Default values
  static const int defaultGoal = 4; // workouts per week
}
