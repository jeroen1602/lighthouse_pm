part of '../markdown.dart';

class IconConfig extends InlineConfig {
  @nonVirtual
  @override
  String get tag => 'icn';

  final TextStyle? style;

  IconConfig({this.style});
}

extension MarkdownConfigIconConfigExt on MarkdownConfig {
  IconConfig get iconConfig => _getConfig<IconConfig>('icn', IconConfig());

  T _getConfig<T extends WidgetConfig>(final String tag, final T defaultValue) {
    if (this is! MarkdownConfigOpen) {
      return defaultValue;
    }
    final openConfig = this as MarkdownConfigOpen;
    final config = openConfig.tagConfig[tag];
    if (config == null || config is! T) {
      return defaultValue;
    }
    return config;
  }
}
