import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'data/repositories/workout_repository.dart';
import 'data/repositories/routine_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/navigation/router.dart';
import 'presentation/screens/splash_screen.dart';
import 'data/providers/workout_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final authRepository = AuthRepository();
  runApp(FitnessTrackerApp(authRepository: authRepository));
}

class FitnessTrackerApp extends StatefulWidget {
  final AuthRepository authRepository;
  const FitnessTrackerApp({super.key, required this.authRepository});

  @override
  State<FitnessTrackerApp> createState() => _FitnessTrackerAppState();
}

class _FitnessTrackerAppState extends State<FitnessTrackerApp> {
  late final GoRouter _router;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.authRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider.value(value: widget.authRepository),
        ChangeNotifierProvider(create: (_) => WorkoutRepository()),
        ChangeNotifierProvider(create: (_) => RoutineRepository()),
        ChangeNotifierProxyProvider<WorkoutRepository, WorkoutProvider>(
          create: (context) => WorkoutProvider(Provider.of<WorkoutRepository>(context, listen: false)),
          update: (context, repo, previous) => previous ?? WorkoutProvider(repo),
        ),
      ],
      builder: (context, child) {
        final themeProvider = context.watch<ThemeProvider>();
        
        if (_showSplash) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: SplashScreen(
              onFinish: () {
                setState(() {
                  _showSplash = false;
                });
              },
            ),
          );
        }
        
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
        );
      },
    );
  }
}
