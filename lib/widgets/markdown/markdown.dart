library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:meta/meta.dart';

part 'src/config_from_theme.dart';
part 'src/icon_config.dart';
part 'src/icon_node.dart';
part 'src/icon_syntax.dart';
part 'src/super_script_syntax.dart';

TextNodeGenerator getMarkdownTextGenerator() {
  String? lastVisitedTag;

  return (
    final md.Node node,
    final MarkdownConfig config,
    final WidgetVisitor visitor,
  ) {
    var text = node.textContent;

    // shamelessly copied from flutter markdown.

    // The leading spaces pattern is used to identify spaces
    // at the beginning of a line of text.
    final RegExp leadingSpacesPattern = RegExp(r'^ *');

    // The soft line break is used to identify the spaces at the end of a line
    // of text and the leading spaces in the immediately following the line
    // of text. These spaces are removed in accordance with the Markdown
    // specification on soft line breaks when lines of text are joined.
    final RegExp softLineBreakPattern = RegExp(r' ?\n *');

    // Leading spaces following a hard line break are ignored.
    // https://github.github.com/gfm/#example-657
    // Leading spaces in paragraph or list item are ignored
    // https://github.github.com/gfm/#example-192
    // https://github.github.com/gfm/#example-236
    if (const <String>['ul', 'ol', 'li', 'p', 'br'].contains(lastVisitedTag)) {
      text = text.replaceAll(leadingSpacesPattern, '');
    }

    text = text.replaceAll(softLineBreakPattern, ' ');
    if (node is md.Element) {
      lastVisitedTag = node.tag;
    } else {
      lastVisitedTag = null;
    }

    return TextNode(text: text, style: config.p.textStyle);
  };
}
