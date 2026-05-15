import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beauty_ai_app/screens/onboarding_pager.dart';

void main() {
  testWidgets('OnboardingPager loads correctly', (WidgetTester tester) async {
    // Build the app inside MaterialApp (important!)
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingPager(),
      ),
    );

    // Verify first onboarding text is shown
    expect(find.textContaining('Beauty on'), findsOneWidget);

    // Swipe to next page
    await tester.drag(
      find.byType(PageView),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();

    // Verify second screen button exists
    expect(find.text('Get Started'), findsOneWidget);
  });
}
