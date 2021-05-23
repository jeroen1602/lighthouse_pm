import 'package:flutter/material.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';

import 'BasePage.dart';

class NotFoundPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not found'),
      ),
      body: ContentContainerWidget(
        builder: (context) {
          final theme = Theme.of(context);
          final width = MediaQuery.of(context).size.width;
          var iconSize = width - 10.0;
          if (width >= ContentContainerWidget.DEFAULT_MAX_SIZE) {
            iconSize = width * ContentContainerWidget.DEFAULT_CONTENT_SIZE - 10;
          }

          return ListView(
            children: [
              ListTile(
                title: Text(
                  '404 Not Found',
                  style: theme.textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
              ),
              ListTile(
                title: Text(
                  "The page you are trying to reach doesn't exist.",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
