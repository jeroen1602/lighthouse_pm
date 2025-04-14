import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/pages/settings/privacy_page.dart';

import '../helpers/widget_helpers.dart';

void main() {
  const version1_2Date = "November 24th 2024";

  testWidgets('Should create privacy page', (final WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp((final context) {
        return const PrivacyPage();
      }),
    );

    await tester.pumpAndSettle();

    expect(find.text("Privacy"), findsOneWidget, reason: "Should find heading");
    expect(
      find.textContaining(version1_2Date),
      findsOneWidget,
      reason: "Should find privacy versions",
    );
  });
}
