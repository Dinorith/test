import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/ui/screens/onboarding_screen.dart';
import 'src/ui/screens/home_screen.dart'; // we will create this next

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  
  // Reset onboarding flag to show onboarding first
  // Remove this line after first test
  await prefs.remove('seenOnboarding');
  
  // Check if onboarding has been completed
  // By default (first app launch), seenOnboarding will be false, showing onboarding screen
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    ProviderScope(
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,

      // Default route
      initialRoute: seenOnboarding ? '/home' : '/onboarding',

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
