import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';

import 'base_page.dart';

class NotFoundPage extends BasePage {
  const NotFoundPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    final theming = Theming.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: ContentContainerListView(
        children: [
          ListTile(
            title: Text(
              '404 Not Found',
              style: theming.displayLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const ListTile(
            title: Text(
              "The page you are trying to reach doesn't exist.",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
