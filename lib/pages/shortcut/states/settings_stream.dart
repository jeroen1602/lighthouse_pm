import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/local/main_page_settings.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';

class SettingsStream extends WaterfallStreamWidget<MainPageSettings>
    with WithBlocStateless {
  SettingsStream(
      {Key? key,
      required List<Object?> upStream,
      List<DownStreamBuilder> downStreamBuilders = const []})
      : super(
            key: key,
            upStream: upStream,
            downStreamBuilders: downStreamBuilders);

  @override
  Widget build(BuildContext context) {
    return MainPageSettings.mainPageSettingsStreamBuilder(
        bloc: blocWithoutListen(context),
        builder: (context, settings) {
          if (settings == null) {
            return CircularProgressIndicator();
          }
          return getNextStreamDown(context, settings);
        });
  }

  static DownStreamBuilder createBuilder() {
    return (context, upStream, downStream) {
      return SettingsStream(
        upStream: upStream,
        downStreamBuilders: downStream.cast<DownStreamBuilder>(),
      );
    };
  }
}
