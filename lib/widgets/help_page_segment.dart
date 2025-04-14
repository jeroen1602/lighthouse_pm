import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/markdown/markdown.dart';

class HelpPageSegment extends StatefulWidget {
  const HelpPageSegment(this.page, {this.language = 'en', super.key});

  final String page;
  final String language;

  Future<String> _loadMarkdown(final BuildContext context) async {
    return await DefaultAssetBundle.of(
      context,
    ).loadString('assets/pages/help/${page}_$language.md');
  }

  @override
  State<StatefulWidget> createState() {
    return _HelpItemState();
  }
}

class _HelpItemState extends State<HelpPageSegment> {
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final theming = Theming.fromTheme(theme);
    final style = MarkdownStyleSheet.fromTheme(theme);
    final iconStyle = style.p?.copyWith(
      fontSize: theming.bodyTextIconSize,
      color: theming.iconColor,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder(
            future: widget._loadMarkdown(context),
            builder: (final context, final snapshot) {
              if (snapshot.hasError) {
                debugPrint(snapshot.error?.toString());
                return Container();
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              return MarkdownBody(
                data: snapshot.requireData,
                styleSheet: style,
                selectable: false,
                inlineSyntaxes: [IconSyntax()],
                builders: {'icn': IconBuilder(iconStyle)},
                onTapLink: markdownOpenLinkOnTap,
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
