import 'package:flutter/material.dart';
import 'package:lighthouse_pm/Theming.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';

import 'BasePage.dart';

class NotFoundPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    final theming = Theming.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Not found'),
      ),
      body: ContentContainerListView(
        children: [
          ListTile(
            title: Text(
              '404 Not Found',
              style: theming.headline1,
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