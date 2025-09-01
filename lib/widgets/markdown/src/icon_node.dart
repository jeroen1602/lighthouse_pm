part of '../markdown.dart';

///
/// Convert an [md.Element] to the actual [Widget] for rendering. Use [IconSyntax]
/// to get these elements from a markdown.
///
/// Add it to the [MarkdownGenerator] using:
/// ```dart
///MarkdownGenerator(
//   inlineSyntaxList: [IconSyntax()],
//   generators: [IconNode.iconGeneratorWithTag],
//   textGenerator: getMarkdownTextGenerator(),
// );
///```
///
/// If the icon name starts with `svg-` then it will be interpreted as an svg
/// and rendered. If the icon name starts with `mat-` then it will be interpreted
/// as an icon in [Icons].
///
/// `mat-` [Icons] need to be translated manually because no reflection is used
/// for this implementation
class IconNode extends ElementNode {
  final String iconName;
  final IconConfig iconConfig;

  TextStyle? get preferredStyle => iconConfig.style;

  IconNode(this.iconName, this.iconConfig);

  static final iconGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: "icn",
    generator: (final e, final config, final visitor) =>
        IconNode(e.textContent, config.iconConfig),
  );

  Widget _getSVG(final String name) {
    return SvgPicture.asset(
      'assets/images/$name.svg',
      height: preferredStyle?.fontSize ?? 17,
      width: preferredStyle?.fontSize ?? 17,
      colorFilter: preferredStyle?.color != null
          ? ColorFilter.mode(preferredStyle!.color!, BlendMode.srcIn)
          : null,
    );
  }

  Widget? _getMatIcon(final String name) {
    late IconData? data;

    /// Update this to add more supported [Icons].
    switch (name) {
      case 'power_settings_new':
        data = Icons.power_settings_new;
        break;
      case 'bluetooth_connected':
        data = Icons.bluetooth_connected;
        break;
      case 'clear':
        data = Icons.clear;
        break;
      default:
        data = null;
        break;
    }
    if (data != null) {
      return Icon(
        data,
        size: preferredStyle?.fontSize ?? 17,
        color: preferredStyle?.color,
      );
    }
    return null;
  }

  Widget? _getIcon(final String name) {
    if (name.startsWith('svg-')) {
      return _getSVG(name.substring('svg-'.length));
    } else if (name.startsWith('mat-')) {
      return _getMatIcon(name.substring('mat-'.length));
    }
    return null;
  }

  @override
  InlineSpan build() {
    final icon = _getIcon(iconName);
    if (icon != null) {
      return TextSpan(children: [WidgetSpan(child: icon)]);
    }
    return TextSpan(text: iconName);
  }
}
