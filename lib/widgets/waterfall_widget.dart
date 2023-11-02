import 'package:flutter/widgets.dart';

typedef Name = Widget Function(BuildContext);
typedef DownStreamBuilder<T> = WaterfallStreamWidget<T> Function(
    BuildContext, List<Object?> upStream, List<Object> downStreamBuilders);

abstract class WaterfallStreamWidget<T> extends StatelessWidget {
  final List<Object?> upStream;
  final List<DownStreamBuilder> downStreamBuilders;

  const WaterfallStreamWidget(
      {super.key,
      required this.upStream,
      this.downStreamBuilders = const []});

  WaterfallStreamWidget getNextStreamDown(
      final BuildContext context, final T? upstreamData) {
    if (downStreamBuilders.isEmpty) {
      throw Exception("Down stream builders shouldn't be empty if you want to "
          "create an item down stream!");
    }
    final localUpStream = <Object?>[];
    localUpStream.addAll(upStream);
    localUpStream.add(upstreamData);

    return downStreamBuilders[0](
        context, localUpStream, downStreamBuilders.sublist(1));
  }
}

class WaterfallWidgetContainer extends StatelessWidget {
  final List<DownStreamBuilder> stream;

  WaterfallWidgetContainer({super.key, required this.stream}) {
    if (stream.isEmpty) {
      throw Exception("Stream cannot be empty!");
    }
  }

  @override
  Widget build(final BuildContext context) {
    return stream[0](context, [], stream.sublist(1));
  }
}
