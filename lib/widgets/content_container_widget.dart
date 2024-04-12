import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_platform/shared_platform.dart';

///
/// A widget that will scale the content if the screen size gets too big.
///
class ContentContainerWidget extends StatelessWidget {
  static const defaultMaxSize = 1280.0;
  static const defaultContentSize = 0.5;

  const ContentContainerWidget(
      {required this.builder,
      this.maxSize = ContentContainerWidget.defaultMaxSize,
      this.contentSize = ContentContainerWidget.defaultContentSize,
      this.addMaterial = true,
      super.key});

  /// At what size should the content become smaller?
  final double maxSize;

  /// What should be size of the content. A percentage between 0.0 and 1.0.
  final double contentSize;

  /// The content of the page.
  final WidgetBuilder builder;

  final bool addMaterial;

  @override
  Widget build(final BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= maxSize) {
      final double contentWidth = screenWidth * contentSize;
      final double spacerWidth = screenWidth * (1.0 - contentSize);

      return Row(
        children: [
          Container(
            width: spacerWidth / 2.0,
          ),
          if (addMaterial)
            SizedBox(
              width: contentWidth,
              child: Material(
                elevation: 2.0,
                child: builder(context),
              ),
            )
          else
            SizedBox(
              width: contentWidth,
              child: builder(context),
            ),
          Container(
            width: spacerWidth / 2.0,
          ),
        ],
      );
    } else {
      return builder(context);
    }
  }
}

class ContentContainerListView extends StatelessWidget {
  const ContentContainerListView({
    required this.children,
    this.maxSize = ContentContainerWidget.defaultMaxSize,
    this.contentSize = ContentContainerWidget.defaultContentSize,
    super.key,
  });

  /// At what size should the content become smaller?
  final double maxSize;

  /// What should be size of the content. A percentage between 0.0 and 1.0.
  final double contentSize;

  static Widget builder({
    final Key? key,
    final int? itemCount,
    final double maxSize = ContentContainerWidget.defaultMaxSize,
    final double contentSize = ContentContainerWidget.defaultContentSize,
    required final NullableIndexedWidgetBuilder itemBuilder,
  }) {
    return Stack(
      children: [
        ContentContainerWidget(
          builder: (final context) {
            return Container();
          },
          maxSize: maxSize,
          contentSize: contentSize,
        ),
        ContentScrollbar(
            scrollbarChildBuilder: (final context, final controller) {
          return ListView.builder(
            controller: controller,
            itemBuilder: (final BuildContext context, final int index) {
              final Widget? content = itemBuilder(context, index);
              return ContentContainerWidget(
                builder: (final BuildContext context) {
                  if (content == null) {
                    return Container();
                  }
                  return content;
                },
                addMaterial: false,
                maxSize: maxSize,
                contentSize: contentSize,
              );
            },
            itemCount: itemCount,
          );
        }),
      ],
    );
  }

  final List<Widget> children;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: [
        ContentContainerWidget(
          builder: (final context) {
            return Container();
          },
          maxSize: maxSize,
          contentSize: contentSize,
        ),
        ContentScrollbar(
          scrollbarChildBuilder: (final context, final controller) {
            return ListView(
                controller: controller,
                children: children
                    .map((final item) => ContentContainerWidget(
                          builder: (final context) {
                            return item;
                          },
                          addMaterial: false,
                          maxSize: maxSize,
                          contentSize: contentSize,
                        ))
                    .toList());
          },
          maxSize: maxSize,
        ),
      ],
    );
  }
}

typedef ScrollbarChildBuilder = Widget Function(
    BuildContext context, ScrollController controller);

class ContentScrollbar extends StatelessWidget {
  ContentScrollbar({
    super.key,
    final ScrollController? controller,
    required this.scrollbarChildBuilder,
    this.maxSize = ContentContainerWidget.defaultMaxSize,
  }) : controller = controller ?? ScrollController();

  final ScrollbarChildBuilder scrollbarChildBuilder;

  final ScrollController controller;

  final double maxSize;

  @override
  Widget build(final BuildContext context) {
    final child = scrollbarChildBuilder(context, controller);
    return Scrollbar(
        controller: controller,
        thumbVisibility: alwaysShowScrollbar(context, maxSize: maxSize),
        child: child);
  }

  static bool alwaysShowScrollbar(
    final BuildContext context, {
    final double maxSize = ContentContainerWidget.defaultMaxSize,
  }) {
    if (SharedPlatform.isLinux) {
      return true;
    } else if (SharedPlatform.isWeb) {
      final double screenWidth = MediaQuery.of(context).size.width;

      return screenWidth >= maxSize;
    }

    return false;
  }

  static final BehaviorSubject<bool> _alwaysShowScrollbarSubject =
      BehaviorSubject.seeded(false);

  static Stream<bool> get alwaysShowScrollbarStream =>
      _alwaysShowScrollbarSubject.stream;

  static void updateShowScrollbarSubject(final BuildContext context) {
    final startValue = _alwaysShowScrollbarSubject.valueOrNull;
    final newValue = alwaysShowScrollbar(context);
    if (newValue != startValue) {
      _alwaysShowScrollbarSubject.add(newValue);
    }
  }
}
