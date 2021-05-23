import 'package:flutter/material.dart';

///
/// A widget that will scale the content if the screen size gets too big.
///
class ContentContainerWidget extends StatelessWidget {
  static const DEFAULT_MAX_SIZE = 1280.0;
  static const DEFAULT_CONTENT_SIZE = 0.5;

  ContentContainerWidget(
      {required this.builder,
      this.maxSize = ContentContainerWidget.DEFAULT_MAX_SIZE,
      this.contentSize = ContentContainerWidget.DEFAULT_CONTENT_SIZE,
      Key? key})
      : super(key: key);

  /// At what size should the content become smaller?
  final double maxSize;

  /// What should be size of the content. A percentage between 0.0 and 1.0.
  final double contentSize;

  /// The content of the page.
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= this.maxSize) {
      final double contentWidth = screenWidth * this.contentSize;
      final double spacerWidth = screenWidth * (1.0 - this.contentSize);

      return Row(
        children: [
          Container(
            width: spacerWidth / 2.0,
          ),
          Container(
            child: Material(
              child: this.builder(context),
              elevation: 2.0,
            ),
            width: contentWidth,
          ),
          Container(
            width: spacerWidth / 2.0,
          ),
        ],
      );
    } else {
      return this.builder(context);
    }
  }
}
