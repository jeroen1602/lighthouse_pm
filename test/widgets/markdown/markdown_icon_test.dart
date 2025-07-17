import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/widgets/markdown/markdown.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../helpers/widget_helpers.dart';

/// This lookup contains the current material icons conversion that [IconNode]
/// supports.
///
/// This is here to make coverage analyzer happy, and to make sure that all
/// these icons do get converted correctly.
final materialIconsLookup = {
  'power_settings_new': Icons.power_settings_new,
  'bluetooth_connected': Icons.bluetooth_connected,
  'clear': Icons.clear,
};

List<InlineSpan>? _getMyTextSpanFromRichText(
  final List<Widget> input, {
  final index = 1,
}) {
  final richText = input.elementAtOrNull(index);
  if (richText == null) {
    return null;
  }
  if (richText is! RichText) {
    return null;
  }
  final text = richText.text;
  if (text is! TextSpan) {
    return null;
  }
  final children1 = text.children;
  if (children1 == null || children1.length != 1) {
    return null;
  }
  final children2 = children1[0];
  if (children2 is! TextSpan) {
    return null;
  }
  return children2.children;
}

void main() {
  group('markdown', () {
    group('super_script_syntax', () {
      testWidgets('Should convert svg icons', (
        final WidgetTester tester,
      ) async {
        const exampleText =
            '#### wow a test\n\n'
            'Now with svg icons <icon>svg-group-edit-icon</icon>\n';

        await tester.pumpWidget(
          buildTestApp((final context) {
            return MarkdownBlock(
              data: exampleText,
              generator: MarkdownGenerator(
                inlineSyntaxList: [IconSyntax()],
                generators: [IconNode.iconGeneratorWithTag],
              ),
            );
          }),
        );

        await tester.pumpAndSettle();

        final richTexts = tester
            .widgetList(
              find.descendant(
                of: find.byType(MarkdownBlock),
                matching: find.byType(RichText),
              ),
            )
            .toList(growable: false);

        expect(
          richTexts,
          hasLength(2),
          reason: 'Should contain two rich text blocks',
        );

        final children = _getMyTextSpanFromRichText(richTexts);
        expect(children, isNotNull);
        expect(children, hasLength(1), reason: 'Should have nested TextSpan');
        expect(children![0], isA<TextSpan>());
        expect(children[0].toPlainText(), contains('svg'));
        expect(children[0].toPlainText(), isNot(contains('<icon>')));
        expect(children[0].toPlainText(), isNot(contains('</icon>')));
        expect(children[0].toPlainText(), isNot(contains('<icn>')));
        expect(children[0].toPlainText(), isNot(contains('</icn>')));

        expect((children[0] as TextSpan).children, isNotNull);

        final iconTextSpan = (children[0] as TextSpan).children![1];
        expect(iconTextSpan, isA<TextSpan>());
        expect((iconTextSpan as TextSpan).children, hasLength(1));

        expect(iconTextSpan.children![0], isA<WidgetSpan>());
        expect(
          (iconTextSpan.children![0] as WidgetSpan).child,
          isA<SvgPicture>(),
        );

        final svg =
            (iconTextSpan.children![0] as WidgetSpan).child as SvgPicture;
        final loader = svg.bytesLoader;
        expect(loader, isA<SvgAssetLoader>());
        expect(
          (loader as SvgAssetLoader).assetName,
          contains('group-edit-icon'),
        );
      });

      testWidgets('Should convert material icons', (
        final WidgetTester tester,
      ) async {
        const exampleText =
            '#### wow a test\n\n'
            'Now with mat icons <icon>mat-power_settings_new</icon>\n';

        await tester.pumpWidget(
          buildTestApp((final context) {
            return MarkdownBlock(
              data: exampleText,
              generator: MarkdownGenerator(
                inlineSyntaxList: [IconSyntax()],
                generators: [IconNode.iconGeneratorWithTag],
              ),
            );
          }),
        );

        await tester.pumpAndSettle();

        final richTexts = tester
            .widgetList(
              find.descendant(
                of: find.byType(MarkdownBlock),
                matching: find.byType(RichText),
              ),
            )
            .toList(growable: false);

        expect(
          richTexts,
          hasLength(3),
          reason: 'Should contain three rich text blocks',
        );

        final children = _getMyTextSpanFromRichText(richTexts);
        expect(children, isNotNull);
        expect(children, hasLength(1), reason: 'Should have nested TextSpan');
        expect(children![0], isA<TextSpan>());
        expect(children[0].toPlainText(), contains('mat'));
        expect(children[0].toPlainText(), isNot(contains('<icon>')));
        expect(children[0].toPlainText(), isNot(contains('</icon>')));
        expect(children[0].toPlainText(), isNot(contains('<icn>')));
        expect(children[0].toPlainText(), isNot(contains('</icn>')));

        expect((children[0] as TextSpan).children, isNotNull);

        final iconTextSpan = (children[0] as TextSpan).children![1];
        expect(iconTextSpan, isA<TextSpan>());
        expect((iconTextSpan as TextSpan).children, hasLength(1));

        expect(iconTextSpan.children![0], isA<WidgetSpan>());
        expect((iconTextSpan.children![0] as WidgetSpan).child, isA<Icon>());

        final icon = (iconTextSpan.children![0] as WidgetSpan).child as Icon;
        expect(icon.icon, Icons.power_settings_new);
      });

      testWidgets('Should not convert unknown material icons', (
        final WidgetTester tester,
      ) async {
        const exampleText =
            '#### wow a test\n\n'
            'Now with non existent mat icons <icon>mat-non_existent</icon>\n';

        await tester.pumpWidget(
          buildTestApp((final context) {
            return MarkdownBlock(
              data: exampleText,
              generator: MarkdownGenerator(
                inlineSyntaxList: [IconSyntax()],
                generators: [IconNode.iconGeneratorWithTag],
              ),
            );
          }),
        );

        await tester.pumpAndSettle();

        final richTexts = tester
            .widgetList(
              find.descendant(
                of: find.byType(MarkdownBlock),
                matching: find.byType(RichText),
              ),
            )
            .toList(growable: false);

        expect(
          richTexts,
          hasLength(2),
          reason: 'Should contain two rich text blocks',
        );

        final text =
            ((richTexts[1] as RichText).text as TextSpan).toPlainText();
        expect(text, contains('mat-'));
        expect(text, isNot(contains('<icon>')));
        expect(text, isNot(contains('</icon>')));
        expect(text, isNot(contains('<icn>')));
        expect(text, isNot(contains('</icn>')));

        // Should just put the name of the icon instead of the actual icon.
        expect(text, contains('mat-non_existent'));
      });

      for (final entry in materialIconsLookup.entries) {
        testWidgets('Should convert material icon: "${entry.key}"', (
          final WidgetTester tester,
        ) async {
          final exampleText =
              '#### wow a test\n\n'
              'Now with mat icons <icon>mat-${entry.key}</icon>\n';

          await tester.pumpWidget(
            buildTestApp((final context) {
              return MarkdownBlock(
                data: exampleText,
                generator: MarkdownGenerator(
                  inlineSyntaxList: [IconSyntax()],
                  generators: [IconNode.iconGeneratorWithTag],
                ),
              );
            }),
          );

          await tester.pumpAndSettle();

          final richTexts = tester
              .widgetList(
                find.descendant(
                  of: find.byType(MarkdownBlock),
                  matching: find.byType(RichText),
                ),
              )
              .toList(growable: false);

          expect(
            richTexts,
            hasLength(3),
            reason: 'Should contain three rich text blocks',
          );

          final children = _getMyTextSpanFromRichText(richTexts);
          expect(children, isNotNull);
          expect(children, hasLength(1), reason: 'Should have nested children');

          expect(children![0], isA<TextSpan>());
          expect((children[0] as TextSpan).children, isNotNull);

          final iconTextSpan = (children[0] as TextSpan).children![1];
          expect(iconTextSpan, isA<TextSpan>());
          expect((iconTextSpan as TextSpan).children, hasLength(1));

          expect(iconTextSpan.children![0], isA<WidgetSpan>());
          expect((iconTextSpan.children![0] as WidgetSpan).child, isA<Icon>());

          final icon = (iconTextSpan.children![0] as WidgetSpan).child as Icon;
          expect(icon.icon, entry.value);
        });
      }
    });
  });
}
