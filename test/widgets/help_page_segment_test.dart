import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/widgets/help_page_segment.dart';
import 'package:markdown_widget/markdown_widget.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../helpers/widget_helpers.dart';

class URLLauncherFake extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? _lastUrl;

  String? get lastUrl => _lastUrl;

  @override
  Future<bool> launchUrl(final String url, final LaunchOptions options) async {
    _lastUrl = url;
    return true;
  }
}

void main() {
  group('help_page_segment', () {
    testWidgets('Should open links', (final WidgetTester tester) async {
      final fakeLauncher = URLLauncherFake();
      UrlLauncherPlatform.instance = fakeLauncher;

      await tester.pumpWidget(
        buildTestApp((final context) {
          return ListView(
            children: const [HelpPageSegment('extended', language: 'en')],
          );
        }),
      );

      await tester.pumpAndSettle();

      final widget = tester.firstWidget(find.byType(MarkdownBlock));

      expect(widget, isA<MarkdownBlock>());

      await tester.tapOnText(
        find.textRange.ofSubstring('create an issue on Github'),
      );
      expect(
        fakeLauncher.lastUrl,
        "https://github.com/jeroen1602/lighthouse_pm/issues/",
      );
    });
  });
}
