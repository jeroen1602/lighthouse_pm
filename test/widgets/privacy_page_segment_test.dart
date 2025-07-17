import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/widgets/privacy_page_segment.dart';
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
  testWidgets('Should open links', (final WidgetTester tester) async {
    final fakeLauncher = URLLauncherFake();
    UrlLauncherPlatform.instance = fakeLauncher;

    await tester.pumpWidget(
      buildTestApp((final context) {
        return ListView(
          children: const [PrivacyPageSegment(version: "1.1", language: "en")],
        );
      }),
    );

    await tester.pumpAndSettle();

    final widget = tester.firstWidget(find.byType(MarkdownBlock));

    expect(widget, isA<MarkdownBlock>());

    await tester.tapOnText(
      find.textRange.ofSubstring('Github privacy statement'),
    );
    expect(
      fakeLauncher.lastUrl,
      "https://docs.github.com/en/github/site-policy/github-privacy-statement#github-pages",
    );
  });
}
