import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/ViveBaseStationExtraInfoAlertWidget.dart';

import '../../helpers/WidgetHelpers.dart';

void main() {
  testWidgets("Should create vive base station dialog",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ViveBaseStationExtraInfoAlertWidget.showCustomDialog(context, 0x1020);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    final richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    final text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('1020'), reason: "Find device id ending");

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should validate input vive base station dialog",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ViveBaseStationExtraInfoAlertWidget.showCustomDialog(context, 0x1020);
    }));

    // Wait for the progress indicator to stop
    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    final richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    final text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('1020'), reason: "Find device id ending");

    final formFieldFinder = find.byType(TextFormField);

    await tester.enterText(formFieldFinder, " ");
    await tester.pumpAndSettle();

    expect(find.text("Please enter the id"), findsOneWidget);

    await tester.enterText(formFieldFinder, "ABCQ");
    await tester.pumpAndSettle();

    expect(
        find.text("Please use legal characters [a-fA-F0-9]"), findsOneWidget);

    await tester.enterText(formFieldFinder, "ABC");
    await tester.pumpAndSettle();

    expect(find.text("Please enter at least the first 4 characters"),
        findsOneWidget);

    await tester.enterText(formFieldFinder, "ABCDEF");
    await tester.pumpAndSettle();

    expect(find.text("Please enter the rest of the id"), findsOneWidget);

    await tester.enterText(formFieldFinder, "ABCDEF123");
    await tester.pumpAndSettle();

    expect(find.text("The length of the id must be 8 digits"), findsOneWidget);
  });

  testWidgets(
      "Should ask for confirmation if id doesn't match vive base station dialog",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ViveBaseStationExtraInfoAlertWidget.showCustomDialog(context, 0x1020);
    }));

    // Wait for the progress indicator to stop
    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    final richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    final text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('1020'), reason: "Find device id ending");

    final formFieldFinder = find.byType(TextFormField);

    await tester.enterText(formFieldFinder, "ABCDEF10");
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    //Expect another dialog to be opened.

    expect(find.text("The end of the id doesn't match"), findsOneWidget);

    // Get the second element
    final richTextNewDialog = tester
        .widgetList<RichText>(find.descendant(
            of: find.ancestor(
                of: find.text("The end of the id doesn't match"),
                matching: find.byType(Dialog)),
            matching: find.byType(RichText)))
        .toList()[1];

    final confirmationDialogText = richTextNewDialog.text.toPlainText();

    expect(confirmationDialogText, contains("ABCDEF10"));
    expect(confirmationDialogText, contains("1020"));
    expect(confirmationDialogText, contains("The id you have provided ("));
  });

  testWidgets(
      "Previous dialog should remain if change it is selected vive base station dialog",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ViveBaseStationExtraInfoAlertWidget.showCustomDialog(context, 0x1020);
    }));

    // Wait for the progress indicator to stop
    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    var richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    var text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('1020'), reason: "Find device id ending");

    final formFieldFinder = find.byType(TextFormField);

    await tester.enterText(formFieldFinder, "ABCDEF10");
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    //Expect another dialog to be opened.

    expect(find.text("The end of the id doesn't match"), findsOneWidget);

    // Get the second element
    final richTextNewDialog = tester
        .widgetList<RichText>(find.descendant(
            of: find.ancestor(
                of: find.text("The end of the id doesn't match"),
                matching: find.byType(Dialog)),
            matching: find.byType(RichText)))
        .toList()[1];

    final confirmationDialogText = richTextNewDialog.text.toPlainText();

    expect(confirmationDialogText, contains("ABCDEF10"));
    expect(confirmationDialogText, contains("1020"));
    expect(confirmationDialogText, contains("The id you have provided ("));

    await tester.tap(find.text("Change it"));
    await tester.pumpAndSettle();

    // The other dialog should still be here!
    expect(find.text("The end of the id doesn't match"), findsNothing);

    richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('1020'), reason: "Find device id ending");
  });

  testWidgets(
      "Previous dialog should close if it's correct is selected vive base station dialog",
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((context) {
      ViveBaseStationExtraInfoAlertWidget.showCustomDialog(context, 0x1020);
    }));

    // Wait for the progress indicator to stop
    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    var richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    var text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('1020'), reason: "Find device id ending");

    final formFieldFinder = find.byType(TextFormField);

    await tester.enterText(formFieldFinder, "ABCDEF10");
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    //Expect another dialog to be opened.

    expect(find.text("The end of the id doesn't match"), findsOneWidget);

    // Get the second element
    final richTextNewDialog = tester
        .widgetList<RichText>(find.descendant(
            of: find.ancestor(
                of: find.text("The end of the id doesn't match"),
                matching: find.byType(Dialog)),
            matching: find.byType(RichText)))
        .toList()[1];

    final confirmationDialogText = richTextNewDialog.text.toPlainText();

    expect(confirmationDialogText, contains("ABCDEF10"));
    expect(confirmationDialogText, contains("1020"));
    expect(confirmationDialogText, contains("The id you have provided ("));

    await tester.tap(find.text("It's correct"));
    await tester.pumpAndSettle();

    // The other dialog should still be here!
    expect(find.text("The end of the id doesn't match"), findsNothing);

    expect(find.byType(Dialog), findsNothing,
        reason: "No dialog should remain");
  });
}
