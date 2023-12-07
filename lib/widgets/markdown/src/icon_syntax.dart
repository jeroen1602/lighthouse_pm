part of '../markdown.dart';

///
/// Convert an <icon>{the icon}</icon> tag into an element that can be used in
/// markdown. Use the [IconBuilder] to then build the correct icon.
///
class IconSyntax extends md.InlineSyntax {
  IconSyntax() : super('<icon>[^<]*<\\/icon>', caseSensitive: false);

  @override
  bool onMatch(final md.InlineParser parser, final Match match) {
    final superScript = match[0];
    // These magic numbers remove the starting `<icon>` and closing `</icon>` from
    // around the content. It could be done better but it is enough for this
    // simple implementation.
    final content = superScript?.substring(6, superScript.length - 7);
    if (content == null || content.trim().isEmpty) {
      parser.advanceBy(1);
      return false;
    }

    final element = md.Element.text('icn', content);
    parser.addNode(element);
    return true;
  }
}
