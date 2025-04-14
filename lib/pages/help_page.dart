import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/local/main_page_settings.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/help_page_segment.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

import 'base_page.dart';

///
/// A widget showing the a material scaffold with some help items the user may need.
///
class HelpPage extends BasePage with WithBlocStateless {
  const HelpPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: MainPageSettings.mainPageSettingsStreamBuilder(
        bloc: blocWithoutListen(context),
        builder: (final context, final settings) {
          return ContentContainerListView(
            children: [
              const HelpPageSegment('metadata'),
              const HelpPageSegment('nickname'),
              const HelpPageSegment('group'),
              if (LighthouseProvider.instance.getPairBackEnds().isNotEmpty)
                const HelpPageSegment('pairing'),
              const HelpPageSegment('extended'),
            ],
          );
        },
      ),
    );
  }
}
