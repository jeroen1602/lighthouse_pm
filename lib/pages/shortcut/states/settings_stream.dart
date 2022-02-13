import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/local/main_page_settings.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';

class SettingsStream extends WaterfallStreamWidget<MainPageSettings>
    with WithBlocStateless {
  SettingsStream(
      {final Key? key,
      required final List<Object?> upStream,
      final List<DownStreamBuilder> downStreamBuilders = const []})
      : super(
            key: key,
            upStream: upStream,
            downStreamBuilders: downStreamBuilders);

  @override
  Widget build(final BuildContext context) {
    return MainPageSettings.mainPageSettingsStreamBuilder(
        bloc: blocWithoutListen(context),
        builder: (final context, final settings) {
          if (settings == null) {
            return const CircularProgressIndicator();
          }
          return getNextStreamDown(context, settings);
        });
  }

  static DownStreamBuilder createBuilder() {
    return (final context, final upStream, final downStream) {
      return SettingsStream(
        upStream: upStream,
        downStreamBuilders: downStream.cast<DownStreamBuilder>(),
      );
    };
  }
}
