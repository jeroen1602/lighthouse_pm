part of lighthouse_markdown;

///
/// Convert the markdown content inside the `<sup>` tag into actual super
/// text.
///
/// This doesn't use its own block render and just uses the normal text.
/// It uses the special superscript unicode characters.
/// https://unicode-table.com/en/blocks/superscripts-and-subscripts/
/// This means that it currently can only convert numbers, since that is
/// all that is needed for the current implementation.
class SuperscriptSyntax extends md.InlineSyntax {
  SuperscriptSyntax() : super('<sup>[^<]*<\\/sup>', caseSensitive: false);

  static const _superScript = {
    "0": "⁰",
    "1": "¹",
    "2": "²",
    "3": "³",
    "4": "⁴",
    "5": "⁵",
    "6": "⁶",
    "7": "⁷",
    "8": "⁸",
    "9": "⁹",
    "-": "⁻"
  };

  ///
  /// Convert the string into the corresponding superscript characters.
  /// It currently only works for numbers and the `-`-sign.
  static String toSuperScript(final String input) {
    String out = "";
    for (final character in input.characters) {
      final converted = _superScript[character];
      out += converted ?? character;
    }
    return out;
  }

  @override
  bool onMatch(final md.InlineParser parser, final Match match) {
    final superScript = match[0];
    // These magic numbers remove the starting `<sup>` and closing `</sup>` from
    // around the content. It could be done better but it is enough for this
    // simple implementation.
    final content = superScript?.substring(5, superScript.length - 6);
    if (content == null || content.trim().isEmpty) {
      parser.advanceBy(1);
      return false;
    }
    final toSuper = toSuperScript(content);
    parser.addNode(md.Text(toSuper));
    return true;
  }
}
