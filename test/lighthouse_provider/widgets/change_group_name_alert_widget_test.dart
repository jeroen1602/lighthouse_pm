import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/change_group_name_alert_widget.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets("Should create a change group name alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ChangeGroupNameAlertWidget.showCustomDialog(context,
          initialGroupName: null);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group name"), findsNWidgets(2));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
      "Should show set if no initial name is set for change group name alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ChangeGroupNameAlertWidget.showCustomDialog(context,
          initialGroupName: null);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group name"), findsNWidgets(2));
    expect(find.text("Set"), findsOneWidget);
    expect(find.text("Save"), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
      "Should show save if initial name is set for change group name alert widget",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ChangeGroupNameAlertWidget.showCustomDialog(context,
          initialGroupName: "Name");
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group name"), findsNWidgets(2));
    expect(find.text("Save"), findsOneWidget);
    expect(find.text("Set"), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should return new name for change group name alert widget",
      (WidgetTester tester) async {
    Future<String?>? future;

    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = ChangeGroupNameAlertWidget.showCustomDialog(context,
          initialGroupName: null);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group name"), findsNWidgets(2));
    expect(future, isNotNull);

    // Set the name.
    await tester.enterText(find.byType(TextField), "New group");
    await tester.pumpAndSettle();

    await tester.tap(find.text("Set"));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!;
    expect(value, isNotNull);
    expect(value, "New group");
  });

  testWidgets(
      "Should not return new name if whitespace for change group name alert widget",
      (WidgetTester tester) async {
    Future<String?>? future;

    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = ChangeGroupNameAlertWidget.showCustomDialog(context,
          initialGroupName: null);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Group name"), findsNWidgets(2));
    expect(future, isNotNull);

    // Set the name.
    await tester.enterText(find.byType(TextField), "  \t\t ");
    await tester.pumpAndSettle();

    await tester.tap(find.text("Set"));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!;
    expect(value, isNull);
  });
}
