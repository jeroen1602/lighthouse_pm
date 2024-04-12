import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_pm/data/local/app_style.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:rxdart/rxdart.dart';

class ThemeDataAndAppStyleStream {
  const ThemeDataAndAppStyleStream(final ThemeMode? themeMode,
      final AppStyle? style, final bool? alwaysShowScrollbar)
      : themeMode = themeMode ?? ThemeMode.system,
        style = style ?? AppStyle.material,
        alwaysShowScrollbar = alwaysShowScrollbar ?? false;

  const ThemeDataAndAppStyleStream.withDefaults() : this(null, null, null);

  final ThemeMode themeMode;
  final AppStyle style;
  final bool alwaysShowScrollbar;

  static Stream<ThemeDataAndAppStyleStream> getStream(
      final LighthousePMBloc bloc) {
    return Rx.combineLatest3<ThemeMode, AppStyle, bool,
            ThemeDataAndAppStyleStream>(
        MergeStream([
          Stream.value(ThemeMode.system),
          bloc.settings.getPreferredThemeAsStream()
        ]),
        MergeStream([
          Stream.fromFuture(SettingsDao.defaultAppStyle),
          bloc.settings.getPreferredStyleAsStream()
        ]),
        MergeStream(
            [Stream.value(false), ContentScrollbar.alwaysShowScrollbarStream]),
        (final themeMode, final style, final showScrollbar) {
      return ThemeDataAndAppStyleStream(themeMode, style, showScrollbar);
    });
  }
}
