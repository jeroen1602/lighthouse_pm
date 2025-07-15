import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/local/main_page_settings.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';

class SettingsStream extends WaterfallStreamWidget<MainPageSettings>
    with WithBlocStateless {
  SettingsStream({
    super.key,
    required super.upStream,
    super.downStreamBuilders,
  });

  @override
  Widget build(final BuildContext context) {
    return MainPageSettings.mainPageSettingsStreamBuilder(
      bloc: blocWithoutListen(context),
      builder: (final context, final settings) {
        return getNextStreamDown(context, settings);
      },
    );
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
