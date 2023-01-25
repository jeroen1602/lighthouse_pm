import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/privacy_page_segment.dart';

import '../base_page.dart';

class PrivacyPage extends BasePage {
  const PrivacyPage({final Key? key}) : super(key: key);

  static const version1_1Date = "January 1st 2022";

  @override
  Widget buildPage(final BuildContext context) {
    final theming = Theming.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy"),
      ),
      body: ContentContainerListView(children: [
        PrivacyPageSegment(
          version: "1.1",
          language: "en",
          startDate: DateTime(2022, 1, 1),
        ),
        const Divider(
          thickness: 1.5,
        ),
        ListTile(
          title: Text(
            "Older versions",
            style: theming.headlineMedium,
          ),
        ),
        const Divider(
          thickness: 1.5,
        ),
        PrivacyPageSegment(
          version: "1.0",
          language: "en",
          endDate: DateTime(2022, 1, 1),
        ),
        Container(
          height: 24.0,
        )
      ]),
    );
  }
}
