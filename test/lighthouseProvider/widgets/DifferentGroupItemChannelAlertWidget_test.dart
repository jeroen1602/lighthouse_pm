import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/DifferentGroupItemChannelAlertWidget.dart';

import '../../helpers/WidgetHelpers.dart';

void main() {
  testWidgets("Should create a different group item channel alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      DifferentGroupItemChannelAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices have the same channel"), findsOneWidget);
    expect(
        find.textContaining(
            "Some of the devices you have selected use the same channel."),
        findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
      "Should return false when cancel is hit group item channel alert widget",
      (WidgetTester tester) async {
    Future<bool>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = DifferentGroupItemChannelAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices have the same channel"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isFalse);
  });

  testWidgets(
      "Should return true when I'm sure is hit group item channel alert widget",
      (WidgetTester tester) async {
    Future<bool>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = DifferentGroupItemChannelAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices have the same channel"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text("I'm sure"));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isTrue);
  });
}
