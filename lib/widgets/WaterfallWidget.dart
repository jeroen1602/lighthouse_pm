import 'package:flutter/widgets.dart';

typedef Name = Widget Function(BuildContext);
typedef DownStreamBuilder<T> = WaterfallStreamWidget<T> Function(
    BuildContext, List<Object> upStream, List<Object> downStreamBuilders);

abstract class WaterfallStreamWidget<T> extends StatelessWidget {
  final List<Object> upStream;
  final List<DownStreamBuilder> downStreamBuilders;

  WaterfallStreamWidget(
      {Key key, @required this.upStream, this.downStreamBuilders = const []})
      : super(key: key);

  WaterfallStreamWidget getNextStreamDown(BuildContext context, T upstreamData) {
    if (downStreamBuilders.isEmpty) {
      throw Exception("Down stream builders shouldn't be empty if you want to "
          "create an item down stream!");
    }
    final localUpStream = List<Object>();
    localUpStream.addAll(upStream);
    localUpStream.add(upstreamData);

    return downStreamBuilders[0](
        context, localUpStream, downStreamBuilders.sublist(1));
  }
}

class WaterfallWidgetContainer extends StatelessWidget {
  final List<DownStreamBuilder> stream;

  WaterfallWidgetContainer({Key key, @required this.stream}) : super(key: key) {
    if (stream.isEmpty) {
      throw Exception("Stream cannot be empty!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return stream[0](context, [], stream.sublist(1));
  }
}