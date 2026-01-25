import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'services/app_config.dart';
import 'services/admob_service.dart';
import 'services/att_service.dart';
import 'services/app_open_ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Load config before running the app
  await AppConfig.getInstance();

  // Ask App Not To Track (iOS 14+). Safe no-op elsewhere.
  await AttService.requestAuthorizationIfNeeded();
  
  // Initialize AdMob
  await AdMobService.initialize();

  // App Open Ad (show on foreground/resume)
  final appOpenAdService = await AppOpenAdService.getInstance();
  appOpenAdService.attach();
  await appOpenAdService.warmUp();
  
  runApp(const MyApp());

  // Attempt to show once after first frame (cold start).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    appOpenAdService.showIfAvailable();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppConfig>(
      future: AppConfig.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final config = snapshot.data!;
        return MaterialApp(
          title: config.appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: config.primaryColor),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
