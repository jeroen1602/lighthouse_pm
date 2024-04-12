import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/widgets/markdown/markdown.dart';

import '../../helpers/widget_helpers.dart';

/// This lookup contains the current material icons conversion that [IconBuilder]
/// supports.
///
/// This is here to make coverage analyzer happy, and to make sure that all
/// these icons do get converted correctly.
final materialIconsLookup = {
  'power_settings_new': Icons.power_settings_new,
  'bluetooth_connected': Icons.bluetooth_connected,
  'clear': Icons.clear,
};

void main() {
  group('markdown', () {
    group('super_script_syntax', () {
      testWidgets('Should convert svg icons',
          (final WidgetTester tester) async {
        const exampleText = '# wow a test\n\n'
            'Now with svg icons <icon>svg-group-edit-icon</icon>\n';

        await tester.pumpWidget(buildTestApp((final context) {
          return Markdown(data: exampleText, inlineSyntaxes: [
            IconSyntax(),
          ], builders: {
            'icn': IconBuilder(null),
          });
        }));

        await tester.pumpAndSettle();

        final richTexts = tester
            .widgetList(find.descendant(
                of: find.byType(Markdown), matching: find.byType(RichText)))
            .toList(growable: false);

        expect(richTexts, hasLength(2),
            reason: 'Should contain two rich text blocks');

        final children = ((richTexts[1] as RichText).text as TextSpan).children;
        expect(children, isNotNull);
        expect(children, hasLength(1), reason: 'Should have nested TextSpan');
        expect(children![0], isA<TextSpan>());
        expect(children[0].toPlainText(), contains('svg'));
        expect(children[0].toPlainText(), isNot(contains('<icon>')));
        expect(children[0].toPlainText(), isNot(contains('</icon>')));
        expect(children[0].toPlainText(), isNot(contains('<icn>')));
        expect(children[0].toPlainText(), isNot(contains('</icn>')));

        expect((children[0] as TextSpan).children, isNotNull);
        expect((children[0] as TextSpan).children![1], isA<WidgetSpan>());
        expect(((children[0] as TextSpan).children![1] as WidgetSpan).child,
            isA<SvgPicture>());

        final svg = ((children[0] as TextSpan).children![1] as WidgetSpan).child
            as SvgPicture;
        final loader = svg.bytesLoader;
        expect(loader, isA<SvgAssetLoader>());
        expect(
            (loader as SvgAssetLoader).assetName, contains('group-edit-icon'));
      });

      testWidgets('Should convert material icons',
          (final WidgetTester tester) async {
        const exampleText = '# wow a test\n\n'
            'Now with mat icons <icon>mat-power_settings_new</icon>\n';

        await tester.pumpWidget(buildTestApp((final context) {
          return Markdown(data: exampleText, inlineSyntaxes: [
            IconSyntax(),
          ], builders: {
            'icn': IconBuilder(null),
          });
        }));

        await tester.pumpAndSettle();

        final richTexts = tester
            .widgetList(find.descendant(
                of: find.byType(Markdown), matching: find.byType(RichText)))
            .toList(growable: false);

        expect(richTexts, hasLength(3),
            reason: 'Should contain three rich text blocks');

        final children = ((richTexts[1] as RichText).text as TextSpan).children;
        expect(children, isNotNull);
        expect(children, hasLength(1), reason: 'Should have nested TextSpan');
        expect(children![0], isA<TextSpan>());
        expect(children[0].toPlainText(), contains('mat'));
        expect(children[0].toPlainText(), isNot(contains('<icon>')));
        expect(children[0].toPlainText(), isNot(contains('</icon>')));
        expect(children[0].toPlainText(), isNot(contains('<icn>')));
        expect(children[0].toPlainText(), isNot(contains('</icn>')));

        expect((children[0] as TextSpan).children, isNotNull);
        expect((children[0] as TextSpan).children![1], isA<WidgetSpan>());
        expect(((children[0] as TextSpan).children![1] as WidgetSpan).child,
            isA<Icon>());

        final icon = ((children[0] as TextSpan).children![1] as WidgetSpan)
            .child as Icon;
        expect(icon.icon, Icons.power_settings_new);
      });

      testWidgets('Should not convert unknown material icons',
          (final WidgetTester tester) async {
        const exampleText = '# wow a test\n\n'
            'Now with non existent mat icons <icon>mat-non_existent</icon>\n';

        await tester.pumpWidget(buildTestApp((final context) {
          return Markdown(data: exampleText, inlineSyntaxes: [
            IconSyntax(),
          ], builders: {
            'icn': IconBuilder(null),
          });
        }));

        await tester.pumpAndSettle();

        final richTexts = tester
            .widgetList(find.descendant(
                of: find.byType(Markdown), matching: find.byType(RichText)))
            .toList(growable: false);

        expect(richTexts, hasLength(2),
            reason: 'Should contain two rich text blocks');

        final text =
            ((richTexts[1] as RichText).text as TextSpan).toPlainText();
        expect(text, contains('mat'));
        expect(text, isNot(contains('<icon>')));
        expect(text, isNot(contains('</icon>')));
        expect(text, isNot(contains('<icn>')));
        expect(text, isNot(contains('</icn>')));

        // Should just put the name of the icon instead of the actual icon.
        expect(text, contains('mat-non_existent'));
      });

      for (final entry in materialIconsLookup.entries) {
        testWidgets('Should convert material icon: "${entry.key}"',
            (final WidgetTester tester) async {
          final exampleText = '# wow a test\n\n'
              'Now with mat icons <icon>mat-${entry.key}</icon>\n';

          await tester.pumpWidget(buildTestApp((final context) {
            return Markdown(data: exampleText, inlineSyntaxes: [
              IconSyntax(),
            ], builders: {
              'icn': IconBuilder(null),
            });
          }));

          await tester.pumpAndSettle();

          final richTexts = tester
              .widgetList(find.descendant(
                  of: find.byType(Markdown), matching: find.byType(RichText)))
              .toList(growable: false);

          expect(richTexts, hasLength(3),
              reason: 'Should contain three rich text blocks');

          final children =
              ((richTexts[1] as RichText).text as TextSpan).children;
          expect(children, isNotNull);
          expect(children, hasLength(1), reason: 'Should have nested children');

          expect(children![0], isA<TextSpan>());
          expect((children[0] as TextSpan).children, isNotNull);
          expect((children[0] as TextSpan).children![1], isA<WidgetSpan>());
          expect(((children[0] as TextSpan).children![1] as WidgetSpan).child,
              isA<Icon>());

          final icon = ((children[0] as TextSpan).children![1] as WidgetSpan)
              .child as Icon;
          expect(icon.icon, entry.value);
        });
      }
    });
  });
}
