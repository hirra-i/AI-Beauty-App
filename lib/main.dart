import 'package:beauty_ai_app/screens/recommendations_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/app_theme.dart';
import 'screens/app_splash_screen.dart';
import 'screens/onboarding_pager.dart';
import 'screens/loading_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/personalised_guidance_permissions_screen.dart';
import 'screens/ai_scan_screen.dart';
import 'screens/home_hub_screen.dart';
import 'screens/welcome_back_screen.dart';
import 'screens/profile_redirect_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const AppSplashScreen(),
        '/onboarding': (_) => const OnboardingPager(),
        '/loading': (_) => const LoadingScreen(),
        '/preferences': (_) => const PreferencesScreen(),
        '/permissions': (_) => const PersonalisedGuidancePermissionsScreen(),
        '/aiScan': (_) => const AiScanScreen(),
        '/welcomeBack': (_) => const WelcomeBackScreen(),
        //NEW MAIN HUB ROUTE
        '/homeHub': (_) => const HomeHubScreen(),
        '/home': (_) => const BeautyProfileSummaryScreen(),
        '/redirect': (_) => const ProfileRedirectScreen(),
        '/recommendations': (context) {
          final advice = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;

          return RecommendationsScreen(advice: advice);
        }
      },
    );
  }
}
