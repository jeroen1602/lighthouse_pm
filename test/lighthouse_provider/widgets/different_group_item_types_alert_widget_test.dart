import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/different_group_item_types_alert_widget.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets("Should create a different group item type alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      DifferentGroupItemTypesAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Not all devices have the same type"), findsOneWidget);
    expect(
        find.textContaining("Not all the devices you want to add to the group"),
        findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
      "Should return false when cancel is hit group item type alert widget",
      (WidgetTester tester) async {
    Future<bool>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = DifferentGroupItemTypesAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Not all devices have the same type"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isFalse);
  });

  testWidgets(
      "Should return true when I'm sure is hit group item type alert widget",
      (WidgetTester tester) async {
    Future<bool>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = DifferentGroupItemTypesAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Not all devices have the same type"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text("I'm sure"));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isTrue);
  });
}
