part of '../markdown.dart';

abstract class MarkdownConfigFrom {
  static T fromTheme<T extends MarkdownConfig>(
    final ThemeData theme, {
    required final T Function(List<WidgetConfig> configs) creator,
    final List<WidgetConfig> extraConfigs = const [],
  }) {
    final textTheme = theme.primaryTextTheme;

    final fallbackHrConfig = theme.brightness == Brightness.dark
        ? HrConfig.darkConfig
        : const HrConfig();
    final fallbackH1Config = theme.brightness == Brightness.dark
        ? H1Config.darkConfig
        : const H1Config();
    final fallbackH2Config = theme.brightness == Brightness.dark
        ? H2Config.darkConfig
        : const H2Config();
    final fallbackH3Config = theme.brightness == Brightness.dark
        ? H3Config.darkConfig
        : const H3Config();
    final fallbackH4Config = theme.brightness == Brightness.dark
        ? H4Config.darkConfig
        : const H4Config();
    final fallbackH5Config = theme.brightness == Brightness.dark
        ? H5Config.darkConfig
        : const H5Config();
    final fallbackH6Config = theme.brightness == Brightness.dark
        ? H6Config.darkConfig
        : const H6Config();
    final fallbackPreConfig = theme.brightness == Brightness.dark
        ? PreConfig.darkConfig
        : const PreConfig();
    final fallbackPConfig = theme.brightness == Brightness.dark
        ? PConfig.darkConfig
        : const PConfig();
    final fallbackBlockquoteConfig = theme.brightness == Brightness.dark
        ? BlockquoteConfig.darkConfig
        : const BlockquoteConfig();
    final fallbackTableConfig = const TableConfig();
    final fallbackCodeConfig = theme.brightness == Brightness.dark
        ? CodeConfig.darkConfig
        : const CodeConfig();

    return creator([
      _getFromConfigAndRemove(
        extraConfigs,
        HrConfig(
          color: theme.dividerTheme.color ?? fallbackHrConfig.color,
          height: theme.dividerTheme.thickness ?? fallbackHrConfig.height,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        NoDividerH1Config(
          style: textTheme.headlineLarge ?? fallbackH1Config.style,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        NoDividerH2Config(
          style: textTheme.headlineMedium ?? fallbackH2Config.style,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        NoDividerH3Config(
          style: textTheme.headlineSmall ?? fallbackH3Config.style,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        H4Config(style: textTheme.titleLarge ?? fallbackH4Config.style),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        H5Config(style: textTheme.titleMedium ?? fallbackH5Config.style),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        H6Config(style: textTheme.titleSmall ?? fallbackH6Config.style),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        // TODO: copy using a monospaced font
        PreConfig(
          textStyle:
              textTheme.bodyMedium?.copyWith() ?? fallbackPreConfig.textStyle,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        LinkConfig(
          style:
              textTheme.bodyMedium?.copyWith(color: Colors.blue) ??
              const LinkConfig().style,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        PConfig(textStyle: textTheme.bodyMedium ?? fallbackPConfig.textStyle),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        BlockquoteConfig(
          textColor:
              textTheme.displayMedium?.color ??
              fallbackBlockquoteConfig.textColor,
          sideColor:
              textTheme.displayMedium?.backgroundColor ??
              fallbackBlockquoteConfig.sideColor,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        TableConfig(
          textBaseline:
              textTheme.bodyMedium?.textBaseline ??
              fallbackTableConfig.textBaseline,
          headerStyle: textTheme.titleMedium ?? fallbackTableConfig.headerStyle,
          bodyStyle: textTheme.bodyMedium ?? fallbackTableConfig.bodyStyle,
        ),
      ),
      _getFromConfigAndRemove(
        extraConfigs,
        // TODO: copy using a monospaced font
        CodeConfig(style: textTheme.displayMedium ?? fallbackCodeConfig.style),
      ),
      ...extraConfigs,
    ]);
  }

  static T _getFromConfigAndRemove<T extends WidgetConfig>(
    final List<WidgetConfig> configs,
    final T fallback,
  ) {
    final index = configs.indexWhere((final x) => x is T);
    if (index > 0) {
      final config = configs[index] as T;
      configs.removeAt(index);
      return config;
    }
    return fallback;
  }
}

class MarkdownConfigOpen extends MarkdownConfig {
  final Map<String, WidgetConfig> tagConfig = {};

  MarkdownConfigOpen({final List<WidgetConfig> configs = const []})
    : super(configs: configs) {
    for (final config in configs) {
      tagConfig[config.tag] = config;
    }
  }
}

class NoDividerH1Config extends H1Config {
  const NoDividerH1Config({super.style});

  @override
  HeadingDivider? get divider => null;
}

class NoDividerH2Config extends H2Config {
  const NoDividerH2Config({super.style});

  @override
  HeadingDivider? get divider => null;
}

class NoDividerH3Config extends H3Config {
  const NoDividerH3Config({super.style});

  @override
  HeadingDivider? get divider => null;
}
