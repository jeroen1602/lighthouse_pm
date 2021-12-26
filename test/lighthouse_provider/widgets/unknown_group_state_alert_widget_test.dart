import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_power_state.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/unknown_group_state_alert_widget.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets("Should create an universal Unknown group state alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      UnknownGroupStateAlertWidget.showCustomDialog(context, false, true);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is unknown"), findsOneWidget);

    final richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .toList()[1];
    final text = richText.text.toPlainText();

    expect(
        text, contains("The state of the devices in this group are unknown,"));
    expect(text, contains("what do you want to do?"));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should create a non universal Unknown group state alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      UnknownGroupStateAlertWidget.showCustomDialog(context, false, false);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is not universal"), findsOneWidget);
    expect(
        find.textContaining(
            "Not all the devices in this group have the same state,"),
        findsOneWidget);
    expect(find.textContaining("what do you want to do?"), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should create actions for Unknown group state alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      UnknownGroupStateAlertWidget.showCustomDialog(context, false, true);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is unknown"), findsOneWidget);

    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Standby"), findsNothing);
    expect(find.text("Sleep"), findsOneWidget);
    expect(find.text("On"), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
      "Should add standby if supported for Unknown group state alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      UnknownGroupStateAlertWidget.showCustomDialog(context, true, true);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is unknown"), findsOneWidget);

    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Standby"), findsOneWidget);
    expect(find.text("Sleep"), findsOneWidget);
    expect(find.text("On"), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should return null on cancel Unknown group state alert widget",
      (WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future =
          UnknownGroupStateAlertWidget.showCustomDialog(context, true, false);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is not universal"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isNull);
  });

  testWidgets("Should return on state on 'on' Unknown group state alert widget",
      (WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future =
          UnknownGroupStateAlertWidget.showCustomDialog(context, true, false);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is not universal"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('On'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isNotNull);
    expect(value, LighthousePowerState.on);
  });

  testWidgets(
      "Should return sleep state on 'sleep' Unknown group state alert widget",
      (WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future =
          UnknownGroupStateAlertWidget.showCustomDialog(context, true, false);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is not universal"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isNotNull);
    expect(value, LighthousePowerState.sleep);
  });

  testWidgets(
      "Should return standby state on 'standby' Unknown group state alert widget",
      (WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future =
          UnknownGroupStateAlertWidget.showCustomDialog(context, true, false);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group state is not universal"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Standby'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isNotNull);
    expect(value, LighthousePowerState.standby);
  });
}
