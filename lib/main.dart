import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wellness_diary/providers/auth_provider.dart';
import 'package:wellness_diary/providers/mood_provider.dart';
import 'package:wellness_diary/providers/health_vital_provider.dart';
import 'package:wellness_diary/providers/medicine_provider.dart';
import 'package:wellness_diary/providers/theme_provider.dart';
import 'package:wellness_diary/screens/home_screen.dart';
import 'package:wellness_diary/screens/login_screen.dart';
import 'package:wellness_diary/services/firebase_service.dart';
import 'package:wellness_diary/utils/app_theme.dart';
import 'package:wellness_diary/utils/notification_service.dart';
import 'models/mood_model.dart';
import 'models/health_vital_model.dart';
import 'models/medicine_model.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (will continue with local storage if not configured)
  await FirebaseService.initialize();
  
  // Initialize Hive (local storage - always used as backup)
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(MoodModelAdapter());
  Hive.registerAdapter(HealthVitalModelAdapter());
  Hive.registerAdapter(MedicineModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  
  // Open Hive boxes
  await Hive.openBox<MoodModel>('moods');
  await Hive.openBox<HealthVitalModel>('health_vitals');
  await Hive.openBox<MedicineModel>('medicines');
  await Hive.openBox<UserModel>('users');
  
  // Initialize notification service (skip on web)
  if (!kIsWeb) {
    await NotificationService().init();
  }
  
  // Set preferred orientations (skip on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  runApp(const WellnessDiaryApp());
}

class WellnessDiaryApp extends StatelessWidget {
  const WellnessDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => HealthVitalProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, _) {
          // Update providers with current user ID when authenticated
          if (authProvider.isAuthenticated && authProvider.currentUser != null) {
            final userId = authProvider.currentUser!.id;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<HealthVitalProvider>().setUserId(userId, context);
              context.read<MedicineProvider>().setUserId(userId, context);
              context.read<MoodProvider>().setUserId(userId, context);
            });
          }
          
          return MaterialApp(
            title: 'Wellness Diary',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: authProvider.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/login': (_) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}

