import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/offline_group_item_alert_widget.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets("Should create a offline group item alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      OfflineGroupItemAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices are offline"), findsOneWidget);
    expect(
        find.textContaining(
            "Some devices in this group are offline, do you want to continue"),
        findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
      "Should return canceled is true when cancel is hit offline group item alert widget",
      (WidgetTester tester) async {
    Future<OfflineGroupItemAlertWidgetReturn>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = OfflineGroupItemAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices are offline"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value.dialogCanceled, isTrue);
    expect(value.disableWarning, isFalse);
  });

  testWidgets(
      "Should return canceled is false when I'm sure is hit offline group item alert widget",
      (WidgetTester tester) async {
    Future<OfflineGroupItemAlertWidgetReturn>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = OfflineGroupItemAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices are offline"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text("Continue"));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value.dialogCanceled, isFalse);
    expect(value.disableWarning, isFalse);
  });

  testWidgets(
      "Should return disable warning is false when cancel is hit and disable warning offline group item alert widget",
      (WidgetTester tester) async {
    Future<OfflineGroupItemAlertWidgetReturn>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = OfflineGroupItemAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices are offline"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text("Don't show this warning again."));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value.dialogCanceled, isTrue);
    expect(value.disableWarning, isFalse);
  });

  testWidgets(
      "Should return disable warning is true when I'm sure is hit and disable warning  offline group item alert widget",
      (WidgetTester tester) async {
    Future<OfflineGroupItemAlertWidgetReturn>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = OfflineGroupItemAlertWidget.showCustomDialog(context);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Some devices are offline"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text("Don't show this warning again."));

    await tester.tap(find.text("Continue"));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value.dialogCanceled, isFalse);
    expect(value.disableWarning, isTrue);
  });
}
