import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/DeleteGroupAlertWidget.dart';

import '../../helpers/WidgetHelpers.dart';

void main() {
  testWidgets("Should create a delete group alert widget",
      (WidgetTester tester) async {
    final group = Group(id: 1, name: "Test group");
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      DeleteGroupAlertWidget.showCustomDialog(context, group: group);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Delete group"), findsOneWidget);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should show group name delete group alert widget",
      (WidgetTester tester) async {
    final group = Group(id: 1, name: "Test group");
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      DeleteGroupAlertWidget.showCustomDialog(context, group: group);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Delete group"), findsOneWidget);

    final richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .toList()[1];
    final text = richText.text.toPlainText();

    expect(text, contains("Test group"));
    expect(text, contains("Are you sure you want to delete the group"));

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should return false when no is hit delete group alert widget",
      (WidgetTester tester) async {
    final group = Group(id: 1, name: "Test group");

    Future<bool>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = DeleteGroupAlertWidget.showCustomDialog(context, group: group);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Delete group"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isFalse);
  });

  testWidgets("Should return true when yes is hit delete group alert widget",
      (WidgetTester tester) async {
    final group = Group(id: 1, name: "Test group");

    Future<bool>? future;
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      future = DeleteGroupAlertWidget.showCustomDialog(context, group: group);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Delete group"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(Duration(seconds: 1));
    expect(value, isTrue);
  });
}
