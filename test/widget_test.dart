import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/main.dart';

void main() {
  testWidgets('App loads and shows HomeScreen or Onboarding', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp(seenOnboarding: false));

    // Wait for widgets to build
    await tester.pumpAndSettle();

    // Verify OnboardingScreen shows "Discover Recipes"
    expect(find.text("Discover Recipes"), findsOneWidget);

    // Tap "Start" button to finish onboarding
    await tester.tap(find.text("Start"));
    await tester.pumpAndSettle();

    // Verify HomeScreen shows bottom navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify Home tab is selected
    expect(find.text("Random Meal Suggestion"), findsOneWidget);
  });
}
